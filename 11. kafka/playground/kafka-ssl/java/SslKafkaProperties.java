package com.hady.kafka;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.common.config.SslConfigs;

import java.nio.file.Path;
import java.util.Properties;

public final class SslKafkaProperties {

    private SslKafkaProperties() {
    }

    public static void addTls(Properties properties) {
        String truststore = System.getenv().getOrDefault(
                "KAFKA_TRUSTSTORE",
                "../kafka-ssl-lab/secrets/kafka.truststore.p12"
        );

        String password = System.getenv().getOrDefault(
                "KAFKA_SSL_PASSWORD",
                "changeit"
        );

        properties.setProperty(
                CommonClientConfigs.SECURITY_PROTOCOL_CONFIG,
                "SSL"
        );

        properties.setProperty(
                SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG,
                Path.of(truststore)
                        .toAbsolutePath()
                        .normalize()
                        .toString()
        );

        properties.setProperty(
                SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG,
                password
        );

        properties.setProperty(
                SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG,
                "PKCS12"
        );

        properties.setProperty(
                SslConfigs.SSL_ENDPOINT_IDENTIFICATION_ALGORITHM_CONFIG,
                "https"
        );
    }
}
