
# Confluent REST Proxy

## Introduction

- Kafka is greate for Java based Consumer / Producer, but sometimes clients are lacking for other languages
- Although things are gettting better
- Additionally, sometimes Avro support for some languages isn't geate, whereas JSON/HTTP request are greate
 
> For all these reasones Confluent created the REST Proxy

## Confluent REST Proxy

> It's an open source project created by confluent

- It 's integrated with the schema registry so that consumers and producers can easilty read and write to acro topic

![[Pasted image 20260801145310.png]]

## Considerations


- There's a performace hit to using HTTP instead of Kafka's native protocol and its's been estimated that throughput decrease is 3-4x
- It is up to producing application to batch events
