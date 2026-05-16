# Matcher `AND`, `OR` Behavior, and what `continue` means

Here is the **exact + correct behavior** of **matchers** and **continue** in AlertmanagerConfig.

I’ll explain it simply and clearly — no confusion.

---

## ✅ **1. Are matchers “OR” or “AND”?**

Your block:

```yaml

matchers:

  - name: severity

    value: "critical"

    regex: false

  - name: namespace

    value: "(observability|b2b-bss-preprod-fe|b2b-bss-preprod-be)"

    regex: true

```

### ➜ **These matchers combine with AND logic**

Meaning:

An alert must satisfy **ALL** matchers in the list:

### ✔ severity == "critical"

### AND

### ✔ namespace matches regex "(observability|b2b-bss-preprod-fe|b2b-bss-preprod-be)"

Only alerts matching **both** conditions will go to the receiver.

This is exactly how Alertmanager’s matcher logic works — each matcher narrows the selection.

---

## ❗ **2. When does OR happen?**

**OR only happens between _routes_, not between matchers.**

Example:

```yaml

routes:

  - matchers: [ A ]

  - matchers: [ B ]

```

Alert is checked against **first route**, if not matched → next route → next...

But inside one route, matchers always use AND.

---

## ✅ **3. What does `continue: false` mean?**

This is one of the most misunderstood parts of Alertmanager routing.

### ✔ `continue: false`

> After a route matches an alert, **do NOT evaluate any more sibling routes.**  

> This route is FINAL for this alert.

This is the normal “stop here” behavior.

Equivalent to “break” in programming.

---

## 🔄 **4. What does `continue: true` mean?**

### ✔ `continue: true`

> Even if this route matches, Alertmanager will continue evaluating _the next sibling routes_.

This is used when you want **multiple receivers** to get the same alert.

But you must be very careful — if you leave `continue: true` accidentally, the alert may be sent multiple times.

---

## 🧠 **Putting it all together for your example**

```yaml

- receiver: azure-logicapp

  matchers:

    - name: severity

      value: "critical"

      regex: false

    - name: namespace

      value: "(observability|b2b-bss-preprod-fe|b2b-bss-preprod-be)"

      regex: true

  repeatInterval: 5m

  continue: false

```

### Behavior:

1.  Alert will match this route **only if**:

    \*   severity is exactly `"critical"`

    \*   namespace is one of:

        \*   observability

        \*   b2b-bss-preprod-fe

        \*   b2b-bss-preprod-be

2.  If matched:

    \*   It goes to `azure-logicapp`

    \*   It will repeat every **5 minutes**

    \*   Because `continue: false`:

        \*   Alertmanager will **stop routing here**

        \*   No other routes will be checked

        \*   No duplicate notifications

---

## 🟢 Summary Cheat Sheet

### Matchers:

\*   Inside **same route** → **AND**

\*   Between **routes** → sequential checks (like OR + priority)

### Continue:

| value             | meaning                                          |

| ----------------- | ------------------------------------------------ |

| `continue: false` | Stop routing after this route matches            |

| `continue: true`  | Continue evaluating next routes even after match |

---

## If you want, I can also:

✔ Validate your entire AlertmanagerConfig  

✔ Produce your final desired routing tree (10m vs 1h logic)  

✔ Optimize grouping  

✔ Provide a visual flow diagram of routing

Just tell me.
