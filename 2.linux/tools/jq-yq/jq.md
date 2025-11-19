# jq Notes

## Example 1

Examine the /root/grype-report.json report and find the total number of Critical vulnerabilities that exist.

```bash
jq -r '[.matches[] | select(.vulnerability.severity == "Critical")] | length' /root/grype-report.json
```

---
