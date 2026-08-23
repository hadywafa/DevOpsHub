# Summary

This incident gives you a very useful TLS troubleshooting model. The main lesson is: **not every `SSLHandshakeException` is a certificate trust problem**.

## What actually happened

Your Java 25 client connected to:

```text
b2ba.etisalat.corp.ae:443
```

and sent a valid TLS `ClientHello`.

The server/F5 immediately returned:

```text
fatal alert: handshake_failure
```

before sending:

```text
ServerHello
Certificate
```

So Java never reached certificate validation.

The real problem was:

```text
Java 25
   ↓
offers modern ECDHE cipher suites
   ↓
F5 did not support/allow them
   ↓
no common cipher
   ↓
handshake_failure
```

After the F5 team enabled:

```text
ECDHE-RSA-AES128-GCM-SHA256
```

Java 25 could negotiate successfully.

---

## The TLS handshake you should remember

Simplified:

```text
Client                           Server/F5

ClientHello
- TLS versions
- cipher suites
- SNI hostname
        ----------------------->

                                choose:
                                - TLS version
                                - cipher
                                - certificate

        <-----------------------
ServerHello
Certificate
...

Java validates certificate
        ↓
Finished
```

This gives you two very different failure areas.

### Failure before `ServerHello`

Example:

```text
ClientHello
     ↓
handshake_failure
```

Think:

```text
TLS version
cipher suites
F5 SSL profile
SNI
TLS policy
```

**Not truststore first.**

### Failure after `Certificate`

Example:

```text
ServerHello
Certificate
    ↓
PKIX path building failed
```

Think:

```text
root CA
intermediate CA
truststore
hostname/SAN
certificate expiry
```

---

## The most useful error distinction

Memorize these:

| Error                                             | First thing to suspect               |
| ------------------------------------------------- | ------------------------------------ |
| `PKIX path building failed`                       | Java truststore / CA chain           |
| `unable to find valid certification path`         | Java truststore                      |
| `No subject alternative DNS name`                 | Hostname mismatch                    |
| `certificate_expired`                             | Certificate validity                 |
| `protocol_version`                                | TLS version mismatch                 |
| `handshake_failure` immediately after ClientHello | Cipher / TLS/F5 policy               |
| `certificate_required`                            | mTLS / client certificate            |
| `bad_certificate`                                 | Client/server rejected a certificate |
| `Connection refused`                              | Network/service/port                 |
| `UnknownHostException`                            | DNS                                  |

---

## What curl taught us

This command succeeded:

```bash
curl -v \
  --tlsv1.2 \
  --tls-max 1.2 \
  https://b2ba.etisalat.corp.ae
```

and showed:

```text
SSL connection using TLSv1.2 / AES128-GCM-SHA256
SSL certificate verify ok
```

That proved several things at once:

```text
DNS                  ✅
TCP connectivity     ✅
TLS 1.2              ✅
certificate valid    ✅
OS trust             ✅
endpoint reachable   ✅
```

Then this failed:

```bash
curl -v \
  --tlsv1.2 \
  --tls-max 1.2 \
  --ciphers ECDHE-RSA-AES128-GCM-SHA256 \
  https://b2ba.etisalat.corp.ae
```

That was the key test.

It proved:

```text
F5 accepts:
AES128-GCM-SHA256

F5 rejects:
ECDHE-RSA-AES128-GCM-SHA256
```

So the bottleneck was the **F5 cipher configuration**, not certificates.

---

## Why Java 21 worked and Java 25 failed

This is another strong lesson:

> Never assume two Java versions have the same TLS defaults.

Older Java versions may still allow older cipher suites that newer Java security policies disable.

So:

```text
Java 21
   ↓
old cipher available
   ↓
F5 accepts
   ↓
works
```

while:

```text
Java 25
   ↓
old cipher disabled
   ↓
only modern suites offered
   ↓
F5 had none in common
   ↓
fails
```

This is why a Java upgrade can suddenly expose an old F5/server TLS configuration.

---

## Certificate lesson from the same incident

You also learned this distinction:

```text
Leaf:
CN=b2ba.etisalat.corp.ae
        ↓
Issuer:
SHA2-ICA01
        ↓
Root:
SHA2-ROOT
```

Normally Java only needs the CA trust chain:

```text
SHA2-ICA01
SHA2-ROOT
```

The leaf does not normally need to be explicitly stored as a trusted certificate.

And your truststore already contained the root/intermediate fingerprints, so that part was valid.

---

## Your troubleshooting order from now on

For any Java HTTPS failure, use this order:

```text
1. Can I resolve/connect?
        ↓
2. curl -v URL
        ↓
3. What TLS version/cipher succeeds?
        ↓
4. Java SSL debug
        ↓
5. Did failure happen BEFORE or AFTER server certificate?
```

Then branch:

```text
BEFORE certificate
→ TLS / cipher / F5 / SNI

AFTER certificate
→ truststore / CA / hostname
```

This single distinction will save you a lot of time.

## The one sentence to remember

> **`SSLHandshakeException` is only a category. The position where the handshake fails tells you the real problem.**

In your incident:

```text
ClientHello
   ↓
fatal handshake_failure
```

therefore:

> **cipher/TLS negotiation problem, not certificate trust.**
