بص، من وجهة نظري دي من أحسن الفرص اللي جاتلك في دبي لو هدفك تشتغل في **Product Company** قوية وتبعد عن شغل الـ outsourcing والـ enterprise التقليدي.

الوظيفة دي مش DevOps عادي، دي أقرب لـ:

> **Senior Platform Engineer + SRE + Cloud Architect + Infrastructure Engineer**

وده اتجاه السوق العالمي حالياً.

---

# الأول: الشركة بتعمل إيه؟

تخيل معايا السيناريو ده.

## أنت بنك زي Emirates NBD

العملاء بتوعك عايزين يشتروا Bitcoin أو USDC.

هل البنك هيبني:

- Exchange
- Wallet
- Trading Engine
- Liquidity
- Blockchain integration
- Settlement
- Risk
- Compliance

من الصفر؟

مستحيل.

فيجيب شركة زي **Aquanow**.

يعني البنك يقول:

> "أنا عايز أضيف Crypto Trading في الأبلكيشن بتاعي."

Aquanow ترد:

> "خلاص، عندنا APIs وبنية تحتية كاملة."

فالعميل يفتح Liv X مثلاً...

يضغط Buy Bitcoin...

هو فاكر إنه بيتعامل مع البنك.

لكن تحت الكواليس Aquanow هي اللي شغالة.

---

# يعني إيه Trading؟

دي أهم حاجة تفهمها قبل الإنترفيو.

Trading يعني:

شراء وبيع Assets.

مثلاً

أنا عايز أشتري Bitcoin.

فيه شخص تاني عايز يبيع.

يبقى لازم يحصل:

Buyer  
↓

Exchange

↓

Seller

لكن الحقيقة أعقد بكتير.

لازم يحصل:

- Matching
- Price Discovery
- Liquidity
- Settlement
- Risk Check
- Compliance
- Wallet Update

كل ده في أجزاء من الثانية.

---

# يعني إيه Liquidity؟

دي كلمة هتسمعها كتير.

تخيل فيه عربية BMW.

لو مفيش حد يبيعها...

يبقى حتى لو معاك فلوس مش هتعرف تشتري.

يبقى السوق مفيهوش Liquidity.

أما لو فيه آلاف ناس بتبيع وبتشتري...

أي Order بيتنفذ فوراً.

ده اسمه High Liquidity.

Aquanow بتوفر السيولة دي.

---

# يعني إيه Order؟

أنا مثلاً:

عايز أشتري

1 BTC

بسعر

100000$

دي اسمها

Buy Order

واحد تاني يقول

أنا هبيع

1 BTC

100000$

يبقى حصل Match.

---

# Trading Platform

دي عبارة عن سيستم ضخم جداً.

فيه:

API

↓

Risk Engine

↓

Order Book

↓

Matching Engine

↓

Kafka

↓

Settlement

↓

Wallet

↓

Database

↓

Notification

كل خطوة دي Service.

---

# ليه Kafka مهم جداً؟

تخيل عندك مليون Trade في الدقيقة.

كل Trade عبارة عن Event.

مثلاً

Customer Bought BTC

↓

Kafka Topic

↓

Settlement Service

↓

Notification Service

↓

Analytics

↓

Audit

↓

Risk Engine

كل Service تقرأ نفس الـ Event.

علشان كده هم كاتبين:

> **The broker is the product**

يعني Kafka بالنسبة لهم قلب الشركة.

---

# يعني إيه Settlement؟

بعد ما اشتريت Bitcoin.

لازم:

تخصم الفلوس

↓

تضيف BTC

↓

تحدث الرصيد

↓

تسجل العملية

↓

تبلغ البنك

↓

تبلغ الـ Ledger

كل ده اسمه Settlement.

---

# يعني إيه Custody؟

لو اشتريت Bitcoin.

هيتخزن فين؟

لازم يبقى فيه Wallet آمنة جداً.

دي اسمها Custody.

وده جزء مهم جداً في الشركات المالية.

---

# ليه Availability مهمة؟

البورصة شغالة

24/7

لو السيستم وقع دقيقة واحدة...

ممكن يخسروا ملايين.

علشان كده هم مركزين على:

SRE

Observability

Reliability

Incident Response

SLO

Error Budget

---

# ليه كل الكلام ده يهمك؟

لأن وظيفتك هتبقى مسؤولة عن إن المنصة متقعش.

يعني:

Terraform

↓

يبني Infrastructure

↓

EKS

↓

يشغل Kubernetes

↓

Kafka

↓

يشغل Events

↓

Monitoring

↓

Prometheus

↓

Grafana

↓

Tracing

↓

Alerting

↓

CI/CD

↓

Deployment

كل ده مسئوليتك.

---

# هل أنت مناسب؟

أنا شايف إنك مناسب بنسبة كويسة جداً.

عندك بالفعل:

✅ Kubernetes

✅ Helm

✅ CI/CD

✅ Terraform

✅ AKS

✅ Azure

✅ Docker

✅ Linux

✅ Prometheus

✅ Grafana

✅ Loki

✅ Tempo

✅ Troubleshooting

ودي كلها نقاط قوية.

---

## أكبر نقطة ضعف

بصراحة؟

Kafka.

خصوصاً

Confluent Platform

و

Confluent for Kubernetes (CFK)

هم باين جداً من الـ JD إن عندهم Kafka هو قلب الشركة.

---

# المرتب المتوقع

للأسف مفيش Salary منشور للوظيفة نفسها.

والموجود على Glassdoor بعنوان "Operational Excellence Engineer" غير معبر عن الدور ده لأنه بيتكلم عن وظائف مختلفة وببيانات قليلة جداً. ([Glassdoor](https://www.glassdoor.com/Salaries/dubai-operational-excellence-engineer-salary-SRCH_IL.0%2C5_IM954_KO6%2C37.htm?utm_source=chatgpt.com 'Salary: Operational Excellence Engineer in Dubai, United ...'))

بناءً على:

- مستوى الوظيفة
- إنها Product Company
- FinTech
- Crypto
- Senior
- دبي
- مسؤولية Architecture + SRE + AWS + Kubernetes

أنا أتوقع:

| المستوى                |           المرتب الشهري |
| ---------------------- | ----------------------: |
| Minimum                |             **28k AED** |
| المتوقع                |       **35k - 45k AED** |
| لو عندك Kafka قوي جداً |       **45k - 55k AED** |
| لو Lead فعلاً          | **قد يصل إلى 60k AED+** |

وده متوافق مع رواتب شركات الـ FinTech والـ Crypto في دبي أكتر من متوسط وظائف الـ Operations التقليدية. كما أن بيانات الرواتب المتاحة علنًا لـ Aquanow نفسها قليلة جدًا، لكن رواتب مهندسي البرمجيات لديهم تشير إلى أنهم يدفعون بمستوى منافس. ([Levels.fyi](https://www.levels.fyi/companies/aquanow/salaries?utm_source=chatgpt.com 'Aquanow Salaries'))

لو سألوك توقعاتك في الإنترفيو، أنا كنت هقول:

> **40k AED base** مع openness حسب الـ total compensation.

---

# تذاكر إيه؟

## الأولوية رقم 1 (مهم جداً)

## Kafka

ذاكر:

- Producer
- Consumer
- Topic
- Partition
- Offset
- Consumer Group
- Replication
- ISR
- Leader
- Follower
- Consumer Lag
- Retention
- Schema Registry
- Kafka Connect

أفضل مصدر:

- Confluent Fundamentals
- Confluent Documentation

---

## الأولوية رقم 2

AWS

ركز على:

- VPC
- Transit Gateway
- PrivateLink
- Security Groups
- NACL
- Route53
- ALB
- NLB
- IAM
- Organizations
- SCP
- Multi Account
- Landing Zone
- EKS

---

## الأولوية رقم 3

EKS

خصوصاً:

- IRSA (IAM Roles for Service Accounts)
- Karpenter
- Cluster Autoscaler
- Managed Node Groups
- EKS Upgrade
- CNI
- Pod Identity
- RBAC
- Network Policy

---

## الأولوية رقم 4

Terraform

ذاكر:

- Module Design
- Remote State
- Backend
- Terragrunt
- Drift Detection
- Checkov
- TFLint
- Terratest

---

## الأولوية رقم 5

Observability

ذاكر:

- Prometheus
- PromQL
- Grafana
- Loki
- Tempo
- OpenTelemetry
- SLI
- SLO
- Error Budget
- Burn Rate Alert

---

# أفضل المصادر

لو معاك يومين أو ثلاثة فقط:

### 1. YouTube

ابحث عن:

- Confluent Kafka Full Course
- TechWorld with Nana - Kafka
- TechWorld with Nana - EKS
- TechWorld with Nana - Terraform
- TechWorld with Nana - Prometheus

---

### 2. Documentation

- Apache Kafka Documentation
- Confluent Documentation
- AWS EKS Documentation
- Terraform Documentation

اقرأ الـ Concepts فقط، مش لازم تغوص في كل التفاصيل.

---

## لو معاك وقت قليل جداً

أنا هرتبهم بالشكل ده:

1. Kafka (6 ساعات)
2. EKS (3 ساعات)
3. AWS Networking (3 ساعات)
4. Terraform + Terragrunt (3 ساعات)
5. SRE + SLO + Error Budget (ساعتين)

---

### بما إني عارف خبرتك، أعتقد لو حضرت **Kafka بشكل جيد** وراجعت **AWS Networking وEKS**، هتبقى داخل الإنترفيو وأنت مغطّي حوالي **85–90%** من المتطلبات التقنية، لأن باقي الجوانب (Kubernetes، CI/CD، Helm، Troubleshooting، Observability) عندك فيها خبرة عملية قوية بالفعل.
