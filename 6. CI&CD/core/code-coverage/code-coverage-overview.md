# ✅ What Is Code Coverage?

**Code coverage** measures how much of your source code is executed during automated tests. It helps answer:

> “Are my tests actually exercising the logic I’ve written?”

**Example:**
If you have 100 lines of code and your tests run through 80 of them, your coverage is **80%**.

---

## 🧪 Is Code Coverage Used in Testing?

**Yes — heavily.** It’s a **testing metric**, not a test itself. It’s used to:

- Identify **untested paths** (e.g., error handling, edge cases)
- Improve **test completeness**
- Catch **dead code** or unreachable logic

**Common tools:**

| Language   | Coverage Tool               |
| ---------- | --------------------------- |
| Python     | `coverage.py`, `pytest-cov` |
| Java       | `JaCoCo`, `Cobertura`       |
| JavaScript | `nyc`, `Jest`               |
| Go         | Built-in `go test -cover`   |

---

## 🔁 Where Does It Fit in CI/CD?

In CI/CD pipelines, code coverage is used to **automate quality gates**:

**Typical Flow:**

```yaml
# GitHub Actions example
- name: Run tests with coverage
  run: pytest --cov=my_app

- name: Upload coverage report
  uses: actions/upload-artifact

- name: Enforce coverage threshold
  run: coverage report --fail-under=85
```

**Benefits in CI/CD:**

- Prevents merging code with low test coverage
- Tracks coverage trends over time
- Integrates with dashboards (e.g., SonarQube, Codecov)

---

## 🧠 Strategic Use

For someone like you — focused on reproducibility and team impact — coverage can:

- Validate onboarding test suites
- Highlight risky modules (low coverage + high churn)
- Automate compliance checks for regulated environments
