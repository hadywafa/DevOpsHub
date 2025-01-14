# Custom Resource Definition (CDR)

## **Table of Contents (T.O.C)**

1. **Introduction to CRDs**
2. **When to Use CRDs**
3. **Structure of a CRD**
4. **Defining Properties in CRDs**
   - Specifying Schema with OpenAPI v3
   - Example YAML Schema Definition
5. **Creating a New Custom Resource Definition (CRD)**
   - Step-by-Step Guide
   - Example YAML for CRD
   - Applying the CRD
6. **Retrieving an Existing CRD and Its Properties**
   - Inspecting an Existing CRD
   - Viewing Schema and Properties
7. **Creating a Resource from an Existing CRD**
   - Example Resource Creation
   - Applying the Custom Resource
8. **Validation and Schema Definition in CRDs**
9. **Versioning CRDs**
10. **Advanced CRD Features**

- Subresources
- Additional Printer Columns

11. **CRDs and Operators**
12. **CRD Lifecycle Management**
13. **Best Practices for CRDs**
14. **Troubleshooting CRDs**
15. **CRD Limitations and Future Enhancements**
16. **Practical Examples and Use Cases**

---

## **Detailed Content**

---

### **1. Introduction to CRDs**

- **What are CRDs?** Custom resources extend Kubernetes with new resource types.
- **Why use CRDs?** Introduce domain-specific objects (e.g., `Database`, `CanaryRelease`).

---

### **2. When to Use CRDs**

- Use when standard resources (e.g., ConfigMaps) are insufficient.
- **Examples:** Automating database creation or canary deployments.

---

### **3. Structure of a CRD**

A CRD consists of the following key elements:

- **API Version:** `apiextensions.k8s.io/v1`
- **Group, Version, and Scope:** Organize resources logically
- **Names:** Singular, Plural, Kind, Short Names  
  Example:
  ```yaml
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
      - db
  ```

---

### **4. Defining Properties in CRDs**

To enforce structure and validation, CRDs can define a schema using **OpenAPI v3**.

#### **Example Schema Definition for CRD:**

```yaml
schema:
  openAPIV3Schema:
    type: object
    properties:
      spec:
        type: object
        properties:
          engine:
            type: string
          version:
            type: string
            pattern: "^\\d+\\.\\d+$"
```

- **OpenAPI Schema** ensures that users create valid resources.
- **Spec fields** define custom settings, such as the `engine` and `version` in the example.

---

### **5. Creating a New Custom Resource Definition (CRD)**

#### **Step-by-Step Guide to Create a CRD:**

1. **Define the CRD YAML**:

   ```yaml
   apiVersion: apiextensions.k8s.io/v1
   kind: CustomResourceDefinition
   metadata:
     name: databases.example.com
   spec:
     group: example.com
     versions:
       - name: v1
         served: true
         storage: true
         schema:
           openAPIV3Schema:
             type: object
             properties:
               spec:
                 type: object
                 properties:
                   engine:
                     type: string
                   version:
                     type: string
     scope: Namespaced
     names:
       plural: databases
       singular: database
       kind: Database
       shortNames:
         - db
   ```

2. **Apply the CRD**:

   ```bash
   kubectl apply -f database-crd.yaml
   ```

3. **Verify the CRD**:
   ```bash
   kubectl get crds
   kubectl describe crd databases.example.com
   ```

---

### **6. Retrieving an Existing CRD and Its Properties**

1. **List all CRDs**:

   ```bash
   kubectl get crds
   ```

2. **View Details of a Specific CRD**:

   ```bash
   kubectl describe crd <crd-name>
   ```

3. **Inspect the Schema of a CRD**:
   ```bash
   kubectl get crd <crd-name> -o yaml
   ```
   - Check for `spec.schema.openAPIV3Schema` to identify required properties.

---

### **7. Creating a Resource from an Existing CRD**

1. **Inspect the CRD to Identify Required Fields** (from the schema).  
   Example properties: `engine` and `version`.

2. **Create a Custom Resource**:

   ```yaml
   apiVersion: example.com/v1
   kind: Database
   metadata:
     name: my-database
   spec:
     engine: postgres
     version: "13"
   ```

3. **Apply the Resource**:

   ```bash
   kubectl apply -f my-database.yaml
   ```

4. **Verify the Resource**:
   ```bash
   kubectl get databases
   kubectl describe database my-database
   ```

---

### **8. Validation and Schema Definition in CRDs**

- Use **OpenAPI v3 schema** to validate input.
- Example schema with validation:
  ```yaml
  schema:
    openAPIV3Schema:
      type: object
      properties:
        spec:
          type: object
          properties:
            engine:
              type: string
              enum:
                - postgres
                - mysql
            version:
              type: string
              pattern: "^\\d+\\.\\d+$"
  ```

---

### **9. Versioning CRDs**

- Support multiple versions: `v1alpha1`, `v1beta1`, `v1`.
- Deprecate older versions gracefully.

---

### **10. Advanced CRD Features**

1. **Subresources**:

   ```yaml
   subresources:
     status: {}
     scale:
       specReplicasPath: .spec.replicas
       statusReplicasPath: .status.replicas
   ```

2. **Additional Printer Columns**:
   ```yaml
   additionalPrinterColumns:
     - name: Engine
       type: string
       jsonPath: .spec.engine
   ```

---

### **11. CRDs and Operators**

- Operators manage CRDs and automate resource management.
- Example: Postgres Operator manages `Database` CRD instances.

---

### **12. CRD Lifecycle Management**

1. **Update a CRD**:

   ```bash
   kubectl apply -f updated-crd.yaml
   ```

2. **Delete a CRD**:
   ```bash
   kubectl delete crd <crd-name>
   ```

---

### **13. Best Practices for CRDs**

- Use meaningful naming conventions.
- Validate input with schemas.
- Ensure backward compatibility when updating CRDs.

---

### **14. Troubleshooting CRDs**

1. **Check CRD status**:

   ```bash
   kubectl describe crd <crd-name>
   ```

2. **Inspect the logs of the operator/controller** managing the CRD.

---

### **15. CRD Limitations and Future Enhancements**

- Resource size limitations.
- Performance considerations for large objects.

---

### **16. Practical Examples and Use Cases**

- **Database Operator CRD**: Automate database lifecycle.
- **Canary Release CRD**: Manage gradual deployments.
- **Alert Rules CRD**: Define Prometheus alerting rules.

---

This version provides a **clear structure** on what you need to know to **create and manage CRDs** effectively. It emphasizes:

- How to **define properties**.
- How to **retrieve existing CRDs** and their **schemas**.
- How to **create resources** based on CRDs.

Let me know if you need further customization!
