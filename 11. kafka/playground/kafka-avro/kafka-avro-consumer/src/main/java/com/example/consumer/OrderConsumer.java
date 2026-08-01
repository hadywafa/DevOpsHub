package com.example.consumer;

import com.example.events.OrderCreated;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.errors.WakeupException;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicBoolean;

public final class OrderConsumer {

    private static final String TOPIC = env("KAFKA_TOPIC", "orders-avro");

    private OrderConsumer() {
    }

    public static void main(String[] args) {
        Properties config = new Properties();
        config.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
                env("KAFKA_BOOTSTRAP_SERVERS", "localhost:29092"));
        config.put(ConsumerConfig.GROUP_ID_CONFIG,
                env("KAFKA_CONSUMER_GROUP", "orders-avro-java-consumer"));
        config.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                StringDeserializer.class.getName());
        config.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                KafkaAvroDeserializer.class.getName());
        config.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        config.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        config.put("schema.registry.url",
                env("SCHEMA_REGISTRY_URL", "http://localhost:8081"));

        // Return generated OrderCreated objects, not GenericRecord.
        config.put("specific.avro.reader", true);

        AtomicBoolean running = new AtomicBoolean(true);

        try (KafkaConsumer<String, OrderCreated> consumer = new KafkaConsumer<>(config)) {
            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                running.set(false);
                consumer.wakeup();
            }));

            consumer.subscribe(List.of(TOPIC));
            System.out.printf("Listening on topic '%s'. Press Ctrl+C to stop.%n", TOPIC);

            try {
                while (running.get()) {
                    ConsumerRecords<String, OrderCreated> records =
                            consumer.poll(Duration.ofSeconds(1));

                    for (ConsumerRecord<String, OrderCreated> record : records) {
                        OrderCreated order = record.value();

                        System.out.printf(
                                "Consumed key=%s orderId=%s amount=%.2f %s partition=%d offset=%d%n",
                                record.key(),
                                order.getOrderId(),
                                order.getAmount(),
                                order.getCurrency(),
                                record.partition(),
                                record.offset()
                        );
                    }

                    if (!records.isEmpty()) {
                        // Commit only after the records were processed successfully.
                        consumer.commitSync();
                    }
                }
            } catch (WakeupException e) {
                if (running.get()) {
                    throw e;
                }
            }
        }
    }

    private static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
