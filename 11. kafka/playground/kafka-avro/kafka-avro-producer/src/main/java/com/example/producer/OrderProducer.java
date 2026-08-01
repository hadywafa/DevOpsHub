package com.example.producer;

import com.example.events.OrderCreated;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.List;
import java.util.Properties;

public final class OrderProducer {

    private static final String TOPIC = env("KAFKA_TOPIC", "orders-avro");

    private OrderProducer() {
    }

    public static void main(String[] args) throws Exception {
        Properties config = new Properties();
        config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
                env("KAFKA_BOOTSTRAP_SERVERS", "localhost:29092"));
        config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class.getName());
        config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                KafkaAvroSerializer.class.getName());
        config.put("schema.registry.url",
                env("SCHEMA_REGISTRY_URL", "http://localhost:8081"));

        // Explicit for the lab. The serializer registers a new schema automatically.
        config.put("auto.register.schemas", true);
        config.put(ProducerConfig.ACKS_CONFIG, "all");

        List<OrderCreated> orders = List.of(
                newOrder("ORD-1001", 250.00, "AED"),
                newOrder("ORD-1002", 410.50, "USD"),
                newOrder("ORD-1003", 99.99, "AED")
        );

        try (KafkaProducer<String, OrderCreated> producer = new KafkaProducer<>(config)) {
            for (OrderCreated order : orders) {
                String key = order.getOrderId().toString();
                ProducerRecord<String, OrderCreated> record =
                        new ProducerRecord<>(TOPIC, key, order);

                RecordMetadata metadata = producer.send(record).get();

                System.out.printf(
                        "Produced key=%s amount=%.2f %s -> partition=%d offset=%d%n",
                        key,
                        order.getAmount(),
                        order.getCurrency(),
                        metadata.partition(),
                        metadata.offset()
                );
            }
        }
    }

    private static OrderCreated newOrder(String orderId, double amount, String currency) {
        return OrderCreated.newBuilder()
                .setOrderId(orderId)
                .setAmount(amount)
                .setCurrency(currency)
                .build();
    }

    private static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
