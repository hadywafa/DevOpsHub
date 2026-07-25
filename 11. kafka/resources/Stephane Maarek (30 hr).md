
https://www.udemy.com/user/conduktor/

## **Course order from your 8, ruthlessly prioritized** 

 you can't watch all of these in 4 days _and_ do hands-on, so the spine is 1–3 plus lab time; the rest is skim:

1. **Learn Apache Kafka for Beginners v3**  `8 hr` 
	- your foundation, and it's on Kafka 4.0. Run it at 1.5–2x and skip the Java producer/consumer coding sections; you're infra, not app-dev. Lock in partitions, replication/ISR, consumer groups, delivery semantics, and the CLI tools.
2. **Kafka Cluster Setup & Administration**  `4 hr` 
	- for the mental model of broker config, sizing, replication factor, and partition planning. Take the _concepts_; mentally translate its ZooKeeper setup to KRaft and don't drill the quorum mechanics.
3. **Kafka Monitoring & Operations** `5 hr` 
	- the most JD-aligned course you own: Prometheus/Grafana, consumer lag, broker health, rolling upgrades. Highest-yield ops content here.
4. **Kafka Security (SSL/SASL/ACL)** `4 hr` 
	- skim. The concepts (TLS, SASL, RBAC/ACLs) map to the JD's least-privilege emphasis, but the ACL-in-ZooKeeper mechanics are dated.
5. **Confluent Schema Registry & REST Proxy** `4 hr` 
	-  concept-level. The JD names Schema Registry and schema evolution explicitly, so understand compatibility modes; you don't need every Avro lecture.
6. **Kafka Connect** `4 hr`  
	- concept-level. Know the source/sink model and why Connect pipelines and schema evolution need managing.

>  Skip **Kafka Streams** and **ksqlDB** for now — they're the app-development side of Kafka, not the infra/ops this role is about.

## **On the hands-on

this is your real edge, so spend it well.** 

- Don't replicate Maarek's manual EC2 + ZooKeeper setup; it's a dead end (ZooKeeper is gone, and Aquanow runs Kafka on EKS, not VMs). 
- Do your k3s lab with an operator instead — <mark style="background: #FFB86CA6;">Strimzi</mark> is free and fast to stand up, or go straight to <mark style="background: #FFB86CA6;">CFK</mark> to mirror Aquanow's actual stack. Then _break_ things: kill a broker and watch <mark style="background: #FFB86CA6;">ISR</mark> shrink and leader election happen; run a slow consumer and watch lag build in Grafana; change a replication factor and observe rebalancing. "I did this on my own cluster and here's what I saw" is what separates you in the technical round — far more than lecture count.

## Last thing

AWS is technical-round prep, not HR-round, so keep it light this week. Your EKS knowledge is basically your AKS knowledge with renamed parts (VPC≈VNet, and you already run AKS cold), so it'll come back fast when you actually need it.