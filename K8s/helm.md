1.toYaml what we call?

The `toYaml` function in Helm templates is used to convert a given value (like a map or list) into a YAML-formatted string. This is particularly useful when you want to include complex structures in your Kubernetes manifests while maintaining proper indentation.

2. helm fetch vs helm pull, what is the difference?
The `helm fetch` command is used to download a chart from a chart repository and save it locally as a `.tgz` file. On the other hand, `helm pull` is an alias for `helm fetch` and performs the same function. Both commands can be used interchangeably to retrieve charts from repositories.

3. Why  fecth is deprecated?
The `helm fetch` command has been deprecated in favor of `helm pull` to provide a more intuitive and consistent naming convention. The term "pull" better aligns with common terminology used in other package management systems, making it clearer that the command is used to retrieve charts from a repository. As a result, users are encouraged to use `helm pull` for better clarity and consistency in their Helm workflows.

4.helm wont check rollout status for demonsets 
Helm does not check the rollout status for DaemonSets because DaemonSets are designed to ensure that a copy of a pod runs on all (or some) nodes in a Kubernetes cluster. The nature of DaemonSets means that their pods may not have a straightforward "ready" state like Deployments do. 

When Helm deploys or upgrades a DaemonSet, it does not wait for all pods to become ready before considering the release successful. This is because DaemonSets can have pods that are scheduled on nodes that may not be immediately available or may take longer to become ready due to various factors (e.g., node conditions, resource constraints).

5.Helm rollback to last suceeded release
To rollback to the last succeeded release in Helm, you can use the `helm rollback` command

helm rollback <release-name> <revision-number> what if specify revision number is 0 , it will rollback to the last succeeded release.. For example, if your release name is `my-release`, you would run:```bash
helm rollback my-release 0
```
6. --no-hooks flag in helm upgrade command
The `--no-hooks` flag in the `helm upgrade` command is used to prevent Helm from executing any hooks that are defined in the chart during the upgrade process. Hooks are special Kubernetes resources that can be triggered at specific points in the release lifecycle, such as before or after an upgrade.

When you use the `--no-hooks` flag, Helm will skip the execution of these hooks, which can be useful in certain scenarios where you want to avoid running custom logic or scripts that may be associated with the upgrade process. This can help ensure a smoother upgrade without any additional side effects from hook executions.

7.what is helm test?
`helm test` is a command used to run tests for a Helm chart. It executes the test hooks defined in the chart, which are typically Kubernetes resources designed to validate the functionality of the deployed application. These tests can include jobs or pods that perform checks to ensure that the application is working as expected after deployment.

8. helm lint what it do?
The `helm lint` command is used to analyze a Helm chart for potential issues and best practices. It checks the chart's structure, syntax, and configuration to ensure that it adheres to Helm's guidelines and conventions. The linting process helps identify common mistakes, such as missing required fields, incorrect values, or deprecated features, allowing developers to fix these issues before deploying the chart. Running `helm lint` is a good practice to ensure the quality and reliability of Helm charts.

9. helm statysus what it do?
The `helm status` command is used to display the current status of a Helm release. It provides detailed information about the release, including its name, namespace, revision number, deployment status, and the resources that were created as part of the release. This command is useful for monitoring the state of a deployed application and troubleshooting any issues that may arise. By running `helm status <release-name>`, users can quickly assess the health and configuration of their Helm-managed applications.

10. helm status different types of status
- deployed: The release is successfully deployed and running.   
- failed: The release has encountered an error during deployment or upgrade.  
- pending-install: The release is in the process of being installed.    
- pending-upgrade: The release is in the process of being upgraded.  
- pending-rollback: The release is in the process of being rolled back to a previous version.




# Helm Templating Decision Guide & Function Reference

> Quick reference for deciding what to templatize, which data structure to use, and common template functions.

---

## Table of Contents

1. [Decision Flowchart](#decision-flowchart)
2. [What to Templatize](#what-to-templatize)
3. [Data Structures Guide](#data-structures-guide)
4. [_helpers.tpl Functions](#_helperstpl-functions)
5. [Built-in Template Functions](#built-in-template-functions)
6. [Common Patterns](#common-patterns)
7. [Production values.yaml Template](#production-valuesyaml-template)

---

## Decision Flowchart

```
┌─────────────────────────────────────────────────────────┐
│              Should I templatize this field?            │
└─────────────────────────┬───────────────────────────────┘
                          │
         ┌────────────────┼────────────────┐
         ▼                ▼                ▼
    KUBERNETES        CHANGES BY        REUSED IN
    CONSTANT?         ENVIRONMENT?      MULTIPLE
    (apiVersion,      (replicas,        TEMPLATES?
     kind)            image, env)       (labels, names)
         │                │                │
         ▼                ▼                ▼
    ❌ HARDCODE      ✅ values.yaml    ✅ _helpers.tpl
                                        FUNCTION
```

---

## What to Templatize

### ❌ NEVER Templatize (Kubernetes Constants)

| Field | Reason |
|-------|--------|
| `apiVersion` | Fixed per resource type |
| `kind` | Fixed per resource type |
| `protocol: TCP` | Rarely changes |
| `spec.type` in Deployment | Always `apps/v1` |

### ✅ ALWAYS Templatize

| Field | Where | Why |
|-------|-------|-----|
| Resource `name` | `_helpers.tpl` | Reused everywhere, needs release name |
| `labels` | `_helpers.tpl` | Consistency across resources |
| `selector.matchLabels` | `_helpers.tpl` | Must match pod labels |
| `image` | `values.yaml` or function | Changes per env/version |
| `replicas` | `values.yaml` | Changes per env |
| `resources` | `values.yaml` | Changes per env |
| Environment variables | `values.yaml` | Changes per env |

### ⚠️ CONSIDER Templatizing

| Field | Templatize If... |
|-------|------------------|
| `strategy.type` | You use both RollingUpdate and Recreate |
| `containerPort` | Different apps use different ports |
| `serviceAccountName` | You create SA dynamically |
| Probes | Different probe paths per app |
| Annotations | Different per environment |

---

## Data Structures Guide

### When to Use Each Type

| Type | Use When | Example |
|------|----------|---------|
| **Scalar** | Single value | `replicaCount: 3` |
| **Map** | Grouped related settings | `image: {repo: x, tag: y}` |
| **List** | Multiple items, same type | `ports: [80, 443]` |
| **List of Maps** | Multiple complex items | `env: [{name: x, value: y}]` |
| **Map of Maps** | Nested config | `resources: {limits: {cpu: x}}` |
| **Map to List** | Key-value → K8s env format | `envMap: {KEY: value}` |

---

### Scalar (Simple Values)

```yaml
# values.yaml
replicaCount: 3
containerPort: 8080
enableDebug: true

# template usage
replicas: {{ .Values.replicaCount }}
containerPort: {{ .Values.containerPort }}
{{- if .Values.enableDebug }}
```

---

### Map (Object/Dictionary)

```yaml
# values.yaml
image:
  registry: myregistry.azurecr.io
  repository: myapp
  tag: "v1.2.3"
  pullPolicy: IfNotPresent

# template usage
image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}

# OR use 'with' for cleaner code
{{- with .Values.image }}
image: "{{ .registry }}/{{ .repository }}:{{ .tag }}"
imagePullPolicy: {{ .pullPolicy }}
{{- end }}
```

---

### Map of Maps (Nested Objects)

```yaml
# values.yaml
resources:
  limits:
    cpu: "1000m"
    memory: "1Gi"
  requests:
    cpu: "100m"
    memory: "128Mi"

# template usage - render entire block
resources:
  {{- toYaml .Values.resources | nindent 2 }}

# template usage - access specific values
cpu-limit: {{ .Values.resources.limits.cpu }}
```

---

### List (Array)

```yaml
# values.yaml - simple list
imagePullSecrets:
  - name: secret1
  - name: secret2

# template usage
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}

# OR iterate
{{- range .Values.imagePullSecrets }}
- name: {{ .name }}
{{- end }}
```

---

### List of Maps (Most Common!)

```yaml
# values.yaml
env:
  - name: DATABASE_URL
    value: "postgres://db:5432"
  - name: REDIS_HOST
    value: "redis:6379"
  - name: LOG_LEVEL
    value: "info"

ports:
  - name: http
    containerPort: 8080
    protocol: TCP
  - name: metrics
    containerPort: 9090
    protocol: TCP

# template usage - direct render
env:
  {{- toYaml .Values.env | nindent 2 }}

# template usage - iterate
ports:
  {{- range .Values.ports }}
  - name: {{ .name }}
    containerPort: {{ .containerPort }}
    protocol: {{ .protocol | default "TCP" }}
  {{- end }}
```

---

### Map → List Conversion (for env vars)

```yaml
# values.yaml (easier to write)
envMap:
  DATABASE_URL: "postgres://db:5432"
  REDIS_HOST: "redis:6379"
  LOG_LEVEL: "info"

# template - convert map to K8s env format
env:
  {{- range $key, $value := .Values.envMap }}
  - name: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}

# OUTPUT:
# env:
#   - name: DATABASE_URL
#     value: "postgres://db:5432"
#   - name: LOG_LEVEL
#     value: "info"
#   - name: REDIS_HOST
#     value: "redis:6379"
```

---

## _helpers.tpl Functions

### Essential Functions (Must Have)

```yaml
{{/*
=================================================================
1. CHART NAME (short)
   Used for: container name, simple references
=================================================================
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
=================================================================
2. FULLNAME (release + chart name)
   Used for: resource names (deployment, service, etc.)
   Avoids: name collisions between releases
=================================================================
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
=================================================================
3. CHART LABEL (chart name + version)
   Used for: helm.sh/chart label
=================================================================
*/}}
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
=================================================================
4. COMMON LABELS (all resources get these)
   Used for: metadata.labels in every resource
   Includes: chart info, version, managed-by
=================================================================
*/}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mychart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
=================================================================
5. SELECTOR LABELS (IMMUTABLE!)
   Used for: spec.selector.matchLabels AND pod labels
   WARNING: These CANNOT change after first deploy!
   Keep minimal - only name + instance
=================================================================
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
=================================================================
6. SERVICE ACCOUNT NAME
   Logic: if create=true, use fullname; else use provided name
=================================================================
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mychart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
=================================================================
7. CONTAINER IMAGE (with registry support)
   Handles: registry/repository:tag format
=================================================================
*/}}
{{- define "mychart.image" -}}
{{- $registry := .Values.image.registry | default "" }}
{{- $repository := .Values.image.repository | default "nginx" }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString }}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s:%s" $repository $tag }}
{{- end }}
{{- end }}
```

---

### Additional Useful Functions

```yaml
{{/*
=================================================================
8. RESOURCES BLOCK (limits + requests)
   Renders complete resources section
=================================================================
*/}}
{{- define "mychart.resources" -}}
{{- if .Values.resources }}
resources:
  {{- toYaml .Values.resources | nindent 2 }}
{{- end }}
{{- end }}


{{/*
=================================================================
9. ENVIRONMENT VARIABLES (from map)
   Converts map to K8s env list format
=================================================================
*/}}
{{- define "mychart.env" -}}
{{- range $key, $value := . }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/* Usage: {{- include "mychart.env" .Values.envMap | nindent 12 }} */}}


{{/*
=================================================================
10. ANNOTATIONS (if any exist)
    Only renders annotations block if values exist
=================================================================
*/}}
{{- define "mychart.annotations" -}}
{{- if . }}
annotations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/* Usage: {{- include "mychart.annotations" .Values.podAnnotations | nindent 4 }} */}}


{{/*
=================================================================
11. LIVENESS PROBE
    Only renders if enabled
=================================================================
*/}}
{{- define "mychart.livenessProbe" -}}
{{- if .Values.livenessProbe.enabled }}
livenessProbe:
  httpGet:
    path: {{ .Values.livenessProbe.path }}
    port: {{ .Values.livenessProbe.port }}
  initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds | default 1 }}
  failureThreshold: {{ .Values.livenessProbe.failureThreshold | default 3 }}
{{- end }}
{{- end }}


{{/*
=================================================================
12. READINESS PROBE
    Only renders if enabled
=================================================================
*/}}
{{- define "mychart.readinessProbe" -}}
{{- if .Values.readinessProbe.enabled }}
readinessProbe:
  httpGet:
    path: {{ .Values.readinessProbe.path }}
    port: {{ .Values.readinessProbe.port }}
  initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds | default 1 }}
  successThreshold: {{ .Values.readinessProbe.successThreshold | default 1 }}
{{- end }}
{{- end }}


{{/*
=================================================================
13. CHECKSUM ANNOTATION (triggers redeploy on config change)
    Add to pod annotations to restart pods when ConfigMap changes
=================================================================
*/}}
{{- define "mychart.configChecksum" -}}
checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
{{- end }}


{{/*
=================================================================
14. IMAGE PULL SECRETS (if any exist)
=================================================================
*/}}
{{- define "mychart.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml .Values.imagePullSecrets | nindent 2 }}
{{- end }}
{{- end }}


{{/*
=================================================================
15. POD SECURITY CONTEXT
=================================================================
*/}}
{{- define "mychart.podSecurityContext" -}}
{{- if .Values.podSecurityContext }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- end }}
{{- end }}


{{/*
=================================================================
16. CONTAINER SECURITY CONTEXT
=================================================================
*/}}
{{- define "mychart.containerSecurityContext" -}}
{{- if .Values.securityContext }}
securityContext:
  {{- toYaml .Values.securityContext | nindent 2 }}
{{- end }}
{{- end }}
```

---

## Built-in Template Functions

### String Functions

| Function | Example | Result |
|----------|---------|--------|
| `quote` | `{{ "hello" \| quote }}` | `"hello"` |
| `upper` | `{{ "hello" \| upper }}` | `HELLO` |
| `lower` | `{{ "HELLO" \| lower }}` | `hello` |
| `title` | `{{ "hello world" \| title }}` | `Hello World` |
| `trim` | `{{ " hello " \| trim }}` | `hello` |
| `trimSuffix` | `{{ "hello-" \| trimSuffix "-" }}` | `hello` |
| `trimPrefix` | `{{ "-hello" \| trimPrefix "-" }}` | `hello` |
| `trunc` | `{{ "hello" \| trunc 3 }}` | `hel` |
| `replace` | `{{ "hello" \| replace "l" "x" }}` | `hexxo` |
| `contains` | `{{ if contains "ell" "hello" }}` | `true` |
| `hasPrefix` | `{{ if hasPrefix "he" "hello" }}` | `true` |
| `hasSuffix` | `{{ if hasSuffix "lo" "hello" }}` | `true` |
| `repeat` | `{{ "ab" \| repeat 3 }}` | `ababab` |
| `nospace` | `{{ "he llo" \| nospace }}` | `hello` |
| `snakecase` | `{{ "HelloWorld" \| snakecase }}` | `hello_world` |
| `camelcase` | `{{ "hello_world" \| camelcase }}` | `HelloWorld` |
| `kebabcase` | `{{ "HelloWorld" \| kebabcase }}` | `hello-world` |

---

### Default & Coalesce

| Function | Example | Result |
|----------|---------|--------|
| `default` | `{{ .Values.x \| default "fallback" }}` | Use "fallback" if x is empty |
| `coalesce` | `{{ coalesce .Values.a .Values.b "default" }}` | First non-empty value |
| `empty` | `{{ if empty .Values.x }}` | True if nil, "", 0, false |
| `required` | `{{ required "msg" .Values.x }}` | Fail if x is empty |

```yaml
# Examples
image: {{ .Values.image.tag | default .Chart.AppVersion }}
name: {{ coalesce .Values.nameOverride .Chart.Name }}
apiKey: {{ required "API key is required!" .Values.apiKey }}
```

---

### Type Conversion

| Function | Example | Result |
|----------|---------|--------|
| `toString` | `{{ 123 \| toString }}` | `"123"` |
| `toJson` | `{{ .Values.x \| toJson }}` | JSON string |
| `toYaml` | `{{ .Values.x \| toYaml }}` | YAML string |
| `fromYaml` | `{{ .Files.Get "x.yaml" \| fromYaml }}` | Parse YAML |
| `fromJson` | `{{ .Files.Get "x.json" \| fromJson }}` | Parse JSON |
| `int` | `{{ "123" \| int }}` | `123` (integer) |
| `float64` | `{{ "1.5" \| float64 }}` | `1.5` (float) |
| `atoi` | `{{ "123" \| atoi }}` | `123` (integer) |

---

### Indent Functions

| Function | Example | Use Case |
|----------|---------|----------|
| `indent` | `{{ .x \| indent 4 }}` | Add spaces to each line |
| `nindent` | `{{ .x \| nindent 4 }}` | Newline + indent (most common!) |

```yaml
# indent - adds spaces, no newline
data: {{ .Values.config | indent 2 }}
# Result:   some: value
#             here: too

# nindent - adds newline THEN indents (preferred!)
data:
  {{- toYaml .Values.config | nindent 2 }}
# Result:
#   some: value
#   here: too
```

---

### Logic Functions

| Function | Example | Result |
|----------|---------|--------|
| `eq` | `{{ if eq .Values.x "y" }}` | Equal |
| `ne` | `{{ if ne .Values.x "y" }}` | Not equal |
| `lt` | `{{ if lt .Values.x 10 }}` | Less than |
| `le` | `{{ if le .Values.x 10 }}` | Less or equal |
| `gt` | `{{ if gt .Values.x 10 }}` | Greater than |
| `ge` | `{{ if ge .Values.x 10 }}` | Greater or equal |
| `and` | `{{ if and .Values.a .Values.b }}` | Both true |
| `or` | `{{ if or .Values.a .Values.b }}` | Either true |
| `not` | `{{ if not .Values.x }}` | Negation |

```yaml
# Examples
{{- if and .Values.ingress.enabled (gt .Values.replicaCount 1) }}
{{- if or (eq .Values.env "prod") (eq .Values.env "staging") }}
{{- if not .Values.autoscaling.enabled }}
```

---

### List Functions

| Function | Example | Result |
|----------|---------|--------|
| `list` | `{{ list "a" "b" "c" }}` | Create list |
| `first` | `{{ first .Values.items }}` | First item |
| `last` | `{{ last .Values.items }}` | Last item |
| `rest` | `{{ rest .Values.items }}` | All except first |
| `initial` | `{{ initial .Values.items }}` | All except last |
| `append` | `{{ append .Values.items "new" }}` | Add to list |
| `prepend` | `{{ prepend .Values.items "new" }}` | Add to start |
| `concat` | `{{ concat .list1 .list2 }}` | Merge lists |
| `has` | `{{ if has "x" .Values.items }}` | Item exists |
| `uniq` | `{{ .Values.items \| uniq }}` | Remove duplicates |
| `sortAlpha` | `{{ .Values.items \| sortAlpha }}` | Sort strings |

```yaml
# Index access
{{ index .Values.ports 0 }}                    # First port
{{ index .Values.containers 0 "image" }}       # First container's image
```

---

### Map/Dict Functions

| Function | Example | Result |
|----------|---------|--------|
| `dict` | `{{ dict "key" "value" }}` | Create map |
| `get` | `{{ get .Values.map "key" }}` | Get value |
| `set` | `{{ set .Values.map "key" "val" }}` | Set value |
| `unset` | `{{ unset .Values.map "key" }}` | Remove key |
| `hasKey` | `{{ if hasKey .Values.map "key" }}` | Key exists |
| `keys` | `{{ keys .Values.map }}` | All keys |
| `values` | `{{ values .Values.map }}` | All values |
| `merge` | `{{ merge .map1 .map2 }}` | Merge maps |
| `mergeOverwrite` | `{{ mergeOverwrite .map1 .map2 }}` | Merge (right wins) |
| `pick` | `{{ pick .Values.map "a" "b" }}` | Select keys |
| `omit` | `{{ omit .Values.map "a" "b" }}` | Exclude keys |

```yaml
# Create dict inline
{{- $myDict := dict "name" .Values.name "version" .Chart.Version }}

# Merge defaults with user values
{{- $defaults := dict "replicas" 1 "port" 8080 }}
{{- $merged := merge .Values.config $defaults }}
```

---

### Crypto Functions

| Function | Example | Use Case |
|----------|---------|----------|
| `sha256sum` | `{{ .data \| sha256sum }}` | Generate checksum |
| `b64enc` | `{{ .data \| b64enc }}` | Base64 encode |
| `b64dec` | `{{ .data \| b64dec }}` | Base64 decode |
| `randAlphaNum` | `{{ randAlphaNum 16 }}` | Random string |
| `htpasswd` | `{{ htpasswd "user" "pass" }}` | HTTP basic auth |

```yaml
# Common: restart pods when config changes
annotations:
  checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}

# Generate random password
password: {{ randAlphaNum 32 | b64enc }}
```

---

### Date Functions

| Function | Example | Result |
|----------|---------|--------|
| `now` | `{{ now }}` | Current time |
| `date` | `{{ now \| date "2006-01-02" }}` | Format date |
| `dateModify` | `{{ now \| dateModify "-1h" }}` | Modify time |
| `toDate` | `{{ "2024-01-01" \| toDate "2006-01-02" }}` | Parse date |

---

### Semantic Version Functions

| Function | Example | Result |
|----------|---------|--------|
| `semver` | `{{ semver "1.2.3" }}` | Parse semver |
| `semverCompare` | `{{ if semverCompare ">=1.0" .Capabilities.KubeVersion.Version }}` | Compare versions |

```yaml
# Use different API based on K8s version
{{- if semverCompare ">=1.21" .Capabilities.KubeVersion.Version }}
apiVersion: networking.k8s.io/v1
{{- else }}
apiVersion: networking.k8s.io/v1beta1
{{- end }}
```

---

## Common Patterns

### 1. Conditional Block

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{- end }}
```

### 2. Optional Section

```yaml
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
```

### 3. Range with Index

```yaml
{{- range $index, $host := .Values.ingress.hosts }}
  - host: {{ $host }}
    # index is: {{ $index }}
{{- end }}
```

### 4. Range with Key-Value

```yaml
{{- range $key, $value := .Values.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
```

### 5. Ternary (Inline If)

```yaml
replicas: {{ ternary 1 .Values.replicaCount .Values.autoscaling.enabled }}
# If autoscaling.enabled is true → 1, else → replicaCount
```

### 6. Default with Nested Access

```yaml
# Safe access with defaults
image: {{ (.Values.image).repository | default "nginx" }}:{{ (.Values.image).tag | default "latest" }}
```

### 7. Required Value

```yaml
apiKey: {{ required "API key must be set in values.yaml!" .Values.apiKey }}
```

### 8. Include Template Inside Range

```yaml
{{- range .Values.services }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mychart.fullname" $ }}-{{ .name }}
  labels:
    {{- include "mychart.labels" $ | nindent 4 }}
{{- end }}
```

---

## Production values.yaml Template

```yaml
# ============================================================
# NAMING
# ============================================================
nameOverride: ""
fullnameOverride: ""

# ============================================================
# DEPLOYMENT
# ============================================================
replicaCount: 3

image:
  registry: ""                    # e.g., myregistry.azurecr.io
  repository: nginx
  tag: ""                         # Defaults to Chart.appVersion
  pullPolicy: IfNotPresent

imagePullSecrets: []
# - name: my-registry-secret

serviceAccount:
  create: true
  name: ""
  annotations: {}

# ============================================================
# CONTAINER
# ============================================================
containerPort: 8080

env: []
# - name: LOG_LEVEL
#   value: "info"

envFrom: []
# - secretRef:
#     name: my-secret
# - configMapRef:
#     name: my-config

resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "100m"
    memory: "128Mi"

# ============================================================
# PROBES
# ============================================================
livenessProbe:
  enabled: true
  path: /health
  port: http
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  enabled: true
  path: /ready
  port: http
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1

startupProbe:
  enabled: false
  path: /health
  port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 30

# ============================================================
# SERVICE
# ============================================================
service:
  type: ClusterIP
  port: 80
  targetPort: http
  annotations: {}

# ============================================================
# INGRESS
# ============================================================
ingress:
  enabled: false
  className: nginx
  annotations: {}
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []
  # - secretName: chart-example-tls
  #   hosts:
  #     - chart-example.local

# ============================================================
# AUTOSCALING
# ============================================================
autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

# ============================================================
# DEPLOYMENT STRATEGY
# ============================================================
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0

# ============================================================
# POD CONFIGURATION
# ============================================================
podAnnotations: {}
podLabels: {}

podSecurityContext: {}
  # fsGroup: 1000

securityContext: {}
  # runAsNonRoot: true
  # runAsUser: 1000
  # readOnlyRootFilesystem: true

# ============================================================
# SCHEDULING
# ============================================================
nodeSelector: {}

tolerations: []

affinity: {}
  # podAntiAffinity:
  #   preferredDuringSchedulingIgnoredDuringExecution:
  #   - weight: 100
  #     podAffinityTerm:
  #       labelSelector:
  #         matchLabels:
  #           app.kubernetes.io/name: my-app
  #       topologyKey: kubernetes.io/hostname

topologySpreadConstraints: []

# ============================================================
# VOLUMES
# ============================================================
volumes: []
# - name: config
#   configMap:
#     name: my-config

volumeMounts: []
# - name: config
#   mountPath: /etc/config
#   readOnly: true

# ============================================================
# CONFIG MAP (embedded)
# ============================================================
configMap:
  enabled: false
  data: {}
    # config.yaml: |
    #   key: value

# ============================================================
# MONITORING
# ============================================================
metrics:
  enabled: false
  port: 9090
  path: /metrics

serviceMonitor:
  enabled: false
  interval: 30s
  scrapeTimeout: 10s
  labels: {}

# ============================================================
# POD DISRUPTION BUDGET
# ============================================================
podDisruptionBudget:
  enabled: false
  minAvailable: 1
  # maxUnavailable: 1

# ============================================================
# NETWORK POLICY
# ============================================================
networkPolicy:
  enabled: false
```

---

## Quick Reference Card

### Template Syntax

| Syntax | Meaning |
|--------|---------|
| `{{ .Values.x }}` | Access values |
| `{{ .Release.Name }}` | Release name |
| `{{ .Chart.Name }}` | Chart name |
| `{{ include "func" . }}` | Call helper function |
| `{{- ... }}` | Trim left whitespace |
| `{{ ... -}}` | Trim right whitespace |
| `{{/* comment */}}` | Comment |
| `{{ if }}...{{ end }}` | Conditional |
| `{{ range }}...{{ end }}` | Loop |
| `{{ with }}...{{ end }}` | Change scope |
| `{{ $ }}` | Root scope |
| `{{ . }}` | Current scope |

### Common Pipelines

```yaml
{{ .Values.x | default "y" }}           # Default value
{{ .Values.x | quote }}                 # Wrap in quotes
{{ .Values.x | upper }}                 # Uppercase
{{ .Values.x | b64enc }}                # Base64 encode
{{ toYaml .Values.x | nindent 2 }}      # Render YAML with indent
{{ include "func" . | nindent 4 }}      # Include with indent
{{ required "msg" .Values.x }}          # Fail if empty
```

### Files Every Chart Needs

| File | Purpose |
|------|---------|
| `Chart.yaml` | Metadata |
| `values.yaml` | Default config |
| `templates/_helpers.tpl` | Reusable functions |
| `templates/deployment.yaml` | Main workload |
| `templates/service.yaml` | Network exposure |
| `templates/NOTES.txt` | Post-install message |
| `.helmignore` | Files to exclude |

why flat netwrok?
what is DNS pod in kubernetes?
what is cluster IP vs node port vs load balancer vs headless service in kuberbetes when to use them ?
ans:

session affinity and client id affintity  in load balancer service in kubernetes?


traffic polices

---

## Helm - Package Manager for Kubernetes

### Why Helm?

Helm is the **package manager for Kubernetes** (like apt for Ubuntu, yum for RHEL, or npm for Node.js).

### Problems WITHOUT Helm:

| Issue | Description |
|-------|-------------|
| **Multiple YAML Files** | A single app needs Deployment, Service, ConfigMap, Secret, Ingress, PVC, etc. - managing 10-20 YAML files manually |
| **No Versioning** | Can't track which version of manifests are deployed |
| **No Rollback** | Manual process to revert - error-prone and time-consuming |
| **Environment Management** | Need separate YAML files for dev/staging/prod or manual edits |
| **No Templating** | Hardcoded values everywhere - duplicate YAML for each environment |
| **No Release History** | No record of what was deployed, when, and by whom |
| **Dependency Management** | Manually deploy dependencies in correct order |

### How Helm Solves These:

```
┌─────────────────────────────────────────────────────────┐
│                    HELM CHART                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ templates/  │  │ values.yaml │  │ Chart.yaml  │     │
│  │ deployment  │  │ replicas: 3 │  │ name: myapp │     │
│  │ service     │  │ image: xxx  │  │ version: 1.0│     │
│  │ configmap   │  │ port: 8080  │  │             │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
              helm install myapp ./mychart
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              KUBERNETES CLUSTER                          │
│   Deployment + Service + ConfigMap + Secret + Ingress   │
└─────────────────────────────────────────────────────────┘
```

---

### Helm Chart Structure

```
mychart/
├── Chart.yaml          # Metadata (name, version, description)
├── values.yaml         # Default configuration values
├── values-dev.yaml     # Environment-specific overrides
├── values-prod.yaml
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── ingress.yaml
│   ├── _helpers.tpl    # Template helpers/functions
│   └── NOTES.txt       # Post-install instructions
├── charts/             # Dependency charts
└── .helmignore         # Files to ignore
```

---

## YAML Fundamentals (Prerequisites for Helm)

Before learning Helm templating, you MUST understand YAML data structures. Helm's `values.yaml` and templates are all YAML.

---

### 1. Scalar Values (Single Values)

```yaml
# Strings
name: myapp
description: "This is my application"    # Quotes optional for simple strings
path: "/api/v1"                          # Use quotes for special chars

# Numbers
replicas: 3
port: 8080
cpu: 0.5

# Booleans
enabled: true
debug: false

# Null
value: null
value: ~           # ~ also means null
```

---

### 2. Key-Value Pairs (Maps/Dictionaries)

```yaml
# Simple key-value
name: myapp
version: 1.0.0

# Nested key-value (Object/Map)
image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

# Same thing in inline/flow style
image: { repository: nginx, tag: "1.21", pullPolicy: IfNotPresent }
```

**Accessing in Helm:**
```yaml
{{ .Values.name }}                    # myapp
{{ .Values.image.repository }}        # nginx
{{ .Values.image.tag }}               # 1.21
```

---

### 3. Lists/Arrays

```yaml
# Simple list (using -)
fruits:
  - apple
  - banana
  - orange

# Inline list style
fruits: [apple, banana, orange]

# List of strings (common in K8s)
args:
  - "--config=/etc/config"
  - "--verbose"
  - "--port=8080"

# List of numbers
ports:
  - 80
  - 443
  - 8080
```

**Accessing in Helm:**
```yaml
{{ index .Values.fruits 0 }}          # apple (first item)
{{ index .Values.ports 1 }}           # 443 (second item)
```

---

### 4. List of Maps (Most Common in K8s!)

```yaml
# List of objects - VERY common pattern
containers:
  - name: app
    image: nginx:1.21
    port: 80
  - name: sidecar
    image: envoy:latest
    port: 9090

# Environment variables
env:
  - name: DATABASE_URL
    value: "postgres://db:5432"
  - name: REDIS_HOST
    value: "redis:6379"

# Ports definition
ports:
  - name: http
    containerPort: 80
    protocol: TCP
  - name: https
    containerPort: 443
    protocol: TCP
```

**In values.yaml:**
```yaml
env:
  - name: LOG_LEVEL
    value: "info"
  - name: NODE_ENV
    value: "production"
```

**Using in Helm template:**
```yaml
env:
  {{- toYaml .Values.env | nindent 2 }}

# Renders to:
env:
  - name: LOG_LEVEL
    value: "info"
  - name: NODE_ENV
    value: "production"
```

---

### 5. Map of Maps (Nested Objects)

```yaml
# Deeply nested structure
resources:
  limits:
    cpu: "1000m"
    memory: "1Gi"
  requests:
    cpu: "100m"
    memory: "128Mi"

# Accessing
{{ .Values.resources.limits.cpu }}     # 1000m
{{ .Values.resources.requests.memory }} # 128Mi

# Render entire block
resources:
  {{- toYaml .Values.resources | nindent 2 }}
```

---

### 6. Map with String Keys (for env vars, labels, annotations)

```yaml
# Labels as key-value map
labels:
  app: myapp
  team: backend
  environment: production

# Annotations
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "9090"

# Environment as map (alternative to list)
env:
  DATABASE_URL: "postgres://db:5432"
  REDIS_HOST: "redis:6379"
  LOG_LEVEL: "info"
```

**Iterating in Helm (range):**
```yaml
# For labels map
labels:
  {{- range $key, $value := .Values.labels }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}

# For env map → convert to list format K8s expects
env:
  {{- range $key, $value := .Values.env }}
  - name: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}
```

---

### 7. Multi-line Strings

```yaml
# Literal block (|) - preserves newlines
config: |
  server.port=8080
  server.host=0.0.0.0
  logging.level=INFO

# Folded block (>) - folds newlines to spaces
description: >
  This is a long description
  that spans multiple lines
  but will be folded into one line.

# With indicators
config: |+    # Keep trailing newlines
config: |-    # Strip trailing newline
```

**In values.yaml:**
```yaml
configFile: |
  [database]
  host = localhost
  port = 5432
  
  [cache]
  enabled = true
```

**In template:**
```yaml
data:
  config.ini: |
{{ .Values.configFile | indent 4 }}
```

---

### 8. Anchors and Aliases (Reuse Values)

```yaml
# Define anchor with &
defaults: &defaults
  cpu: "100m"
  memory: "128Mi"

# Reference with *
resources:
  requests: *defaults    # Reuses defaults
  limits:
    cpu: "500m"
    memory: "512Mi"

# Merge with <<
production:
  <<: *defaults          # Merge defaults
  memory: "256Mi"        # Override specific value
```

---

### YAML Gotchas to Avoid

| Issue | Wrong | Correct | Why It's Wrong |
|-------|-------|---------|----------------|
| **Tabs** | Using tabs | Use spaces only (2 space indent) | YAML spec prohibits tabs for indentation. Tabs cause parsing errors because their width is ambiguous. |
| **Colon in string** | `url: http://host:8080` | `url: "http://host:8080"` | The second colon (`:8080`) is interpreted as a new key-value pair, breaking the structure. |
| **Special chars** | `path: /api/*` | `path: "/api/*"` | `*` is a reserved character (alias indicator). Other special chars: `{}[]!@#&` also need quoting. |
| **Boolean strings** | `enabled: yes` | `enabled: true` or `enabled: "yes"` | YAML auto-converts `yes/no/on/off/y/n` to boolean `true/false`. Quote if you want the literal string. |
| **Numbers as strings** | `version: 1.0` | `version: "1.0"` | `1.0` is parsed as float `1` (trailing zero dropped). Use quotes to preserve as string "1.0". |
| **Empty value** | `key:` | `key: ""` or `key: null` | `key:` results in `null`, which may cause unexpected behavior. Be explicit about intent. |

---

### Quick Reference: YAML → Helm Access

```yaml
# values.yaml
name: myapp                          # {{ .Values.name }}
replicas: 3                          # {{ .Values.replicas }}

image:                               
  repository: nginx                  # {{ .Values.image.repository }}
  tag: "1.21"                        # {{ .Values.image.tag }}

ports:                               
  - 80                               # {{ index .Values.ports 0 }}
  - 443                              # {{ index .Values.ports 1 }}

env:                                 # range $key, $value := .Values.env
  LOG_LEVEL: info                    
  DEBUG: "false"                     

labels:                              # range $k, $v := .Values.labels
  app: myapp
  tier: frontend

containers:                          # range .Values.containers
  - name: web
    image: nginx
  - name: sidecar
    image: envoy

resources:                           # toYaml .Values.resources | nindent X
  limits:
    cpu: "1"
    memory: "1Gi"
```

---

## Helm Templating Syntax

Now that you understand YAML structures, here's how Helm templates work with them:

### Template Delimiters

```yaml
{{ }}     # Output result
{{- }}    # Trim whitespace before
{{ -}}    # Trim whitespace after
{{- -}}   # Trim both sides
```

#### Why `-` Delimiter is Needed

The `-` in `{{-` or `-}}` is used for **whitespace control** to produce clean YAML output.

| Syntax | Effect |
|--------|--------|
| `{{- }}` | Trims whitespace/newlines **before** the action |
| `{{ -}}` | Trims whitespace/newlines **after** the action |
| `{{- -}}` | Trims **both sides** |

**Without `-` (produces extra blank lines):**
```yaml
metadata:
  labels:
{{ if .Values.team }}
    team: {{ .Values.team }}
{{ end }}
```

**With `-` (clean output):**
```yaml
metadata:
  labels:
{{- if .Values.team }}
    team: {{ .Values.team }}
{{- end }}
```

**Why It Matters:**
YAML is **whitespace-sensitive**. Extra blank lines or spaces can:
- Break indentation and cause parsing errors
- Make rendered manifests harder to read
- Cause unexpected behavior in Kubernetes resources

The `-` helps control exactly how templates render, ensuring clean, valid YAML output.

---

### Accessing Values

```yaml
# From values.yaml
{{ .Values.replicaCount }}
{{ .Values.image.repository }}

# Built-in objects
{{ .Release.Name }}           # Helm release name
{{ .Release.Namespace }}      # Target namespace
{{ .Chart.Name }}             # Chart name from Chart.yaml
{{ .Chart.Version }}          # Chart version
```

---

### range - Iterating Over Lists

**values.yaml:**
```yaml
ports:
  - name: http
    port: 80
  - name: https
    port: 443
```

**template:**
```yaml
ports:
  {{- range .Values.ports }}
  - name: {{ .name }}
    containerPort: {{ .port }}
  {{- end }}
```

**Output:**
```yaml
ports:
  - name: http
    containerPort: 80
  - name: https
    containerPort: 443
```

---

### range - Iterating Over Maps (Key-Value)

**values.yaml:**
```yaml
env:
  DATABASE_URL: "postgres://db:5432"
  REDIS_HOST: "redis:6379"
  LOG_LEVEL: "info"
```

**template:**
```yaml
env:
  {{- range $key, $value := .Values.env }}
  - name: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}
```

**Output:**
```yaml
env:
  - name: DATABASE_URL
    value: "postgres://db:5432"
  - name: LOG_LEVEL
    value: "info"
  - name: REDIS_HOST
    value: "redis:6379"
```

---

### toYaml - Render Complex Structures

**values.yaml:**
```yaml
resources:
  limits:
    cpu: "1000m"
    memory: "1Gi"
  requests:
    cpu: "100m"
    memory: "128Mi"
```

**template:**
```yaml
resources:
  {{- toYaml .Values.resources | nindent 2 }}
```

**Output:**
```yaml
resources:
  limits:
    cpu: "1000m"
    memory: "1Gi"
  requests:
    cpu: "100m"
    memory: "128Mi"
```

---

### if/else - Conditionals

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
# ... ingress spec
{{- end }}

# With else
replicas: {{- if .Values.autoscaling.enabled }} 1 {{- else }} {{ .Values.replicaCount }} {{- end }}

# Check if value exists
{{- if .Values.nodeSelector }}
nodeSelector:
  {{- toYaml .Values.nodeSelector | nindent 2 }}
{{- end }}
```

---

### with - Change Scope

The `with` block changes the context (`.`) to a specific value, making code cleaner when accessing nested properties repeatedly.

**values.yaml:**
```yaml
image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent
```

**WITHOUT `with` (repetitive):**
```yaml
spec:
  containers:
    - name: app
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
```

**WITH `with` (cleaner):**
```yaml
spec:
  containers:
    - name: app
      {{- with .Values.image }}
      image: "{{ .repository }}:{{ .tag }}"
      imagePullPolicy: {{ .pullPolicy }}
      {{- end }}
```

**Both render the same output:**
```yaml
spec:
  containers:
    - name: app
      image: "nginx:1.21"
      imagePullPolicy: IfNotPresent
```

**Note:** Inside `with`, use `$` to access root scope:
```yaml
{{- with .Values.image }}
image: "{{ .repository }}:{{ .tag }}"
release: {{ $.Release.Name }}  # $ accesses root
{{- end }}
```

---

### Understanding Scope in Helm

**Scope** refers to what the dot (`.`) refers to at any point in your template. The dot is your current context - it determines what data you can access directly.

```
┌─────────────────────────────────────────────────────────────┐
│                    HELM SCOPE CONCEPT                       │
│                                                             │
│   ROOT SCOPE (.)                                            │
│   ├── .Values      (values.yaml data)                       │
│   ├── .Release     (release info)                           │
│   ├── .Chart       (Chart.yaml data)                        │
│   ├── .Files       (file access)                            │
│   └── .Capabilities (cluster info)                          │
│                                                             │
│   $ = Always points to ROOT SCOPE (escape hatch)            │
└─────────────────────────────────────────────────────────────┘
```

---

#### Root Scope (Default)

At the top level of any template, `.` refers to the root scope:

```yaml
# At root level, . has access to everything
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}        # . is root scope
  labels:
    app: {{ .Chart.Name }}         # . is root scope
spec:
  replicas: {{ .Values.replicas }} # . is root scope
```

---

#### Scope Changes with `with`

The `with` block changes what `.` refers to:

```yaml
# values.yaml
database:
  host: postgres.local
  port: 5432
  name: mydb

# template
{{- with .Values.database }}
# NOW . refers to .Values.database (NOT root!)
env:
  - name: DB_HOST
    value: {{ .host }}      # Same as .Values.database.host
  - name: DB_PORT
    value: {{ .port }}      # Same as .Values.database.port
  - name: DB_NAME
    value: {{ .name }}      # Same as .Values.database.name
  
  # PROBLEM: This won't work inside 'with'!
  # - name: RELEASE
  #   value: {{ .Release.Name }}  # ERROR! . is now database, not root
  
  # SOLUTION: Use $ to access root scope
  - name: RELEASE
    value: {{ $.Release.Name }}   # $ always = root scope
{{- end }}
```

---

#### Scope Changes with `range`

When iterating, `.` becomes the current item:

```yaml
# values.yaml
containers:
  - name: web
    image: nginx
    port: 80
  - name: api
    image: myapp
    port: 8080

# template
spec:
  containers:
    {{- range .Values.containers }}
    # . is now the current container object
    - name: {{ .name }}           # Current container's name
      image: {{ .image }}         # Current container's image
      ports:
        - containerPort: {{ .port }}
      
      # Access root scope with $
      env:
        - name: RELEASE_NAME
          value: {{ $.Release.Name }}      # $ = root
        - name: CHART_VERSION
          value: {{ $.Chart.Version }}     # $ = root
    {{- end }}
```

---

#### Using `$` to Access Root Scope

`$` is set to the root scope at the start of template execution and never changes:

```yaml
# Complex example with nested scope changes
{{- with .Values.app }}
  # . = .Values.app
  name: {{ .name }}
  
  {{- range .containers }}
    # . = current container (nested scope change!)
    - name: {{ .name }}
      
      # Need root values? Use $
      namespace: {{ $.Release.Namespace }}
      chartName: {{ $.Chart.Name }}
      
      # Access sibling values through $
      appName: {{ $.Values.app.name }}
  {{- end }}
{{- end }}
```

---

#### Scope with Variables

Variables preserve values across scope changes:

```yaml
# Capture values before scope changes
{{- $releaseName := .Release.Name }}
{{- $namespace := .Release.Namespace }}

{{- range .Values.services }}
  # . is now current service, but variables still work
  - name: {{ .name }}-{{ $releaseName }}
    namespace: {{ $namespace }}
{{- end }}
```

---

#### Scope Summary Table

| Context | What `.` refers to | How to access root |
|---------|-------------------|-------------------|
| Top-level template | Root (Values, Release, Chart, etc.) | `.` or `$` |
| Inside `with .Values.x` | `.Values.x` | `$` |
| Inside `range .Values.list` | Current list item | `$` |
| Inside `range $i, $v := .Values.list` | Current item (`$v`) | `$` |
| Nested `with` inside `range` | Inner `with` value | `$` |

---

#### Common Scope Mistakes

```yaml
# WRONG - . is not root inside range
{{- range .Values.hosts }}
  host: {{ . }}
  release: {{ .Release.Name }}  # ERROR! . is the current host string
{{- end }}

# CORRECT - use $ for root
{{- range .Values.hosts }}
  host: {{ . }}
  release: {{ $.Release.Name }}  # Works! $ is always root
{{- end }}

# WRONG - . is not root inside with
{{- with .Values.database }}
  db: {{ .host }}
  chart: {{ .Chart.Name }}  # ERROR! . is database, not root
{{- end }}

# CORRECT
{{- with .Values.database }}
  db: {{ .host }}
  chart: {{ $.Chart.Name }}  # Works!
{{- end }}
```

---

### Common Functions

| Function | Example | Result |
|----------|---------|--------|
| `quote` | `{{ .Values.name \| quote }}` | `"myapp"` |
| `default` | `{{ .Values.port \| default 8080 }}` | Use 8080 if empty |
| `upper/lower` | `{{ .Values.env \| upper }}` | `PRODUCTION` |
| `indent` | `{{ .Values.config \| indent 4 }}` | Add 4 spaces |
| `nindent` | `{{ toYaml .x \| nindent 2 }}` | Newline + indent |
| `trim` | `{{ .Values.name \| trim }}` | Remove whitespace |
| `replace` | `{{ .Values.x \| replace "-" "_" }}` | `my_app` |
| `contains` | `{{ if contains "http" .Values.url }}` | Boolean check |

---

### Complete Example: values.yaml → Template → Output

**values.yaml:**
```yaml
replicaCount: 3

image:
  repository: myapp
  tag: "v1.0.0"

env:
  LOG_LEVEL: debug
  PORT: "8080"

labels:
  app: myapp
  tier: backend

resources:
  limits:
    cpu: "500m"
    memory: "256Mi"
```

**templates/deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    {{- range $key, $value := .Values.labels }}
    {{ $key }}: {{ $value }}
    {{- end }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

**Rendered Output (helm template myrelease ./mychart):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myrelease
  labels:
    app: myapp
    tier: backend
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: mychart
          image: "myapp:v1.0.0"
          env:
            - name: LOG_LEVEL
              value: "debug"
            - name: PORT
              value: "8080"
          resources:
            limits:
              cpu: "500m"
              memory: "256Mi"
```

---

```bash
# Create new chart scaffold
helm create mychart

# Chart.yaml - Metadata
apiVersion: v2
name: mychart
description: My application Helm chart
type: application
version: 0.1.0        # Chart version
appVersion: "1.0.0"   # Application version
```

**values.yaml - Configuration:**
```yaml
replicaCount: 3
image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
resources:
  limits:
    cpu: 100m
    memory: 128Mi
```

**templates/deployment.yaml - Templated Manifest:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Chart.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

---

### Utilizing Helm Charts

```bash
# Add a repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Search for charts
helm search repo nginx
helm search hub wordpress        # Search Artifact Hub

# Install a chart
helm install myrelease bitnami/nginx

# Install with custom values
helm install myrelease bitnami/nginx -f custom-values.yaml

# Install with inline overrides
helm install myrelease bitnami/nginx --set replicaCount=5

# Install in specific namespace
helm install myrelease bitnami/nginx -n production --create-namespace

# Dry-run (preview without installing)
helm install myrelease ./mychart --dry-run --debug

# Template (render manifests locally)
helm template myrelease ./mychart > rendered.yaml

# Upgrade a release
helm upgrade myrelease ./mychart -f values-prod.yaml

# Install or upgrade (upsert)
helm upgrade --install myrelease ./mychart
```

---

### Helm Release Management & History

```bash
# List all releases
helm list
helm list -A                     # All namespaces
helm list --pending              # Pending releases

# Get release status
helm status myrelease

# Get release history
helm history myrelease
```

**Example History Output:**
```
REVISION  UPDATED                   STATUS      DESCRIPTION
1         Mon Jan 20 10:00:00 2026  superseded  Install complete
2         Mon Jan 22 14:30:00 2026  superseded  Upgrade complete
3         Mon Jan 25 09:15:00 2026  deployed    Upgrade complete
```

---

### Helm Rollback

```bash
# Rollback to previous revision
helm rollback myrelease

# Rollback to specific revision
helm rollback myrelease 2

# Rollback with dry-run
helm rollback myrelease 1 --dry-run

# Force rollback (delete and recreate resources)
helm rollback myrelease 1 --force

# Wait for rollback to complete
helm rollback myrelease 1 --wait --timeout 5m
```

**Rollback Flow:**
```
Current: Revision 3 (buggy)
         │
         ▼
    helm rollback myrelease 2
         │
         ▼
New: Revision 4 (copy of Revision 2's state)

History now shows:
REVISION  STATUS
1         superseded
2         superseded
3         superseded
4         deployed      ← New revision with Revision 2 config
```

---

### How Helm Stores Releases

```
┌───────────────────────────────────────────────────────────┐
│                   HELM 3 Architecture                      │
│                                                            │
│   helm install ──────► Kubernetes API ──────► Cluster      │
│                              │                             │
│                              ▼                             │
│                     Release stored as                      │
│                     Kubernetes SECRET                      │
│                     (in release namespace)                 │
│                                                            │
│   Secret: sh.helm.release.v1.myrelease.v1                 │
│   Secret: sh.helm.release.v1.myrelease.v2                 │
│   Secret: sh.helm.release.v1.myrelease.v3                 │
└───────────────────────────────────────────────────────────┘
```

```bash
# View Helm secrets
kubectl get secrets -l owner=helm

# Each secret contains:
# - Chart metadata
# - Values used
# - Rendered manifests
# - Release status
```

---

### Helm Commands Cheat Sheet

| Command | Description |
|---------|-------------|
| `helm create <name>` | Create new chart |
| `helm install <release> <chart>` | Install chart |
| `helm upgrade <release> <chart>` | Upgrade release |
| `helm upgrade --install` | Install or upgrade |
| `helm uninstall <release>` | Remove release |
| `helm list` | List releases |
| `helm history <release>` | Show revision history |
| `helm rollback <release> <rev>` | Rollback to revision |
| `helm status <release>` | Show release status |
| `helm get values <release>` | Get deployed values |
| `helm get manifest <release>` | Get deployed manifests |
| `helm template <chart>` | Render templates locally |
| `helm lint <chart>` | Validate chart |
| `helm package <chart>` | Package chart as .tgz |
| `helm repo add/update/list` | Manage repositories |

---

### Real-World Example: Multi-Environment Deployment

```bash
# Same chart, different environments
helm upgrade --install myapp ./mychart \
  -f values.yaml \
  -f values-dev.yaml \
  -n dev

helm upgrade --install myapp ./mychart \
  -f values.yaml \
  -f values-staging.yaml \
  -n staging

helm upgrade --install myapp ./mychart \
  -f values.yaml \
  -f values-prod.yaml \
  -n production \
  --set image.tag=v2.1.0
```

**Benefits Achieved:**
- ✅ Single source of truth (one chart)
- ✅ Environment-specific configs via values files
- ✅ Version controlled
- ✅ Instant rollback capability
- ✅ Release history tracking
- ✅ Dependency management

---

## Converting Existing YAML to Helm Chart (Step-by-Step)

### Scenario: You Have These Existing Files

```
my-app/
├── deployment.yaml
├── service.yaml
├── configmap.yaml
└── ingress.yaml
```

---

### Step 1: Create Chart Scaffold

```bash
# Create empty chart structure
helm create myapp-chart

# Remove sample templates (we'll add our own)
rm -rf myapp-chart/templates/*
```

**Resulting Structure:**
```
myapp-chart/
├── Chart.yaml
├── values.yaml
├── templates/        # Empty - we'll add our YAMLs here
└── charts/
```

---

### Step 2: Copy Your YAMLs to templates/

```bash
cp deployment.yaml myapp-chart/templates/
cp service.yaml myapp-chart/templates/
cp configmap.yaml myapp-chart/templates/
cp ingress.yaml myapp-chart/templates/
```

**At this point, chart works!** (but not templated yet)
```bash
helm install myapp ./myapp-chart --dry-run
```

---

### Step 3: Identify Values to Extract

**Before (deployment.yaml - hardcoded):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 3                              # ← Extract
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myregistry/myapp:v1.2.3   # ← Extract
          ports:
            - containerPort: 8080          # ← Extract
          resources:
            limits:
              cpu: "500m"                  # ← Extract
              memory: "256Mi"              # ← Extract
          env:
            - name: DB_HOST
              value: "prod-db.example.com" # ← Extract (varies per env)
```

---

### Step 4: Create values.yaml

```yaml
# values.yaml - All configurable values

replicaCount: 3

image:
  repository: myregistry/myapp
  tag: "v1.2.3"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

containerPort: 8080

resources:
  limits:
    cpu: "500m"
    memory: "256Mi"
  requests:
    cpu: "100m"
    memory: "128Mi"

env:
  DB_HOST: "prod-db.example.com"
  LOG_LEVEL: "info"

ingress:
  enabled: true
  host: myapp.example.com
  path: /
```

---

### Step 5: Convert YAML to Template

**After (templates/deployment.yaml - templated):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Release.Name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
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
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.containerPort }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
```

---

### Template Syntax Quick Reference

| Syntax | Description | Example |
|--------|-------------|---------|
| `{{ .Values.xxx }}` | Access values.yaml | `{{ .Values.replicaCount }}` |
| `{{ .Release.Name }}` | Helm release name | `myapp` |
| `{{ .Release.Namespace }}` | Target namespace | `production` |
| `{{ .Chart.Name }}` | Chart name | `myapp-chart` |
| `{{ .Chart.Version }}` | Chart version | `0.1.0` |
| `{{ quote .Values.x }}` | Wrap in quotes | `"value"` |
| `{{ default "x" .Values.y }}` | Default value | If y is empty, use "x" |
| `{{- toYaml .Values.x \| nindent 4 }}` | Convert to YAML with indent | Multi-line objects |
| `{{- if .Values.x }}` | Conditional | Include block if true |
| `{{- range }}` | Loop | Iterate over list/map |

---

### Step 6: Template service.yaml

**Before:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: myapp
```

**After (templates/service.yaml):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
  labels:
    app: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
  selector:
    app: {{ .Release.Name }}
```

---

### Step 7: Template with Conditionals (ingress.yaml)

**After (templates/ingress.yaml):**
```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress
  annotations:
    {{- range $key, $value := .Values.ingress.annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
spec:
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: {{ .Values.ingress.path }}
            pathType: Prefix
            backend:
              service:
                name: {{ .Release.Name }}-service
                port:
                  number: {{ .Values.service.port }}
{{- end }}
```

---

### Step 8: Create Environment-Specific Values

**values-dev.yaml:**
```yaml
replicaCount: 1
image:
  tag: "latest"
resources:
  limits:
    cpu: "200m"
    memory: "128Mi"
env:
  DB_HOST: "dev-db.internal"
  LOG_LEVEL: "debug"
ingress:
  host: myapp-dev.example.com
```

**values-prod.yaml:**
```yaml
replicaCount: 5
image:
  tag: "v1.2.3"
resources:
  limits:
    cpu: "1000m"
    memory: "512Mi"
env:
  DB_HOST: "prod-db.example.com"
  LOG_LEVEL: "warn"
ingress:
  host: myapp.example.com
```

---

### Step 9: Validate and Test

```bash
# Lint chart for errors
helm lint ./myapp-chart

# Dry-run to preview rendered YAML
helm template myrelease ./myapp-chart -f values-dev.yaml

# Install with dry-run (validates against cluster)
helm install myrelease ./myapp-chart -f values-dev.yaml --dry-run --debug

# Compare environments
helm template myrelease ./myapp-chart -f values-dev.yaml > dev-rendered.yaml
helm template myrelease ./myapp-chart -f values-prod.yaml > prod-rendered.yaml
diff dev-rendered.yaml prod-rendered.yaml
```

---

### Step 10: Deploy

```bash
# Deploy to dev
helm upgrade --install myapp ./myapp-chart \
  -f values.yaml \
  -f values-dev.yaml \
  -n dev --create-namespace

# Deploy to production
helm upgrade --install myapp ./myapp-chart \
  -f values.yaml \
  -f values-prod.yaml \
  -n production --create-namespace
```

---

### Final Chart Structure

```
myapp-chart/
├── Chart.yaml
├── values.yaml           # Default values
├── values-dev.yaml       # Dev overrides
├── values-staging.yaml   # Staging overrides
├── values-prod.yaml      # Prod overrides
├── templates/
│   ├── _helpers.tpl      # Reusable template functions
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── ingress.yaml
│   └── NOTES.txt         # Post-install message
└── .helmignore
```

---

### Pro Tips for Conversion

| Tip | Details |
|-----|---------|
| **Start Simple** | First just copy YAMLs, then incrementally templatize |
| **Use `helm template`** | Preview changes without deploying |
| **Extract What Varies** | Only templatize values that differ between environments |
| **Use _helpers.tpl** | Create reusable labels, names, selectors |
| **Add NOTES.txt** | Show connection info after install |
| **Version Your Chart** | Update `Chart.yaml` version on changes |

**Example _helpers.tpl:**
```yaml
{{- define "myapp.labels" -}}
app: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end }}
```

**Use in templates:**
```yaml
metadata:
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
```

---

## Complete Hands-On Example: E-Commerce App Conversion

### EXISTING YAML FILES (Before Helm)

**Original: deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-api
  labels:
    app: ecommerce-api
    team: backend
    environment: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: ecommerce-api
  template:
    metadata:
      labels:
        app: ecommerce-api
        version: v2.1.0
    spec:
      serviceAccountName: ecommerce-sa
      containers:
        - name: api
          image: myregistry.azurecr.io/ecommerce-api:v2.1.0
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 8080
            - name: metrics
              containerPort: 9090
          env:
            - name: DATABASE_URL
              value: "postgresql://prod-db.internal:5432/ecommerce"
            - name: REDIS_HOST
              value: "redis-master.cache:6379"
            - name: LOG_LEVEL
              value: "info"
            - name: ENABLE_CACHE
              value: "true"
          envFrom:
            - secretRef:
                name: ecommerce-secrets
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1000m"
              memory: "1Gi"
          livenessProbe:
            httpGet:
              path: /health/live
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
          volumeMounts:
            - name: config-volume
              mountPath: /app/config
      volumes:
        - name: config-volume
          configMap:
            name: ecommerce-config
      imagePullSecrets:
        - name: acr-secret
```

**Original: service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-api-svc
  labels:
    app: ecommerce-api
spec:
  type: ClusterIP
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: metrics
      port: 9090
      targetPort: 9090
      protocol: TCP
  selector:
    app: ecommerce-api
```

**Original: configmap.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
data:
  app.properties: |
    server.port=8080
    server.context-path=/api
    feature.new-checkout=true
    feature.recommendations=true
```

**Original: ingress.yaml**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
    - hosts:
        - api.ecommerce.com
      secretName: ecommerce-tls
  rules:
    - host: api.ecommerce.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ecommerce-api-svc
                port:
                  number: 80
```

**Original: hpa.yaml**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ecommerce-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

---

### HELM CHART CONVERSION

**Step 1: Create Chart Structure**
```bash
mkdir -p ecommerce-chart/templates
cd ecommerce-chart
```

**Chart.yaml:**
```yaml
apiVersion: v2
name: ecommerce-api
description: E-Commerce API Helm Chart
type: application
version: 1.0.0
appVersion: "2.1.0"
maintainers:
  - name: Platform Team
    email: platform@company.com
```

---

**values.yaml (Extracted Configuration):**
```yaml
# Application
nameOverride: ""
fullnameOverride: ""

# Replicas (overridden by HPA if enabled)
replicaCount: 3

# Container Image
image:
  repository: myregistry.azurecr.io/ecommerce-api
  tag: "v2.1.0"
  pullPolicy: Always

imagePullSecrets:
  - name: acr-secret

serviceAccount:
  name: ecommerce-sa

# Container Ports
ports:
  http: 8080
  metrics: 9090

# Service Configuration
service:
  type: ClusterIP
  httpPort: 80
  metricsPort: 9090

# Environment Variables
env:
  DATABASE_URL: "postgresql://prod-db.internal:5432/ecommerce"
  REDIS_HOST: "redis-master.cache:6379"
  LOG_LEVEL: "info"
  ENABLE_CACHE: "true"

# Secret Reference
secretRef:
  enabled: true
  name: ecommerce-secrets

# Resources
resources:
  requests:
    cpu: "250m"
    memory: "512Mi"
  limits:
    cpu: "1000m"
    memory: "1Gi"

# Health Probes
livenessProbe:
  path: /health/live
  port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  path: /health/ready
  port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5

# Ingress
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
  host: api.ecommerce.com
  path: /
  tls:
    enabled: true
    secretName: ecommerce-tls

# HPA
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

# ConfigMap
config:
  enabled: true
  data:
    app.properties: |
      server.port=8080
      server.context-path=/api
      feature.new-checkout=true
      feature.recommendations=true

# Deployment Strategy
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0

# Labels
labels:
  team: backend
```

---

**templates/_helpers.tpl:**
```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "ecommerce.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ecommerce.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ecommerce.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "ecommerce.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels.team }}
team: {{ .Values.labels.team }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ecommerce.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ecommerce.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

---

**templates/deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "ecommerce.fullname" . }}
  labels:
    {{- include "ecommerce.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  strategy:
    type: {{ .Values.strategy.type }}
    {{- if eq .Values.strategy.type "RollingUpdate" }}
    rollingUpdate:
      maxSurge: {{ .Values.strategy.rollingUpdate.maxSurge }}
      maxUnavailable: {{ .Values.strategy.rollingUpdate.maxUnavailable }}
    {{- end }}
  selector:
    matchLabels:
      {{- include "ecommerce.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "ecommerce.selectorLabels" . | nindent 8 }}
        version: {{ .Values.image.tag | quote }}
    spec:
      serviceAccountName: {{ .Values.serviceAccount.name }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.ports.http }}
            - name: metrics
              containerPort: {{ .Values.ports.metrics }}
          env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
          {{- if .Values.secretRef.enabled }}
          envFrom:
            - secretRef:
                name: {{ .Values.secretRef.name }}
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.path }}
              port: {{ .Values.livenessProbe.port }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.path }}
              port: {{ .Values.readinessProbe.port }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
          {{- if .Values.config.enabled }}
          volumeMounts:
            - name: config-volume
              mountPath: /app/config
          {{- end }}
      {{- if .Values.config.enabled }}
      volumes:
        - name: config-volume
          configMap:
            name: {{ include "ecommerce.fullname" . }}-config
      {{- end }}
```

---

**templates/service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "ecommerce.fullname" . }}-svc
  labels:
    {{- include "ecommerce.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - name: http
      port: {{ .Values.service.httpPort }}
      targetPort: {{ .Values.ports.http }}
      protocol: TCP
    - name: metrics
      port: {{ .Values.service.metricsPort }}
      targetPort: {{ .Values.ports.metrics }}
      protocol: TCP
  selector:
    {{- include "ecommerce.selectorLabels" . | nindent 4 }}
```

---

**templates/configmap.yaml:**
```yaml
{{- if .Values.config.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "ecommerce.fullname" . }}-config
  labels:
    {{- include "ecommerce.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.config.data }}
  {{ $key }}: |
{{ $value | indent 4 }}
  {{- end }}
{{- end }}
```

---

**templates/ingress.yaml:**
```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "ecommerce.fullname" . }}-ingress
  labels:
    {{- include "ecommerce.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    kubernetes.io/ingress.class: {{ $.Values.ingress.className }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.tls.enabled }}
  tls:
    - hosts:
        - {{ .Values.ingress.host }}
      secretName: {{ .Values.ingress.tls.secretName }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: {{ .Values.ingress.path }}
            pathType: Prefix
            backend:
              service:
                name: {{ include "ecommerce.fullname" . }}-svc
                port:
                  number: {{ .Values.service.httpPort }}
{{- end }}
```

---

**templates/hpa.yaml:**
```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "ecommerce.fullname" . }}-hpa
  labels:
    {{- include "ecommerce.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "ecommerce.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
```

---

**templates/NOTES.txt:**
```
🚀 {{ .Chart.Name }} deployed successfully!

Get the application URL:
{{- if .Values.ingress.enabled }}
  https://{{ .Values.ingress.host }}
{{- else }}
  kubectl port-forward svc/{{ include "ecommerce.fullname" . }}-svc {{ .Values.service.httpPort }}:{{ .Values.service.httpPort }}
  Then visit: http://localhost:{{ .Values.service.httpPort }}
{{- end }}

Check deployment status:
  kubectl get pods -l app.kubernetes.io/instance={{ .Release.Name }}

View logs:
  kubectl logs -l app.kubernetes.io/instance={{ .Release.Name }} -f
```

---

### ENVIRONMENT OVERRIDES

**values-dev.yaml:**
```yaml
replicaCount: 1

image:
  tag: "latest"
  pullPolicy: Always

env:
  DATABASE_URL: "postgresql://dev-db:5432/ecommerce_dev"
  REDIS_HOST: "redis-dev:6379"
  LOG_LEVEL: "debug"
  ENABLE_CACHE: "false"

resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

ingress:
  host: api-dev.ecommerce.local
  tls:
    enabled: false

autoscaling:
  enabled: false

config:
  data:
    app.properties: |
      server.port=8080
      server.context-path=/api
      feature.new-checkout=true
      feature.recommendations=false
```

**values-prod.yaml:**
```yaml
replicaCount: 5

image:
  tag: "v2.1.0"

env:
  DATABASE_URL: "postgresql://prod-db.internal:5432/ecommerce"
  REDIS_HOST: "redis-master.cache:6379"
  LOG_LEVEL: "warn"
  ENABLE_CACHE: "true"

resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "2000m"
    memory: "2Gi"

ingress:
  host: api.ecommerce.com
  tls:
    enabled: true

autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60
```

---

### DEPLOYMENT COMMANDS

```bash
# Validate chart
helm lint ./ecommerce-chart

# Preview dev environment
helm template ecommerce ./ecommerce-chart -f values-dev.yaml

# Deploy to dev
helm upgrade --install ecommerce ./ecommerce-chart \
  -f values.yaml \
  -f values-dev.yaml \
  -n dev --create-namespace

# Deploy to production
helm upgrade --install ecommerce ./ecommerce-chart \
  -f values.yaml \
  -f values-prod.yaml \
  -n production --create-namespace

# Rollback if issues
helm rollback ecommerce 1 -n production
```

---

## Go Templating in Helm - Complete Guide

Helm uses **Go templates** (from Go's `text/template` package) with additional functions from the **Sprig library**. Understanding Go templating is essential for creating powerful, flexible Helm charts.

---

### Template Basics - Syntax

```
┌─────────────────────────────────────────────────────────────┐
│                 GO TEMPLATE SYNTAX                          │
│                                                             │
│   {{ }}     - Template action (outputs value)               │
│   {{- }}    - Trim whitespace BEFORE                        │
│   {{ -}}    - Trim whitespace AFTER                         │
│   {{- -}}   - Trim whitespace BOTH sides                    │
│                                                             │
│   {{ /* comment */ }}  - Template comment                   │
└─────────────────────────────────────────────────────────────┘
```

**Whitespace Control Example:**
```yaml
# Without trim (extra blank lines)
metadata:
  labels:
{{ if .Values.team }}
    team: {{ .Values.team }}
{{ end }}

# With trim (clean output)
metadata:
  labels:
{{- if .Values.team }}
    team: {{ .Values.team }}
{{- end }}
```

---

### Built-in Objects (Data Sources)

| Object | Description | Example |
|--------|-------------|---------|
| `.Values` | Values from values.yaml & --set | `{{ .Values.replicaCount }}` |
| `.Release` | Release information | `{{ .Release.Name }}` |
| `.Chart` | Chart.yaml contents | `{{ .Chart.Name }}` |
| `.Files` | Access non-template files | `{{ .Files.Get "config.ini" }}` |
| `.Capabilities` | Cluster capabilities | `{{ .Capabilities.KubeVersion }}` |
| `.Template` | Current template info | `{{ .Template.Name }}` |

---

### .Release Object Properties

```yaml
{{ .Release.Name }}        # helm install MYRELEASE ./chart
{{ .Release.Namespace }}   # Target namespace
{{ .Release.IsInstall }}   # true if install (not upgrade)
{{ .Release.IsUpgrade }}   # true if upgrade
{{ .Release.Revision }}    # Revision number (1, 2, 3...)
{{ .Release.Service }}     # Always "Helm"
```

**Example Usage:**
```yaml
metadata:
  name: {{ .Release.Name }}-config
  namespace: {{ .Release.Namespace }}
  annotations:
    helm.sh/revision: {{ .Release.Revision | quote }}
    {{- if .Release.IsUpgrade }}
    upgraded-at: {{ now | date "2006-01-02T15:04:05Z07:00" }}
    {{- end }}
```

---

### .Chart Object Properties

```yaml
{{ .Chart.Name }}           # From Chart.yaml name field
{{ .Chart.Version }}        # Chart version (e.g., "1.0.0")
{{ .Chart.AppVersion }}     # App version (e.g., "2.1.0")
{{ .Chart.Description }}    # Chart description
{{ .Chart.Type }}           # "application" or "library"
{{ .Chart.Keywords }}       # List of keywords
{{ .Chart.Home }}           # Project home URL
{{ .Chart.Sources }}        # List of source URLs
```

---

### Variables - Declaring and Using

```yaml
# Declare a variable with :=
{{- $name := .Release.Name -}}
{{- $namespace := .Release.Namespace -}}
{{- $fullname := printf "%s-%s" .Release.Name .Chart.Name -}}

# Use variables
metadata:
  name: {{ $fullname }}
  namespace: {{ $namespace }}
  labels:
    release: {{ $name }}
```

**Variable Scope in Loops:**
```yaml
# $ always refers to root scope
{{- range .Values.containers }}
  # . is now the current container
  - name: {{ .name }}
    # Use $ to access root values
    release: {{ $.Release.Name }}
{{- end }}
```

---

### Conditionals (if/else)

**Basic If:**
```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{- end }}
```

**If-Else:**
```yaml
spec:
  type: {{ if .Values.service.nodePort }}NodePort{{ else }}ClusterIP{{ end }}
```

**If-Else If-Else:**
```yaml
{{- if eq .Values.env "production" }}
  replicas: 5
{{- else if eq .Values.env "staging" }}
  replicas: 3
{{- else }}
  replicas: 1
{{- end }}
```

**Logical Operators:**
```yaml
# AND
{{- if and .Values.ingress.enabled .Values.ingress.tls.enabled }}

# OR
{{- if or .Values.service.nodePort .Values.service.loadBalancer }}

# NOT
{{- if not .Values.autoscaling.enabled }}

# Combined
{{- if and .Values.ingress.enabled (not .Values.ingress.tls.enabled) }}
```

---

### Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equal | `{{ if eq .Values.env "prod" }}` |
| `ne` | Not equal | `{{ if ne .Values.replicas 0 }}` |
| `lt` | Less than | `{{ if lt .Values.replicas 3 }}` |
| `le` | Less or equal | `{{ if le .Values.replicas 3 }}` |
| `gt` | Greater than | `{{ if gt .Values.replicas 1 }}` |
| `ge` | Greater or equal | `{{ if ge .Values.replicas 1 }}` |

**Examples:**
```yaml
{{- if eq .Values.environment "production" }}
  resources:
    limits:
      cpu: "2000m"
{{- end }}

{{- if gt (len .Values.hosts) 0 }}
  # Only if hosts list is not empty
{{- end }}

{{- if and (ge .Values.replicas 3) (eq .Values.env "prod") }}
  # Production with HA
{{- end }}
```

---

### Loops (range)

**Loop Over List:**
```yaml
# values.yaml
hosts:
  - app.example.com
  - api.example.com
  - admin.example.com

# template
spec:
  rules:
    {{- range .Values.hosts }}
    - host: {{ . }}    # . is current item
      http:
        paths:
          - path: /
    {{- end }}
```

**Loop with Index:**
```yaml
{{- range $index, $host := .Values.hosts }}
  - host: {{ $host }}
    # $index is 0, 1, 2...
{{- end }}
```

**Loop Over Map:**
```yaml
# values.yaml
env:
  DATABASE_URL: "postgres://..."
  REDIS_HOST: "redis:6379"
  LOG_LEVEL: "info"

# template
env:
  {{- range $key, $value := .Values.env }}
  - name: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}
```

**Loop with Conditional:**
```yaml
{{- range .Values.containers }}
{{- if .enabled }}
  - name: {{ .name }}
    image: {{ .image }}
{{- end }}
{{- end }}
```

---

### Pipelines (|)

Pipelines pass the output of one function to the next:

```yaml
# Single pipeline
{{ .Values.image.tag | quote }}

# Multiple pipelines
{{ .Values.name | lower | trunc 63 | trimSuffix "-" }}

# Complex pipeline
{{ .Values.resources | toYaml | nindent 12 }}
```

---

### Essential Functions

#### String Functions

```yaml
# quote - Add quotes
image: {{ .Values.image.tag | quote }}           # "v1.0.0"

# upper / lower - Case conversion
name: {{ .Values.name | upper }}                  # MYAPP
name: {{ .Values.name | lower }}                  # myapp

# title - Title case
name: {{ .Values.name | title }}                  # Myapp

# trunc - Truncate string
name: {{ .Values.name | trunc 63 }}               # Max 63 chars

# trimSuffix / trimPrefix - Remove suffix/prefix
name: {{ .Values.name | trimSuffix "-" }}         # Remove trailing -
name: {{ .Values.name | trimPrefix "app-" }}      # Remove leading app-

# replace - Replace substring
name: {{ .Values.name | replace "_" "-" }}        # Underscores to dashes

# contains - Check if contains
{{- if contains "prod" .Values.env }}

# hasPrefix / hasSuffix
{{- if hasPrefix "prod" .Values.env }}
{{- if hasSuffix "-svc" .Values.name }}

# printf / sprintf - Format string
name: {{ printf "%s-%s" .Release.Name .Chart.Name }}

# indent / nindent - Add indentation
# indent: adds spaces to all lines
# nindent: adds newline THEN indents
resources:
{{ .Values.resources | toYaml | indent 2 }}

resources:
  {{- .Values.resources | toYaml | nindent 2 }}
```

---

#### Type Conversion Functions

```yaml
# toString - Convert to string
port: {{ .Values.port | toString }}

# toJson - Convert to JSON
data: {{ .Values.config | toJson }}

# toYaml - Convert to YAML (most used!)
resources:
  {{- toYaml .Values.resources | nindent 2 }}

# fromYaml / fromJson - Parse YAML/JSON
{{- $config := .Files.Get "config.yaml" | fromYaml }}

# int / int64 / float64 - Number conversion
replicas: {{ .Values.replicas | int }}

# atoi - String to int (ASCII to Integer)
port: {{ .Values.portString | atoi }}
```

---

#### Default Values

```yaml
# default - Provide fallback value
replicas: {{ .Values.replicas | default 1 }}
image: {{ .Values.image.tag | default "latest" }}
env: {{ .Values.environment | default "development" }}

# Chained defaults
port: {{ .Values.service.port | default .Values.containerPort | default 8080 }}

# default with complex types
resources:
  {{- toYaml (.Values.resources | default .Values.defaultResources) | nindent 2 }}

# required - Fail if value missing
image: {{ required "image.repository is required" .Values.image.repository }}
```

---

#### List Functions

```yaml
# first / last - Get first/last element
firstHost: {{ first .Values.hosts }}
lastHost: {{ last .Values.hosts }}

# rest - All except first
{{- range rest .Values.hosts }}

# initial - All except last
{{- range initial .Values.hosts }}

# append / prepend - Add to list
{{- $hosts := append .Values.hosts "new.example.com" }}

# concat - Merge lists
{{- $allHosts := concat .Values.hosts .Values.additionalHosts }}

# has - Check if list contains value
{{- if has "admin" .Values.roles }}

# uniq - Remove duplicates
{{- range uniq .Values.hosts }}

# sortAlpha - Sort alphabetically
{{- range sortAlpha .Values.hosts }}

# len - Get length
{{- if gt (len .Values.hosts) 0 }}
```

---

#### Dictionary (Map) Functions

```yaml
# dict - Create a dictionary
{{- $labels := dict "app" .Release.Name "version" .Chart.Version }}

# merge - Merge dictionaries (right wins)
{{- $merged := merge .Values.labels .Values.defaultLabels }}

# hasKey - Check if key exists
{{- if hasKey .Values "nodeSelector" }}

# keys / values - Get keys/values as list
{{- range keys .Values.env }}

# pick / omit - Select/exclude keys
{{- $subset := pick .Values.labels "app" "version" }}
{{- $subset := omit .Values.labels "internal" "debug" }}

# get - Get value by key (with default)
team: {{ get .Values.labels "team" | default "unknown" }}

# set - Set value in dict (modifies in place)
{{- $_ := set .Values.labels "managed-by" "helm" }}

# pluck - Get values from list of dicts
{{- range .Values.containers }}
  {{- pluck "port" . }}
{{- end }}
```

---

#### Flow Control Functions

```yaml
# empty - Check if value is empty/nil/zero
{{- if not (empty .Values.annotations) }}
  annotations:
    {{- toYaml .Values.annotations | nindent 4 }}
{{- end }}

# coalesce - Return first non-empty value
image: {{ coalesce .Values.image.tag .Chart.AppVersion "latest" }}

# ternary - Inline if-else
replicas: {{ ternary 5 1 .Values.highAvailability }}
# If highAvailability is true: 5, else: 1

# fail - Abort template rendering
{{- if not .Values.image.repository }}
{{- fail "image.repository is required!" }}
{{- end }}
```

---

#### Date/Time Functions

```yaml
# now - Current time
deployedAt: {{ now | date "2006-01-02T15:04:05Z07:00" }}

# date - Format time
# Go uses reference date: Mon Jan 2 15:04:05 MST 2006
timestamp: {{ now | date "2006-01-02" }}      # 2026-01-29
timestamp: {{ now | date "20060102150405" }}  # 20260129143022

# dateModify - Add/subtract time
expiresAt: {{ now | dateModify "+24h" | date "2006-01-02" }}

# ago - Time since
age: {{ .Values.createdAt | ago }}  # "2h30m"
```

---

#### Cryptographic Functions

```yaml
# sha256sum - SHA256 hash
checksum: {{ .Values.config | toYaml | sha256sum }}

# b64enc / b64dec - Base64 encode/decode
encoded: {{ .Values.password | b64enc }}
decoded: {{ .Values.encodedData | b64dec }}

# randAlphaNum - Random string
secret: {{ randAlphaNum 32 }}

# genPrivateKey - Generate private key
key: {{ genPrivateKey "rsa" }}

# derivePassword - Derive password (bcrypt)
password: {{ derivePassword 1 "long" .Values.secret .Values.user "example.com" }}
```

---

### Named Templates (define/include)

**Define in _helpers.tpl:**
```yaml
{{/*
Create chart name and version for chart label
*/}}
{{- define "myapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "myapp.labels" -}}
helm.sh/chart: {{ include "myapp.chart" . }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "myapp.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account
*/}}
{{- define "myapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "myapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

**Use in Templates:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
```

**include vs template:**
```yaml
# include - Returns string, can be piped
{{- include "myapp.labels" . | nindent 4 }}

# template - Outputs directly, cannot be piped (avoid using)
{{ template "myapp.labels" . }}
```

---

### with Block (Scope Change)

The `with` action sets the scope (`.`) to a specific value:

```yaml
# Without with
env:
  {{- if .Values.database }}
  - name: DB_HOST
    value: {{ .Values.database.host }}
  - name: DB_PORT
    value: {{ .Values.database.port | quote }}
  - name: DB_NAME
    value: {{ .Values.database.name }}
  {{- end }}

# With 'with' - cleaner!
{{- with .Values.database }}
env:
  - name: DB_HOST
    value: {{ .host }}
  - name: DB_PORT
    value: {{ .port | quote }}
  - name: DB_NAME
    value: {{ .name }}
{{- end }}
```

**Accessing Root Scope Inside with:**
```yaml
{{- with .Values.database }}
  - name: DB_HOST
    value: {{ .host }}
  # Use $ to access root
  - name: RELEASE_NAME
    value: {{ $.Release.Name }}
{{- end }}
```

---

### Accessing Files

**Reading Files:**
```yaml
# Get file content as string
data:
  config.ini: |
    {{ .Files.Get "config/app.ini" | nindent 4 }}

# Get as base64
data:
  logo.png: {{ .Files.Get "files/logo.png" | b64enc }}

# Glob pattern - get multiple files
{{- range $path, $_ := .Files.Glob "config/*.yaml" }}
  {{ $path }}: |
    {{ $.Files.Get $path | nindent 4 }}
{{- end }}
```

**ConfigMap from Files:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  {{- (.Files.Glob "config/*").AsConfig | nindent 2 }}
```

**Secret from Files:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-certs
type: Opaque
data:
  {{- (.Files.Glob "certs/*").AsSecrets | nindent 2 }}
```

---

### tpl Function (Render Strings as Templates)

When values.yaml contains template syntax:

```yaml
# values.yaml
image:
  repository: myregistry/myapp
  tag: "{{ .Chart.AppVersion }}"  # Template in values!

fullnameOverride: "{{ .Release.Name }}-app"

annotations:
  description: "Deployed {{ .Release.Name }} to {{ .Release.Namespace }}"
```

```yaml
# template - Use tpl to render
metadata:
  name: {{ tpl .Values.fullnameOverride . }}
  annotations:
    description: {{ tpl .Values.annotations.description . }}
spec:
  containers:
    - image: "{{ .Values.image.repository }}:{{ tpl .Values.image.tag . }}"
```

---

### Lookup Function (Query Cluster)

Query existing Kubernetes resources during template rendering:

```yaml
# Check if secret exists
{{- $secret := lookup "v1" "Secret" .Release.Namespace "existing-secret" }}
{{- if $secret }}
  # Secret exists, reference it
  secretName: existing-secret
{{- else }}
  # Create new secret
  secretName: {{ .Release.Name }}-secret
{{- end }}

# Get all services in namespace
{{- range (lookup "v1" "Service" .Release.Namespace "").items }}
  # {{ .metadata.name }}
{{- end }}

# lookup returns empty dict {} during helm template (no cluster)
```

---

### Debug Techniques

```bash
# Render templates locally
helm template myrelease ./mychart

# With values file
helm template myrelease ./mychart -f values-dev.yaml

# Show only specific template
helm template myrelease ./mychart -s templates/deployment.yaml

# Debug mode (verbose output)
helm template myrelease ./mychart --debug

# Dry-run against cluster (validates resources)
helm install myrelease ./mychart --dry-run --debug

# Lint chart
helm lint ./mychart

# Get rendered values
helm get values myrelease
helm get values myrelease --all  # Including defaults
```

**Print Debug in Template:**
```yaml
# Temporarily print variable value
{{ printf "%#v" .Values.resources }}

# Print type
{{ printf "%T" .Values.replicas }}

# Comment-style debug (appears in rendered YAML as comment)
# DEBUG: replicas = {{ .Values.replicaCount }}
```

---

### Common Patterns & Recipes

#### Pattern 1: Optional Blocks
```yaml
{{- if .Values.nodeSelector }}
nodeSelector:
  {{- toYaml .Values.nodeSelector | nindent 2 }}
{{- end }}

{{- if .Values.tolerations }}
tolerations:
  {{- toYaml .Values.tolerations | nindent 2 }}
{{- end }}

{{- if .Values.affinity }}
affinity:
  {{- toYaml .Values.affinity | nindent 2 }}
{{- end }}
```

#### Pattern 2: Merge with Defaults
```yaml
# values.yaml
defaultResources:
  limits:
    cpu: 100m
    memory: 128Mi

# template
resources:
  {{- toYaml (merge .Values.resources .Values.defaultResources) | nindent 2 }}
```

#### Pattern 3: Environment-Aware Logic
```yaml
{{- if eq .Values.environment "production" }}
  replicas: 5
  resources:
    limits:
      cpu: "2"
      memory: "4Gi"
{{- else if eq .Values.environment "staging" }}
  replicas: 2
  resources:
    limits:
      cpu: "500m"
      memory: "1Gi"
{{- else }}
  replicas: 1
  resources:
    limits:
      cpu: "100m"
      memory: "256Mi"
{{- end }}
```

#### Pattern 4: ConfigMap Checksum for Rollout
```yaml
# Force pod restart when ConfigMap changes
spec:
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
```

#### Pattern 5: Secret Data
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-secrets
type: Opaque
data:
  {{- range $key, $value := .Values.secrets }}
  {{ $key }}: {{ $value | b64enc | quote }}
  {{- end }}
stringData:
  {{- range $key, $value := .Values.secretsPlain }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

#### Pattern 6: Multi-Container Pod
```yaml
spec:
  containers:
    {{- range .Values.containers }}
    - name: {{ .name }}
      image: "{{ .image.repository }}:{{ .image.tag }}"
      ports:
        {{- range .ports }}
        - containerPort: {{ . }}
        {{- end }}
      {{- if .resources }}
      resources:
        {{- toYaml .resources | nindent 8 }}
      {{- end }}
    {{- end }}
```

#### Pattern 7: Image Pull Secrets
```yaml
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}

# Or create if registry auth provided
{{- if .Values.registry.auth }}
imagePullSecrets:
  - name: {{ .Release.Name }}-regcred
{{- end }}
```

---

### Go Template Cheat Sheet

| Category | Function | Example |
|----------|----------|---------|
| **Strings** | `quote` | `{{ .Values.tag \| quote }}` |
| | `upper/lower` | `{{ .Values.name \| lower }}` |
| | `trunc` | `{{ .Values.name \| trunc 63 }}` |
| | `trimSuffix` | `{{ .Values.name \| trimSuffix "-" }}` |
| | `replace` | `{{ .Values.name \| replace "_" "-" }}` |
| **Types** | `toYaml` | `{{ toYaml .Values.res \| nindent 2 }}` |
| | `toJson` | `{{ toJson .Values.config }}` |
| | `toString` | `{{ .Values.port \| toString }}` |
| **Defaults** | `default` | `{{ .Values.tag \| default "latest" }}` |
| | `required` | `{{ required "msg" .Values.x }}` |
| | `coalesce` | `{{ coalesce .a .b "default" }}` |
| **Logic** | `if/else` | `{{- if .Values.x }}...{{- end }}` |
| | `eq/ne/lt/gt` | `{{ if eq .Values.env "prod" }}` |
| | `and/or/not` | `{{ if and .a .b }}` |
| | `empty` | `{{ if not (empty .Values.x) }}` |
| | `ternary` | `{{ ternary "a" "b" .Values.x }}` |
| **Loops** | `range` | `{{- range .Values.list }}` |
| | `range $i,$v` | `{{- range $i, $v := .list }}` |
| **Lists** | `first/last` | `{{ first .Values.hosts }}` |
| | `has` | `{{ if has "x" .Values.list }}` |
| | `len` | `{{ len .Values.list }}` |
| **Dicts** | `dict` | `{{ $d := dict "a" 1 "b" 2 }}` |
| | `hasKey` | `{{ if hasKey .Values "key" }}` |
| | `merge` | `{{ merge .a .b }}` |
| **Format** | `printf` | `{{ printf "%s-%s" .a .b }}` |
| | `indent` | `{{ .x \| indent 4 }}` |
| | `nindent` | `{{ .x \| nindent 4 }}` |
| **Scope** | `with` | `{{- with .Values.db }}` |
| | `$` | `{{ $.Release.Name }}` (root) |
| **Include** | `include` | `{{ include "name" . \| nindent 4 }}` |
| | `tpl` | `{{ tpl .Values.tmpl . }}` |

---

### Real-World: Complete Deployment Template

```yaml
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
    helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
  {{- with .Values.deploymentAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount | default 1 }}
  {{- end }}
  {{- with .Values.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .Chart.Name }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ .Chart.Name }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ .Values.serviceAccount.name | default (include "app.fullname" .) }}
      {{- with .Values.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          {{- with .Values.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" }}
          {{- with .Values.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          ports:
            {{- range .Values.ports }}
            - name: {{ .name }}
              containerPort: {{ .containerPort }}
              protocol: {{ .protocol | default "TCP" }}
            {{- end }}
          {{- if or .Values.env .Values.envFrom }}
          {{- with .Values.env }}
          env:
            {{- range $key, $value := . }}
            - name: {{ $key }}
              {{- if kindIs "map" $value }}
              {{- toYaml $value | nindent 14 }}
              {{- else }}
              value: {{ $value | quote }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- with .Values.envFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- with .Values.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          resources:
            {{- toYaml (.Values.resources | default dict) | nindent 12 }}
          {{- with .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
      {{- with .Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

This template handles all common deployment scenarios with proper conditionals, defaults, and flexibility!

---

## Helm Best Practices vs Bad Practices

### App Version vs Chart Version

| Field | Location | Purpose | Example |
|-------|----------|---------|---------|
| `version` | Chart.yaml | **Chart version** - Version of the Helm chart itself (packaging) | `1.2.0` |
| `appVersion` | Chart.yaml | **Application version** - Version of the app being deployed | `v2.5.3` |

```yaml
# Chart.yaml
apiVersion: v2
name: myapp
version: 1.2.0        # Chart version - bump when chart changes
appVersion: "v2.5.3"  # App version - version of your actual application
```

**Key Differences:**
- **Chart version** changes when you modify templates, values, or chart structure
- **App version** changes when your application code/image changes
- They are **independent** - you can update chart without changing app, and vice versa

---

### ✅ Best Practices

| Category | Best Practice |
|----------|---------------|
| **Naming** | Use lowercase, hyphenated names (`my-app`, not `MyApp` or `my_app`) |
| **Versioning** | Follow SemVer for chart version (`MAJOR.MINOR.PATCH`) |
| **Values** | Provide sensible defaults in `values.yaml` |
| **Values** | Document all values with comments |
| **Values** | Use flat structure when possible, nest only when logical |
| **Templates** | Use `_helpers.tpl` for reusable template functions |
| **Templates** | Always use `{{- ` and ` -}}` for whitespace control |
| **Templates** | Use `quote` function for string values |
| **Labels** | Use standard Kubernetes labels (`app.kubernetes.io/*`) |
| **Resources** | Always define resource requests/limits |
| **Security** | Never hardcode secrets in values.yaml |
| **Testing** | Always run `helm lint` before deploying |
| **Testing** | Use `helm template --debug` to preview output |
| **Dependencies** | Pin dependency versions in Chart.yaml |
| **NOTES.txt** | Provide helpful post-install instructions |

---

### ❌ Bad Practices

| Bad Practice | Why It's Bad | Better Approach |
|--------------|--------------|-----------------|
| Hardcoding values in templates | Can't customize per environment | Use `{{ .Values.xxx }}` |
| Storing secrets in values.yaml | Security risk - secrets in Git | Use external secrets, sealed-secrets, or secretRef |
| Not using `quote` for strings | Special characters break YAML | `{{ .Values.name \| quote }}` |
| Ignoring whitespace control | Produces invalid/ugly YAML | Use `{{-` and `-}}` |
| Skipping `helm lint` | Deploys broken charts | Always lint before install |
| No default values | Chart fails without overrides | Provide sensible defaults |
| Monolithic values.yaml | Hard to manage environments | Split into `values-dev.yaml`, `values-prod.yaml` |
| Not using helpers | Duplicate code in templates | Create `_helpers.tpl` |
| Hardcoding release name | Name collisions | Use `{{ .Release.Name }}` |
| No resource limits | Pods can consume all resources | Always set limits/requests |
| Using `latest` tag | Non-deterministic deployments | Pin specific image tags |
| Not versioning charts | Can't rollback to known state | Bump version on every change |
| Skipping NOTES.txt | Users don't know what happened | Add connection/usage info |
| Deep nesting in values | Complex to access | Keep structure flat when possible |

---

### Example: Good vs Bad

**❌ Bad:**
```yaml
# templates/deployment.yaml
containers:
  - name: myapp
    image: myregistry/myapp:latest    # Hardcoded!
    env:
      - name: DB_PASSWORD
        value: "supersecret123"        # Secret in plain text!
```

**✅ Good:**
```yaml
# values.yaml
image:
  repository: myregistry/myapp
  tag: "v1.2.3"
secretRef:
  name: myapp-secrets

# templates/deployment.yaml
containers:
  - name: {{ .Chart.Name }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    envFrom:
      - secretRef:
          name: {{ .Values.secretRef.name }}
```

---

### Version Bumping Rules

| Change Type | Bump | Example |
|-------------|------|---------|
| Breaking changes (new required values) | MAJOR | `1.0.0` → `2.0.0` |
| New features (backward compatible) | MINOR | `1.0.0` → `1.1.0` |
| Bug fixes, doc changes | PATCH | `1.0.0` → `1.0.1` |
| App update only (no chart changes) | appVersion only | Keep chart `1.0.0`, update appVersion |

---

## Helm History & Governance (Quick Reference)

### 🕐 Timeline

| Year | Milestone |
|------|-----------|
| **2015** | Created at **Deis** (acquired by Microsoft) |
| **2016** | Helm v2 released (with Tiller) |
| **2018** | Donated to **CNCF** |
| **2019** | Became **CNCF Graduated Project** |
| **2020** | Helm v3 (Tiller removed, improved security) |
| **2024** | Helm v4 released |

### 👥 Key People

| Person | Role |
|--------|------|
| **Matt Butcher** | Original creator |
| **Matt Farina** | Core maintainer |
| **Josh Dolitsky** | Major contributor |

### 🏢 Maintainers & Sponsors

- **CNCF** - Governance
- **Microsoft** - Major sponsor (acquired Deis)
- **VMware** - Core maintainers
- **Bitnami** - Gold standard charts (owned by VMware)

### 📚 Best Practice Sources

| Source | URL |
|--------|-----|
| Official Docs | helm.sh/docs/chart_best_practices |
| Artifact Hub | artifacthub.io |
| Bitnami Charts | github.com/bitnami/charts |

---

## _helpers.tpl - Complete Guide

### What is `_helpers.tpl`?

| Aspect | Description |
|--------|-------------|
| **Purpose** | Reusable template snippets (functions) |
| **Prefix `_`** | Tells Helm: "Don't render as K8s resource" |
| **Location** | `templates/_helpers.tpl` |

### Template Syntax Cheatsheet

| Syntax | Meaning |
|--------|---------|
| `{{- ... }}` | Trim whitespace **before** |
| `{{ ... -}}` | Trim whitespace **after** |
| `{{/* comment */}}` | Comment (not rendered) |
| `define "name"` | Create named template |
| `include "name" .` | Call template (preferred ✅) |
| `template "name" .` | Call template (legacy ❌) |

### Standard Functions to Define

```yaml
{{/*
1. Chart name (short)
*/}}
{{- define "mychart.name" -}}
{{- .Values.name | default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
2. Fully qualified name (release + chart)
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
3. Chart label (name + version)
*/}}
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
4. Common labels (all resources)
*/}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mychart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
5. Selector labels (IMMUTABLE - don't change after deploy!)
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
6. Service account name
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mychart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
7. Container image with tag
*/}}
{{- define "mychart.image" -}}
{{- $repo := .Values.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" $repo $tag }}
{{- end }}
```

### How to Use in Templates

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "mychart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: {{ include "mychart.image" . }}
```

### Best Practices Summary

| Practice | Why |
|----------|-----|
| **Prefix with chart name** | Avoid collisions with subcharts |
| **Use `include` not `template`** | Allows piping (`\| nindent`) |
| **Truncate to 63 chars** | DNS label limit |
| **Keep selectorLabels minimal** | They're immutable after deploy |
| **Provide defaults** | Chart works without overrides |
| **Quote strings** | Prevents YAML parsing issues |
| **Comment every function** | Self-documenting |
| **Always pass context (`.`)** | Functions need access to .Values, .Chart |

### Quick Reference Table

| Function | Purpose | Usage |
|----------|---------|-------|
| `mychart.name` | Short name | Resource naming |
| `mychart.fullname` | Unique name | Avoid collisions |
| `mychart.chart` | Chart + version | Chart label |
| `mychart.labels` | All labels | `metadata.labels` |
| `mychart.selectorLabels` | Selector labels | `spec.selector` |
| `mychart.image` | Full image path | Container image |
- uninstalled: The release has been uninstalled and is no longer present in the cluster.    
- superseded: The release has been replaced by a newer version, but the older version is still present in the cluster.

- # Production-Grade Linux Troubleshooting Guide for DevOps/Platform Engineers

## Table of Contents
1. [System Health Check](#system-health-check)
2. [Memory Issues](#memory-issues)
3. [Process Management](#process-management)
4. [Filesystem Issues](#filesystem-issues)
5. [Log File Analysis](#log-file-analysis)
6. [Network Troubleshooting](#network-troubleshooting)
7. [CPU Issues](#cpu-issues)
8. [Disk I/O Issues](#disk-io-issues)
9. [Application-Level Debugging](#application-level-debugging)
10. [Performance Monitoring](#performance-monitoring)
11. [Container Troubleshooting](#container-troubleshooting)

---

## 1. System Health Check

### Quick System Overview
```bash
# Overall system health snapshot
uptime && free -h && df -h && top -bn1 | head -20

# System resource summary
vmstat 1 5  # 5 iterations, 1 second apart

# Load averages and CPU info
cat /proc/loadavg
lscpu | grep -E "CPU\(s\)|Model name|Thread|Core"

# Check system messages
dmesg | tail -50
dmesg -T | grep -i error

# System journal errors
journalctl -p 3 -xb  # Priority 3 = errors
```

### Service Status Check
```bash
# Check all failed services
systemctl --failed

# Check specific service status
systemctl status <service-name>
systemctl status nginx apache2 mysql docker

# List all running services
systemctl list-units --type=service --state=running

# Check service logs
journalctl -u <service-name> -f --since "1 hour ago"
```

---

## 2. Memory Issues

### Memory Analysis Commands
```bash
# Detailed memory usage
free -m
free -h --si

# Real-time memory monitoring
watch -n 1 free -h

# Memory usage by process
ps aux --sort=-%mem | head -20

# Detailed memory information
cat /proc/meminfo

# Check for OOM (Out of Memory) kills
dmesg | grep -i "out of memory"
dmesg | grep -i "killed process"
grep -i "out of memory" /var/log/messages
grep -i "killed process" /var/log/syslog

# System memory pressure
cat /proc/pressure/memory  # (Kernel 4.20+)
```

### Memory Leak Detection
```bash
# Monitor specific process memory over time
watch -n 5 'ps aux | grep <process-name>'

# Track memory usage of specific PID
while true; do ps -p <PID> -o %mem,vsz,rss,cmd; sleep 5; done

# Memory map of a process
pmap -x <PID>
cat /proc/<PID>/smaps

# Top memory-consuming processes
top -o %MEM

# Check swap usage
swapon --show
vmstat -s
cat /proc/swaps
```

### Memory Cache and Buffer Management
```bash
# Check cache and buffer usage
sync; echo 3 > /proc/sys/vm/drop_caches  # Clear PageCache, dentries, and inodes

# View memory slab info
slabtop
cat /proc/slabinfo
```

---

## 3. Process Management

### Process Monitoring
```bash
# List all processes with details
ps aux
ps -ef

# Process tree
pstree -p
ps auxf  # Forest view

# Top CPU-consuming processes
top -o %CPU
ps aux --sort=-%cpu | head -20

# Find specific process
ps aux | grep <process-name>
pgrep -a <process-name>
pidof <process-name>

# Process details
ps -p <PID> -o pid,ppid,user,%cpu,%mem,vsz,rss,cmd
```

### Process Troubleshooting
```bash
# Check zombie processes
ps aux | grep 'Z'
ps -eo stat,pid,cmd | grep '^Z'

# Check process limits
cat /proc/<PID>/limits

# Check open file descriptors
lsof -p <PID>
ls -la /proc/<PID>/fd | wc -l

# Check process threads
ps -eLf | grep <PID>
cat /proc/<PID>/status | grep Threads

# Trace system calls
strace -p <PID>
strace -c -p <PID>  # Summary of syscalls

# Real-time process monitoring
htop
atop
```

### Process Control
```bash
# Kill process gracefully
kill -15 <PID>
kill -TERM <PID>

# Force kill
kill -9 <PID>
kill -KILL <PID>

# Kill all processes by name
pkill <process-name>
killall <process-name>

# Change process priority
renice -n -5 -p <PID>
nice -n 10 <command>
```

---

## 4. Filesystem Issues

### Disk Space Analysis
```bash
# Disk usage summary
df -h
df -i  # Inode usage

# Directory size
du -sh /path/to/directory
du -h --max-depth=1 /path | sort -hr

# Find large files
find /path -type f -size +100M -exec ls -lh {} \;
find /path -type f -size +100M -exec du -h {} \; | sort -hr | head -20

# Largest directories
du -h /path | sort -hr | head -20
ncdu /path  # Interactive disk usage analyzer
```

### Inode Issues
```bash
# Check inode usage
df -i

# Find directories with most files
for dir in /*; do echo "$dir:"; find "$dir" -maxdepth 1 | wc -l; done

# Find inode-consuming directories
find /path -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n

# Check filesystem inode limits
tune2fs -l /dev/sda1 | grep -i inode
```

### Filesystem Health
```bash
# Check filesystem for errors (unmount first or use -n for read-only)
fsck -n /dev/sda1

# Check disk health with SMART
smartctl -H /dev/sda
smartctl -a /dev/sda

# Check for disk errors
dmesg | grep -i "I/O error"
grep -i "error\|fail" /var/log/messages

# Mount information
mount | column -t
cat /proc/mounts
findmnt
```

### File Operations
```bash
# Find recently modified files
find /var/log -type f -mtime -1
find /path -type f -mmin -60  # Last 60 minutes

# Find files by user
find /path -user username

# Check file locks
lsof | grep <filename>
fuser -v <filename>

# List open files
lsof
lsof +D /path  # All open files in directory
```

---

## 5. Log File Analysis

### System Logs
```bash
# Main system log locations
/var/log/syslog       # Debian/Ubuntu
/var/log/messages     # RHEL/CentOS
/var/log/kern.log     # Kernel logs
/var/log/auth.log     # Authentication logs
/var/log/boot.log     # Boot logs
/var/log/dmesg        # Hardware and driver messages

# View system logs
tail -f /var/log/syslog
tail -100 /var/log/syslog | grep -i error

# Search for errors in all logs
grep -i "error\|fail\|critical" /var/log/syslog
grep -i "error\|fail\|critical" /var/log/messages
```

### Systemd Journal (journalctl)
```bash
# View all logs
journalctl

# Real-time logs
journalctl -f

# Logs since boot
journalctl -b
journalctl -b -1  # Previous boot

# Priority filtering
journalctl -p err    # Errors only
journalctl -p warning  # Warnings and above

# Time-based filtering
journalctl --since "2025-01-28 10:00:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --until "2025-01-28 12:00:00"

# Service-specific logs
journalctl -u nginx.service
journalctl -u nginx.service --since today

# Kernel messages
journalctl -k

# Show disk usage
journalctl --disk-usage

# Clean old logs
journalctl --vacuum-time=7d
journalctl --vacuum-size=500M
```

### Application Logs
```bash
# Common application log locations
/var/log/nginx/        # Nginx
/var/log/apache2/      # Apache
/var/log/mysql/        # MySQL
/var/log/postgresql/   # PostgreSQL
/var/log/docker/       # Docker

# Monitor application log
tail -f /var/log/nginx/error.log
tail -f /var/log/application/app.log

# Search application logs
grep -i "exception\|error\|fail" /var/log/application/app.log
```

### Log Analysis Tools
```bash
# Count error occurrences
grep -c "error" /var/log/syslog

# Extract unique errors
grep "error" /var/log/syslog | sort | uniq -c | sort -nr

# Filter by timestamp
awk '$0 ~ /Jan 28.*error/' /var/log/syslog

# Multi-line log parsing with context
grep -A 5 -B 5 "OutOfMemoryError" /var/log/application.log

# Combine multiple log files
cat /var/log/syslog* | grep "error"

# Log rotation check
ls -lh /var/log/*.gz
```

---

## 6. Network Troubleshooting

### Network Connectivity
```bash
# Check network interfaces
ip addr show
ifconfig -a
ip link show

# Test connectivity
ping -c 4 google.com
ping -c 4 8.8.8.8

# DNS resolution
nslookup google.com
dig google.com
host google.com

# Trace route
traceroute google.com
mtr google.com  # Real-time traceroute
```

### Port and Socket Debugging
```bash
# Check listening ports
netstat -tulpn
ss -tulpn
lsof -i

# Check specific port
netstat -tulpn | grep :80
ss -tulpn | grep :443
lsof -i :8080

# Active connections
netstat -an
ss -an

# Connection states
netstat -tan | awk '{print $6}' | sort | uniq -c

# Check which process is using a port
lsof -i :port
fuser -n tcp port
```

### Network Performance
```bash
# Network statistics
netstat -s
ss -s

# Interface statistics
ip -s link
ifconfig

# Bandwidth monitoring
iftop
nload
bmon

# Packet capture
tcpdump -i eth0 port 80
tcpdump -i any -w capture.pcap
```

### Firewall and Routing
```bash
# Check firewall rules
iptables -L -n -v
ufw status verbose

# Routing table
ip route show
route -n
netstat -rn

# ARP table
ip neigh show
arp -a
```

---

## 7. CPU Issues

### CPU Monitoring
```bash
# CPU usage
top
htop
mpstat 1 5  # 5 iterations

# Per-CPU statistics
mpstat -P ALL 1

# CPU load over time
uptime
cat /proc/loadavg
w

# Detailed CPU info
lscpu
cat /proc/cpuinfo
```

### High CPU Investigation
```bash
# Top CPU consumers
ps aux --sort=-%cpu | head -20
top -o %CPU

# CPU usage by process over time
pidstat 1 10  # 10 iterations, 1 second apart

# CPU usage per core
mpstat -P ALL 1

# Process CPU affinity
taskset -cp <PID>

# Context switches
vmstat 1 5
pidstat -w 1 10

# System calls causing CPU load
strace -c -p <PID>
```

---

## 8. Disk I/O Issues

### I/O Monitoring
```bash
# I/O statistics
iostat -x 1 5
iostat -xz 1 5  # Hide zero-activity devices

# Per-process I/O
iotop
iotop -o  # Only show active I/O

# I/O wait time
vmstat 1 5  # Check 'wa' column

# Disk latency
ioping /dev/sda
```

### Identify I/O Issues
```bash
# Processes with most I/O
iotop -oPa

# Per-process I/O statistics
pidstat -d 1 10

# Check I/O scheduler
cat /sys/block/sda/queue/scheduler

# Disk queue depth
cat /sys/block/sda/queue/nr_requests

# Iowait per CPU
mpstat -P ALL 1
```

---

## 9. Application-Level Debugging

### Java Applications
```bash
# Java process info
jps -lv
jinfo <PID>

# Java thread dump
jstack <PID>
kill -3 <PID>  # Prints to stdout/logs

# Java heap dump
jmap -dump:format=b,file=heap.bin <PID>
jmap -heap <PID>

# Java GC logs
jstat -gc <PID> 1000 10  # Every 1 second, 10 times
jstat -gcutil <PID> 1000

# Monitor Java application
jconsole
jvisualvm
```

### Python Applications
```bash
# Python process debugging
py-spy top --pid <PID>
py-spy record -o profile.svg --pid <PID>

# Python memory profiling
memory_profiler

# Check Python version
python --version
python3 --version
```

### Application Environment
```bash
# Check environment variables
env
printenv

# Process environment
cat /proc/<PID>/environ | tr '\0' '\n'

# Library dependencies
ldd /path/to/binary

# Check application configuration
cat /etc/app/config
```

---

## 10. Performance Monitoring

### System Performance Tools
```bash
# All-in-one performance tool
htop
atop
glances

# System activity reporter (sar)
sar -u 1 10  # CPU usage
sar -r 1 10  # Memory usage
sar -n DEV 1 10  # Network stats
sar -d 1 10  # Disk stats

# Performance counters
perf top
perf stat -a sleep 10
```

### Long-term Monitoring
```bash
# Enable system accounting
sar -A  # All statistics

# Historical data
sar -f /var/log/sa/sa28

# System resource usage
atop -r  # Read previous logs
```

---

## 11. Container Troubleshooting

### Docker Debugging
```bash
# List containers
docker ps -a

# Container logs
docker logs <container-id>
docker logs -f <container-id>
docker logs --tail 100 <container-id>

# Container resource usage
docker stats
docker stats <container-id>

# Inspect container
docker inspect <container-id>

# Execute command in container
docker exec -it <container-id> bash
docker exec <container-id> ps aux

# Container processes
docker top <container-id>

# Copy files from container
docker cp <container-id>:/path/to/file /local/path
```

### Kubernetes Debugging
```bash
# Pod logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs --previous <pod-name>  # Previous crashed container

# Pod details
kubectl describe pod <pod-name>
kubectl get pod <pod-name> -o yaml

# Execute in pod
kubectl exec -it <pod-name> -- bash
kubectl exec <pod-name> -- ps aux

# Pod resource usage
kubectl top pod
kubectl top pod <pod-name>

# Node resource usage
kubectl top node

# Events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace>

# Debug pod
kubectl debug <pod-name> -it --image=busybox
```

---

## Common Troubleshooting Scenarios

### Scenario 1: High Memory Usage
```bash
# 1. Check overall memory
free -h

# 2. Identify memory hogs
ps aux --sort=-%mem | head -20

# 3. Check for OOM kills
dmesg | grep -i "out of memory"

# 4. Analyze specific process
pmap -x <PID>

# 5. Check swap usage
swapon --show
```

### Scenario 2: Disk Full
```bash
# 1. Check disk space
df -h

# 2. Find large files
du -h / | sort -hr | head -20

# 3. Clean package cache
apt clean  # Debian/Ubuntu
yum clean all  # RHEL/CentOS

# 4. Clean old logs
journalctl --vacuum-time=7d
find /var/log -name "*.gz" -mtime +30 -delete

# 5. Check deleted but open files
lsof +L1 | grep deleted
```

### Scenario 3: Application Not Responding
```bash
# 1. Check if process exists
pgrep -a <app-name>

# 2. Check process status
ps aux | grep <app-name>

# 3. Check application logs
tail -100 /var/log/<app>/error.log

# 4. Check system resources
top
free -h
df -h

# 5. Trace system calls
strace -p <PID>

# 6. Check network connectivity
netstat -tulpn | grep <port>
```

### Scenario 4: Slow Performance
```bash
# 1. Check load average
uptime

# 2. Check CPU usage
top

# 3. Check I/O wait
iostat -x 1 5

# 4. Check memory pressure
free -h
vmstat 1 5

# 5. Check network
netstat -s
iftop
```

---

## Best Practices for Production Debugging

1. **Always create backups** before making changes
2. **Document your findings** and actions taken
3. **Use read-only commands first** before making changes
4. **Monitor in real-time** while troubleshooting
5. **Check logs chronologically** from the time issue started
6. **Look for patterns** in errors and resource usage
7. **Validate fixes** before marking issue as resolved
8. **Implement monitoring** to prevent future occurrences
9. **Use version control** for configuration changes
10. **Communicate with team** during production issues

---

## Quick Reference Checklist

When troubleshooting production issues, follow this checklist:

- [ ] Check system uptime and load: `uptime`
- [ ] Check disk space: `df -h`
- [ ] Check memory usage: `free -h`
- [ ] Check CPU usage: `top`
- [ ] Check failed services: `systemctl --failed`
- [ ] Check recent errors: `journalctl -p err --since "1 hour ago"`
- [ ] Check application logs: `tail -100 /var/log/app/error.log`
- [ ] Check network connectivity: `ping`, `netstat -tulpn`
- [ ] Check for OOM kills: `dmesg | grep -i oom`
- [ ] Check disk I/O: `iostat -x 1 5`

---

## Additional Resources

### Essential Tools to Install
```bash
# Debian/Ubuntu
apt install -y htop iotop iftop sysstat ncdu nethogs strace

# RHEL/CentOS
yum install -y htop iotop iftop sysstat ncdu nethogs strace
```

### Monitoring Solutions
- **Prometheus + Grafana**: Metrics and visualization
- **ELK Stack**: Log aggregation and analysis
- **Datadog/New Relic**: Full-stack monitoring
- **Nagios/Zabbix**: Infrastructure monitoring

---

*Last Updated: January 2026*

