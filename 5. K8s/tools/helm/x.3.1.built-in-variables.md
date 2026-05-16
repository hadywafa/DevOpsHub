# 🔡 **Built-in Variables in Helm**

Helm provides a set of **built-in** objects and variables that you can use within your chart templates to access metadata, configuration values, and other contextual information. Understanding these built-in variables is essential for creating dynamic and flexible Helm charts. Below is a comprehensive overview of Helm's built-in variables, their properties, and examples of how to use them in your templates.

## 📋 **Table of Contents**

1. [📌 `.Chart`](#1)
2. [📌 `.Release`](#2)
3. [📌 `.Values`](#3)
4. [📌 `.Capabilities`](#4)
5. [📌 `.Files`](#5)
6. [📌 `.Env`](#6)
7. [📌 `.Template`](#7)
8. [📌 `.Capabilities.KubeVersion`](#8)
9. [📌 `.Template.BasePath`](#9)
10. [📌 `.Chart.AppVersion`](#10)
11. [📌 `.Values` vs `.Chart` vs `.Release`](#11)
12. [📌 Functions Provided by Sprig](#12)
13. [📝 Examples of Using Built-in Variables](#13)
14. [✅ Best Practices](#14)
15. [🏁 Conclusion](#15)

## 📌 `.Chart` <a id="1"> </a>

Represents the information about the chart itself. It contains metadata defined in the `Chart.yaml` file.

### Properties

- **`.Chart.Name`**: The name of the chart.
- **`.Chart.Version`**: The version of the chart.
- **`.Chart.AppVersion`**: The version of the application enclosed within the chart.
- **`.Chart.Description`**: A description of the chart.
- **`.Chart.Keywords`**: Keywords associated with the chart.
- **`.Chart.Home`**: The home URL of the chart.
- **`.Chart.Sources`**: URLs to the source code of the chart.
- **`.Chart.Icon`**: The URL to an icon file for the chart.
- **`.Chart.Keywords`**: Keywords for the chart.

### Example Usage

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-config
data:
  app-version: {{ .Chart.AppVersion }}
```

## 📌 `.Release` <a id="2"> </a>

Contains information about the current release of the chart. A release is a specific instance of a chart running in a Kubernetes cluster.

### Properties

- **`.Release.Name`**: The name of the release.
- **`.Release.Namespace`**: The namespace into which the release is deployed.
- **`.Release.IsInstall`**: `true` if the current action is an install.
- **`.Release.IsUpgrade`**: `true` if the current action is an upgrade.
- **`.Release.Service`**: The Helm service managing the release.
- **`.Release.Revision`**: The current revision number of the release.
- **`.Release.Time`**: The time when the release was created or modified.

### Example Usage

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Release.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
```

## 📌 `.Values` <a id="3"> </a>

Holds the configuration values provided by the user, typically defined in the `values.yaml` file or via the `--set` flag during installation.

### Usage

- Accessing values: `{{ .Values.key }}` or `{{ .Values.nested.key }}`

### Example `values.yaml`

```yaml
replicaCount: 2
image:
  repository: nginx
  tag: "1.18"
```

### Example Usage in Template

```yaml
replicas: { { .Values.replicaCount } }
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

## 📌 `.Capabilities` <a id="4"> </a>

Provides information about the Kubernetes cluster and the Helm client’s capabilities. It's useful for conditional logic based on Kubernetes API versions or features.

### Properties

- **`.Capabilities.KubeVersion`**: Details about the Kubernetes version.
  - **`.Capabilities.KubeVersion.Major`**: Major version number.
  - **`.Capabilities.KubeVersion.Minor`**: Minor version number.
- **`.Capabilities.APIVersions`**: Lists the API versions supported by the cluster.
- **`.Capabilities.HelmVersion`**: Information about the Helm client version.

### Example Usage

```yaml
{{- if semverCompare ">=1.16-0" .Capabilities.KubeVersion.GitVersion }}
apiVersion: apps/v1
{{- else }}
apiVersion: extensions/v1beta1
{{- end }}
```

## 📌 `.Files` <a id="5"> </a>

Allows access to files in the chart package. Useful for embedding configuration files, scripts, or other resources.

### Properties

- **`.Files.Get`**: Retrieves the content of a specified file.
- **`.Files.Glob`**: Returns a list of files matching a pattern.

### Example Usage

Assuming you have a file `config.yaml` in the `files/` directory:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  config.yaml: |
    {{ .Files.Get "files/config.yaml" | indent 4 }}
```

## 📌 `.Env` <a id="6"> </a>

Provides access to environment variables from the system where Helm is running.

### Example Usage

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
data:
  HOME: { { .Env.HOME } }
  USER: { { .Env.USER } }
```

**Note:** Use `.Env` cautiously, as it can expose sensitive information from the system environment.

## 📌 `.Template` <a id="7"> </a>

Contains functions and properties related to the template rendering process.

### Properties & Functions

- **`.Template.BasePath`**: The base path of the current template file.
- **`.Template.Name`**: The name of the current template.
- **`.Template.Root`**: Access to the root context of the template.

### Example Usage

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  base-path: {{ .Template.BasePath }}
  template-name: {{ .Template.Name }}
```

## 📌 `.Capabilities.KubeVersion` <a id="8"> </a>

Provides detailed information about the Kubernetes version, useful for conditional resource definitions.

### Properties

- **`.Capabilities.KubeVersion.Major`**: Major version number (e.g., "1").
- **`.Capabilities.KubeVersion.Minor`**: Minor version number (e.g., "18").
- **`.Capabilities.KubeVersion.GitVersion`**: Full version string (e.g., "v1.18.0").

### Example Usage

```yaml
{{- if or (semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion) }}
apiVersion: apps/v1
{{- else }}
apiVersion: extensions/v1beta1
{{- end }}
```

## 📌 `.Template.BasePath` <a id="9"> </a>

Represents the base path of the current template, useful for referencing other templates or files relative to the current one.

### Example Usage

```yaml
# Inside a helper template
{{ define "mychart.fullname" }}
{{ .Release.Name }}-{{ .Chart.Name }}
{{ end }}
```

```yaml
# Referencing the helper in another template
metadata:
  name: { { template "mychart.fullname" . } }
```

## 📌 `.Chart.AppVersion` <a id="10"> </a>

Specifies the version of the application that the chart is deploying. It's defined in the `Chart.yaml` file and can be different from the chart's version.

### Example `Chart.yaml`

```yaml
apiVersion: v2
name: mychart
version: 0.1.0
appVersion: "1.0.0"
```

### Example Usage in Template

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-config
data:
  app-version: {{ .Chart.AppVersion }}
```

## 📌 `.Values` vs `.Chart` vs `.Release` <a id="11"> </a>

Understanding the differences between these three is crucial for effective Helm chart templating.

| Variable   | Description                                       | Example Usage                                     |
| ---------- | ------------------------------------------------- | ------------------------------------------------- |
| `.Values`  | User-defined values from `values.yaml` or `--set` | `{{ .Values.replicaCount }}`                      |
| `.Chart`   | Metadata about the chart from `Chart.yaml`        | `{{ .Chart.Name }}`, `{{ .Chart.Version }}`       |
| `.Release` | Information about the current release             | `{{ .Release.Name }}`, `{{ .Release.Namespace }}` |

## 📌 **Functions Provided by Sprig** <a id="12"> </a>

- **`default`**: Provides a default value if the specified value is not set.

  ```yaml
  replicas: { { .Values.replicaCount | default 1 } }
  ```

- **`required`**: Ensures that a value is provided, otherwise the template rendering will fail.

  ```yaml
  image: "{{ required "A valid image is required!" .Values.image.repository }}:{{ .Values.image.tag }}"
  ```

- **`toYaml`**: Converts a structure to YAML format.

  ```yaml
  { { .Values.someList | toYaml } }
  ```

- **`include` and `template`**: Used to include and render other templates or helper functions.

  ```yaml
  metadata:
    name: { { include "mychart.fullname" . } }
  ```

- **`required`**: Makes sure that a value is provided.

  ```yaml
  image: "{{ required "An image is required" .Values.image.repository }}:{{ .Values.image.tag }}"
  ```

For a comprehensive list of available functions, refer to the [Sprig documentation](http://masterminds.github.io/sprig/).

---

## 📝 **Examples of Using Built-in Variables** <a id="13"> </a>

### 1. **Dynamic Naming with `.Release.Name`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Release.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
```

### 2. **Conditional Resource Creation with `.Capabilities`**

```yaml
{{- if .Capabilities.KubeVersion.GitVersion | semverCompare ">=1.16-0" }}
apiVersion: apps/v1
kind: Deployment
# Deployment spec for Kubernetes 1.16+
{{- else }}
apiVersion: extensions/v1beta1
kind: Deployment
# Deployment spec for older Kubernetes versions
{{- end }}
```

### 3. **Embedding File Contents with `.Files`**

Assuming you have a file `templates/config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  config.yaml: |
    {{ .Files.Get "files/config.yaml" | indent 4 }}
```

#### 4. **Using Environment Variables with `.Env`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
data:
  HOME: { { .Env.HOME } }
  USER: { { .Env.USER } }
```

## ✅ **Best Practices** <a id="14"> </a>

1. **Leverage Built-in Variables for Consistency**

   - Use `.Release.Name` and `.Release.Namespace` to ensure resource names are unique and scoped correctly.

2. **Use `.Values` for Configurability**

   - Keep your templates flexible by defining configurable parameters in `values.yaml`. Avoid hardcoding values.

3. **Utilize `.Capabilities` for Compatibility**

   - Implement conditional logic based on Kubernetes versions or features to maintain compatibility across different environments.

4. **Secure Usage of `.Env` and `.Files`**

   - Be cautious when exposing environment variables or file contents to avoid leaking sensitive information.

5. **Organize Templates with Helpers**

   - Use helper templates (defined using `{{ define "helper.name" }}`) to DRY (Don't Repeat Yourself) up your templates and manage complex logic.

6. **Document Your Values and Templates**

   - Clearly document the purpose of each value in `values.yaml` and the usage of built-in variables within your templates for better maintainability.

7. **Keep Templates Clean and Readable**
   - Use indentation and comments to make your templates easy to read and understand.

## 🏁 **Conclusion** <a id="15"> </a>

Helm's built-in variables provide a powerful and flexible way to create dynamic Kubernetes manifests. By leveraging these variables effectively, you can create charts that are both reusable and adaptable to various environments and requirements. Always refer to the [official Helm documentation](https://helm.sh/docs/chart_template_guide/builtin_objects/) for the most up-to-date and detailed information on built-in objects and their usage.
