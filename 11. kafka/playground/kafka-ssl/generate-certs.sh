#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$ROOT_DIR/secrets"
CA_DIR="$ROOT_DIR/pki/ca"
PASSWORD="${KAFKA_SSL_PASSWORD:-changeit}"
VALIDITY_DAYS="${VALIDITY_DAYS:-825}"

command -v keytool >/dev/null 2>&1 || {
  echo "keytool is required. Install JDK 17+ (Java 21 recommended)." >&2
  exit 1
}

rm -rf "$SECRETS_DIR" "$CA_DIR"
mkdir -p "$SECRETS_DIR" "$CA_DIR"

CA_KEYSTORE="$CA_DIR/ca.keystore.p12"
CA_CERT="$SECRETS_DIR/ca.crt"
TRUSTSTORE="$SECRETS_DIR/kafka.truststore.p12"

printf '%s\n' "$PASSWORD" > "$SECRETS_DIR/keystore_creds"
printf '%s\n' "$PASSWORD" > "$SECRETS_DIR/key_creds"
printf '%s\n' "$PASSWORD" > "$SECRETS_DIR/truststore_creds"

# 1) Lab Certificate Authority. Keep this private keystore away from brokers.
keytool -genkeypair \
  -alias kafka-lab-ca \
  -keyalg RSA \
  -keysize 4096 \
  -sigalg SHA256withRSA \
  -dname "CN=Kafka Lab CA,OU=Platform Engineering,O=Hady Lab,L=Dubai,ST=Dubai,C=AE" \
  -ext bc:c \
  -validity 3650 \
  -keystore "$CA_KEYSTORE" \
  -storetype PKCS12 \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" \
  -noprompt

keytool -exportcert \
  -alias kafka-lab-ca \
  -keystore "$CA_KEYSTORE" \
  -storetype PKCS12 \
  -storepass "$PASSWORD" \
  -rfc \
  -file "$CA_CERT"

# 2) Truststore shared by brokers and TLS clients. It contains only the public CA cert.
keytool -importcert \
  -alias kafka-lab-ca \
  -file "$CA_CERT" \
  -keystore "$TRUSTSTORE" \
  -storetype PKCS12 \
  -storepass "$PASSWORD" \
  -noprompt

create_broker_certificate() {
  local broker="$1"
  local keystore="$SECRETS_DIR/${broker}.keystore.p12"
  local csr="$CA_DIR/${broker}.csr"
  local signed_cert="$CA_DIR/${broker}.crt"
  local san="SAN=dns:${broker},dns:localhost,ip:127.0.0.1"

  # Private key + initial self-signed certificate.
  keytool -genkeypair \
    -alias "$broker" \
    -keyalg RSA \
    -keysize 3072 \
    -sigalg SHA256withRSA \
    -dname "CN=${broker},OU=Kafka Brokers,O=Hady Lab,L=Dubai,ST=Dubai,C=AE" \
    -ext "$san" \
    -ext "KU=digitalSignature,keyEncipherment" \
    -ext "EKU=serverAuth,clientAuth" \
    -validity "$VALIDITY_DAYS" \
    -keystore "$keystore" \
    -storetype PKCS12 \
    -storepass "$PASSWORD" \
    -keypass "$PASSWORD" \
    -noprompt

  # Certificate signing request.
  keytool -certreq \
    -alias "$broker" \
    -keystore "$keystore" \
    -storetype PKCS12 \
    -storepass "$PASSWORD" \
    -keypass "$PASSWORD" \
    -ext "$san" \
    -file "$csr"

  # Sign the broker certificate with the lab CA.
  keytool -gencert \
    -alias kafka-lab-ca \
    -keystore "$CA_KEYSTORE" \
    -storetype PKCS12 \
    -storepass "$PASSWORD" \
    -keypass "$PASSWORD" \
    -infile "$csr" \
    -outfile "$signed_cert" \
    -rfc \
    -validity "$VALIDITY_DAYS" \
    -ext "$san" \
    -ext "KU=digitalSignature,keyEncipherment" \
    -ext "EKU=serverAuth,clientAuth"

  # Import CA first, then replace initial cert with CA-signed chain.
  keytool -importcert \
    -alias kafka-lab-ca \
    -file "$CA_CERT" \
    -keystore "$keystore" \
    -storetype PKCS12 \
    -storepass "$PASSWORD" \
    -noprompt

  keytool -importcert \
    -alias "$broker" \
    -file "$signed_cert" \
    -keystore "$keystore" \
    -storetype PKCS12 \
    -storepass "$PASSWORD" \
    -noprompt
}

for broker in kafka-1 kafka-2 kafka-3; do
  create_broker_certificate "$broker"
done

cat > "$SECRETS_DIR/client-docker.properties" <<EOF_CLIENT
security.protocol=SSL
ssl.truststore.location=/etc/kafka/secrets/kafka.truststore.p12
ssl.truststore.password=$PASSWORD
ssl.truststore.type=PKCS12
ssl.endpoint.identification.algorithm=https
EOF_CLIENT

cat > "$ROOT_DIR/client/client.properties" <<EOF_CLIENT_HOST
security.protocol=SSL
ssl.truststore.location=$SECRETS_DIR/kafka.truststore.p12
ssl.truststore.password=$PASSWORD
ssl.truststore.type=PKCS12
ssl.endpoint.identification.algorithm=https
EOF_CLIENT_HOST

chmod 0444 "$SECRETS_DIR"/*
chmod 0700 "$CA_DIR"
chmod 0600 "$CA_KEYSTORE" "$CA_DIR"/*.csr "$CA_DIR"/*.crt

echo
printf 'Generated TLS material:\n'
printf '  CA certificate:       %s\n' "$CA_CERT"
printf '  Client truststore:    %s\n' "$TRUSTSTORE"
printf '  Broker keystores:     %s/{kafka-1,kafka-2,kafka-3}.keystore.p12\n' "$SECRETS_DIR"
printf '  Host client config:   %s/client/client.properties\n' "$ROOT_DIR"
printf '\nThe CA private key remains under %s and is not mounted into Kafka.\n' "$CA_DIR"
