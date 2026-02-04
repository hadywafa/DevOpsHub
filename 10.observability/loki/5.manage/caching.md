# Caching in Loki

## Overview

> Loki supports two types of caching for query results and chunks to speed up query performance and reduce calls to the storage layer. Memcached is included in the Loki Helm chart and enabled by default for the `chunksCache` and `resultsCache`. This sections describes the recommended Memcached configuration to enable caching for chunks and query results.

## Reference

- [Configure caches to speed up queries](https://grafana.com/docs/loki/latest/operations/caching/)
