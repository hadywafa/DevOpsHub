# Mock Exam 1

## 🟡 Q1

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607449315.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟢 Q2

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607516040.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟡 Q3

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607604811.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

### ✍🏻 Answer

1. File **q3_file1.Dockerfile**

   - copies a file secret-token over (COPY secret-token .), uses it (RUN /etc/register.sh ./secret-token) and deletes it afterwards (RUN rm ./secret-token). But because of
     the way Docker works, every RUN, COPY and ADD command creates a new layer and every layer is persistet in the image.
   - This means that even if the file secret-token get's deleted, it's still included with the image.

2. File **q3_file2.yaml**

- contains plain text password under env section value: P@sSw0rd.
- Its secure practice to utilize k8s's secrets to store passwords.

echo -e "q3_file1.Dockerfile\nq3_file2.yaml" > /opt/course/security-issues.txt

---

## 🟢 Q4

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607719410.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## ❓ `Q5`

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607764980.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

### ✍🏻 Answer

For kubelet issues, run:

````bash
kube-bench --benchmark cis-1.10 --config-dir /opt/kube-bench/cfg run --targets node```
````

```bash
sudo groupadd --system etcd
sudo useradd -s /sbin/nologin --system -g etcd etcd

sudo chown -R etcd:etcd /var/lib/etcd
```

For controlplane and etcd issues, run:

```bash
kube-bench --benchmark cis-1.10 --config-dir /opt/kube-bench/cfg run --targets master
```

---

## 🟡 Q6

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607836807.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟡 Q7

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763589843874.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## ❓ `Q8`

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763591243315.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## ❓ `Q9`

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763607924590.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟢 Q10

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763608901319.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟢 Q11

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763608985476.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟢 Q12

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763609026333.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

> `securityContext:` on container level.

---

## 🟢 Q13

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763609492741.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟢 Q14

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763609541028.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>

---

## 🟢 Q15

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid">
  <img src="image/mock-1/1763609579038.png" alt="Mock Exam 1 Question 1" style="width: 60%">
</div>
