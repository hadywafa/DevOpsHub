# X

## Selection

![1762341261241](image/x/1762341261241.png)

![1762345870160](image/x/1762345870160.png)

## Matchers

![1762341271625](image/x/1762341271625.png)

![1762345820260](image/x/1762345820260.png)

![1762345949444](image/x/1762345949444.png)

## modifiers

![1762346815471](image/x/1762346815471.png)

### offset modifier

![1762346844133](image/x/1762346844133.png)

![1762346924020](image/x/1762346924020.png)

![1762346945877](image/x/1762346945877.png)

---

### @ modifier

![1762346987285](image/x/1762346987285.png)

---

### offset with @ modifier

![1762347021557](image/x/1762347021557.png)

> order doesn't matter when combine @ modifier with offset modifer  
> you can combine range vector with offset modifier and @ modifier

---

## Operators

### Arithmetic Operators

![1762357650911](image/x/1762357650911.png)

![1762357923097](image/x/1762357923097.png)

### Comparison Operators

![1762357808149](image/x/1762357808149.png)

![1762357942680](image/x/1762357942680.png)

![1762357962696](image/x/1762357962696.png)

### Binary Operators Precedence

![1762358042575](image/x/1762358042575.png)

### Logical Operators

![1762358064672](image/x/1762358064672.png)

- and
  ![1762358282384](image/x/1762358282384.png)

- or
  ![1762358295083](image/x/1762358295083.png)

- unless
  ![1762358415584](image/x/1762358415584.png)

---

## vector matching

![1762358830065](image/x/1762358830065.png)

![1762358815618](image/x/1762358815618.png)

![1762358845449](image/x/1762358845449.png)

![1762358864057](image/x/1762358864057.png)

### ignore matching

![1762359444194](image/x/1762359444194.png)

![1762359482731](image/x/1762359482731.png)

![1762359516746](image/x/1762359516746.png)

![1762359570236](image/x/1762359570236.png)

---

### one to one matching

![1762504039543](image/x/1762504039543.png)

### Many to one matching

![1762359793468](image/x/1762359793468.png)

![1762359813915](image/x/1762359813915.png)

![1762359845275](image/x/1762359845275.png)

## Aggregators

![1762505912982](image/x/1762505912982.png)

### Default Behavior

![1762505931976](image/x/1762505931976.png)

### `by` clause

![1762506006928](image/x/1762506006928.png)

![1762506098601](image/x/1762506098601.png)

### `Without` clause

![1762506147207](image/x/1762506147207.png)

### Sum vs Count

![1762508179461](image/x/1762508179461.png)

🧠 **What the Question Is Asking**

You’re tasked with:

- Using the Prometheus metric `node_cpu_seconds_total`
- Counting how many **distinct CPUs** exist per instance
- Ensuring each CPU is counted **only once**
- Filtering by a single mode (`mode="idle"`) to avoid duplicates
- Saving the query to `/root/query8.txt`

---

### ✅ **Correct PromQL Query**

```promql
count(node_cpu_seconds_total{mode="idle"}) by (instance)
```

**✔ Why This Works:**

- `node_cpu_seconds_total{mode="idle"}`: Selects only idle-mode time series.
- Each CPU core has a unique `cpu` label (e.g. `cpu="0"`, `cpu="1"`, etc.).
- `count(...) by (instance)`: Counts how many distinct `cpu` label values exist per `instance`.

This gives you:

```ini
{instance="loadbalancer:9100"} → 4
{instance="webserver:9100"} → 8
```

→ Meaning: 4 CPUs on the load balancer, 8 on the web server.

---

### ❌ **Incorrect Alternative**

_`sum by(instance, cpu)(node_cpu_seconds_total{mode="idle"})`_

**🚫 Why It’s Wrong:**

- This **sums the idle time per CPU**, not the number of CPUs.
- You get values like:

  ```ini
  {instance="loadbalancer:9100", cpu="0"} → 123456.7
  {instance="loadbalancer:9100", cpu="1"} → 123789.2
  ```

- It’s useful for tracking CPU usage, but **not for counting CPUs**.

---

## Functions
