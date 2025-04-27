# base-app Helm Chart

## Overview
This Helm chart (***base-app***) provides a template for deploying a generic application to Azure Kubernetes Service (AKS). It includes all common Kubernetes resources such as Deployment, Service, IngressRoute (Traefik), PersistentVolumeClaim, Job, CronJob, SecretProviderClass for Azure Key Vault, and Horizontal Pod Autoscaler. All components are highly configurable via the `values.yaml` file, allowing application teams to easily tailor the deployment to their app's needs.

## Prerequisites
- **Kubernetes**: An AKS cluster (or any Kubernetes cluster) with Helm installed.
- **Traefik Ingress Controller**: The Traefik ingress controller should be installed in the cluster (for the IngressRoute resource).
- **Secrets Store CSI Driver**: If using Azure Key Vault integration, the Azure Key Vault CSI driver and its SecretProviderClass CRD must be installed in the cluster.

## Usage
1. **Add this chart** to your Helm repository or clone this repository.
2. **Customize values**: Edit the `charts/base-app/values.yaml` file to suit your application. At minimum, set the container image (`image.repository` and `image.tag`) for your app. 
3. **Enable/disable features**: Toggle the features you need (e.g., ingress, persistence, autoscaling, jobs) by setting the corresponding values.
4. **Deploy the chart** using Helm:
   ```bash
   helm install my-app charts/base-app -f my-values.yaml


# 

# AKS Universal Application Helm Chart

### charts/base-app/Chart.yaml

```yaml
apiVersion: v2
name: base-app
description: A Helm chart for a universal application deployment on AKS
type: application
version: 0.1.0
appVersion: "1.0.0"
```

### charts/base-app/values.yaml

```yaml
# Default values for the base-app Helm chart.
# This file contains default values and is fully commented to describe each field.

# Global settings
nameOverride: ""        # Provide a name to override the chart's name for resources
fullnameOverride: ""    # Provide a full name for resources (if set, it overrides the release-name and chart name combo)

# Replica count for the Deployment
replicaCount: 1

# Container image configuration
image:
  repository: nginx    # Docker image repository for the application
  tag: "latest"        # Docker image tag
  pullPolicy: IfNotPresent  # Image pull policy

# Image pull secrets for private image registries
imagePullSecrets: []    # (Optional) list of names of Kubernetes secrets for pulling images

# Service account configuration
serviceAccount:
  create: true         # Whether to create a new ServiceAccount
  name: ""             # Name of the ServiceAccount to use. If not set and create=true, a name is generated using the release name.

# Pod annotations (e.g., for monitoring or sidecar injection)
podAnnotations: {}

# Security contexts
podSecurityContext: {}   # Security context for the pod (e.g., runAsUser, fsGroup)
securityContext: {}      # Security context for the container (e.g., capabilities, runAsUser)

# Service configuration
service:
  enabled: true         # Whether to create a Service
  type: ClusterIP       # Kubernetes service type (ClusterIP, NodePort, LoadBalancer)
  port: 80              # Service port to expose
  targetPort: 80        # Container port to target (defaults to containerPort if not set)
  # Note: To map a different service port to container port, adjust port and targetPort accordingly.

# Container port (the port the application container listens on)
containerPort: 80

# Ingress (Traefik IngressRoute) configuration
ingress:
  enabled: true        # Enable Traefik IngressRoute
  host: ""             # Hostname for the ingress route (e.g., myapp.example.com)
  path: /              # Path prefix for the ingress route
  entryPoints:         # Traefik entry points to listen on
    - web
  tls:
    enabled: false     # Enable TLS for the ingress route
    secretName: ""     # Name of the TLS secret (if already provisioned)
    certResolver: ""   # If using Traefik's ACME, specify the certResolver name instead of a secret
  annotations: {}      # Annotations for the IngressRoute (if any)

# Resources (CPU/memory) for the main container
resources: {}          # e.g.,
# resources:
#   limits:
#     cpu: 100m
#     memory: 128Mi
#   requests:
#     cpu: 50m
#     memory: 64Mi

# Node scheduling configurations
nodeSelector: {}       # Node selector for pod assignment
tolerations: []        # Tolerations for pod assignment
affinity: {}           # Affinity rules for pod assignment

# Environment variables for the main container
env: []                # List of environment variables (e.g., [{name: FOO, value: BAR}])
envFrom: []            # List of sources to populate env vars (e.g., configMapRef or secretRef)
# Example:
# env:
#   - name: MY_VARIABLE
#     value: "some-value"
# envFrom:
#   - configMapRef:
#       name: my-config
#   - secretRef:
#       name: my-secret

# Liveness and readiness probes (health checks)
livenessProbe:
  enabled: true
  path: /
  port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3

readinessProbe:
  enabled: true
  path: /
  port: http
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3

# Persistent Volume Claim (PVC) for data persistence
persistence:
  enabled: false              # Enable persistence (PVC)
  name: data                  # Name identifier for the PVC (used in resource naming)
  existingClaim: ""           # If specified, use this existing PVC name and do not create a new one
  storageClass: ""            # StorageClass for the PVC (if empty, use default)
  accessModes: ["ReadWriteOnce"]  # Access modes for the PVC
  size: 1Gi                   # Size of the volume
  mountPath: "/data"          # Container path to mount the volume

# Job (one-time batch job) configuration
job:
  enabled: false             # If true, create a Job
  image:
    repository: ""          # (Optional) image for the job; if empty, defaults to the main application image
    tag: ""                 # (Optional) image tag for the job
  command: []               # (Optional) command override for the job container
  args: []                  # (Optional) args for the job container
  env: []                   # Environment variables specifically for the job
  restartPolicy: OnFailure  # Restart policy for the job (OnFailure or Never)
  backoffLimit: 6           # Backoff limit for job retries
  completions: 1            # Number of completions (jobs to run)
  parallelism: 1            # Parallelism (how many pods can run at once)

# CronJob (scheduled job) configuration
cronjob:
  enabled: false             # If true, create a CronJob
  schedule: "*/5 * * * *"    # Cron schedule (default: every 5 minutes)
  successfulJobsHistoryLimit: 3  # Number of successful job runs to keep
  failedJobsHistoryLimit: 1      # Number of failed job runs to keep
  concurrencyPolicy: Allow       # Concurrency policy (Allow, Forbid, Replace)
  suspend: false                # If true, suspend the cronjob
  image:
    repository: ""          # (Optional) image for the cronjob; if empty, defaults to the main image
    tag: ""                 # (Optional) image tag for the cronjob
  command: []               # (Optional) command override for the cronjob container
  args: []                  # (Optional) args for the cronjob container
  env: []                   # Environment variables specifically for the cronjob

# Horizontal Pod Autoscaler (HPA) configuration
hpa:
  enabled: false            # Enable HPA
  minReplicas: 1            # Minimum number of pods
  maxReplicas: 3            # Maximum number of pods
  targetCPUUtilizationPercentage: 80    # Target average CPU utilization (%)
  targetMemoryUtilizationPercentage: null # Target average memory utilization (%), if any

# Azure Key Vault CSI Driver integration
azureKeyVault:
  enabled: false            # Enable mounting secrets from Azure Key Vault via CSI driver
  usePodIdentity: false     # If true, use Azure AD Pod Identity (deprecated approach)
  useVMManagedIdentity: false  # If true, use the AKS VM's managed identity
  userAssignedIdentityID: ""   # (Optional) Client ID of user-assigned managed identity (if using)
  keyVaultName: ""          # Name of the Azure Key Vault
  tenantId: ""              # Azure Tenant ID for the Key Vault
  secrets: []               # List of secret objects to fetch from Key Vault
  # Example secret object configuration:
  # secrets:
  #   - objectName: "my-secret-name"
  #     objectType: secret         # secret, key, or cert
  #     objectVersion: ""          # specific version (optional)
  #     secretKey: "my-secret-key" # name of the key in the mounted file or synced secret (defaults to objectName if not specified)
  mountPath: "/mnt/secrets"  # Mount path in the container for the secrets
  syncSecrets: false         # If true, sync the secrets to a Kubernetes Secret as well
  syncSecretName: ""         # Name of the Kubernetes secret to create (if syncSecrets is true; if empty, a default name will be used)
```

### charts/base-app/templates/_helpers.tpl

```yaml
{{- /* Helper template for naming and labels */ -}}
{{- define "base-app.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "base-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{ .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "base-app.name" . -}}
{{- if ne $name "" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "base-app.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{- define "base-app.labels" -}}
app.kubernetes.io/name: {{ include "base-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ include "base-app.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
```

### charts/base-app/templates/deployment.yaml

```yaml
# Deployment Template
# This template deploys the main application container as a Kubernetes Deployment.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "base-app.fullname" . }}
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "base-app.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        {{ include "base-app.labels" . | nindent 8 }}
      annotations:
        {{- toYaml .Values.podAnnotations | nindent 8 }}
    spec:
      {{- if .Values.podSecurityContext }}
      securityContext:
        {{ toYaml .Values.podSecurityContext | nindent 8 }}
      {{- end }}
      {{- if .Values.serviceAccount.create }}
      serviceAccountName: {{ .Values.serviceAccount.name | default (include "base-app.fullname" .) }}
      {{- else if .Values.serviceAccount.name }}
      serviceAccountName: {{ .Values.serviceAccount.name }}
      {{- end }}
      containers:
        - name: app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.containerPort }}
          {{- if .Values.env }}
          env:
            {{- range .Values.env }}
            - name: {{ .name }}
              value: {{ quote .value }}
            {{- end }}
          {{- end }}
          {{- if .Values.envFrom }}
          envFrom:
            {{- range .Values.envFrom }}
            - {{- if .configMapRef }}
              configMapRef:
                name: {{ .configMapRef.name }}
              {{- else if .secretRef }}
              secretRef:
                name: {{ .secretRef.name }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- if .Values.resources }}
          resources:
            {{ toYaml .Values.resources | nindent 12 }}
          {{- end }}
          {{- if .Values.securityContext }}
          securityContext:
            {{ toYaml .Values.securityContext | nindent 12 }}
          {{- end }}
          {{- if .Values.livenessProbe.enabled }}
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.path }}
              port: {{ .Values.livenessProbe.port }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
            successThreshold: {{ .Values.livenessProbe.successThreshold }}
            failureThreshold: {{ .Values.livenessProbe.failureThreshold }}
          {{- end }}
          {{- if .Values.readinessProbe.enabled }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.path }}
              port: {{ .Values.readinessProbe.port }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
            successThreshold: {{ .Values.readinessProbe.successThreshold }}
            failureThreshold: {{ .Values.readinessProbe.failureThreshold }}
          {{- end }}
          {{- if or .Values.persistence.enabled .Values.azureKeyVault.enabled }}
          volumeMounts:
            {{- if .Values.persistence.enabled }}
            - name: {{ .Values.persistence.name }}
              mountPath: {{ .Values.persistence.mountPath }}
            {{- end }}
            {{- if .Values.azureKeyVault.enabled }}
            - name: secrets-store
              mountPath: {{ .Values.azureKeyVault.mountPath }}
              readOnly: true
            {{- end }}
          {{- end }}
      {{- if or .Values.azureKeyVault.enabled .Values.persistence.enabled }}
      volumes:
        {{- if .Values.azureKeyVault.enabled }}
        - name: secrets-store
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: {{ include "base-app.fullname" . }}-azure-kv
        {{- end }}
        {{- if .Values.persistence.enabled }}
        - name: {{ .Values.persistence.name }}
          persistentVolumeClaim:
            claimName: {{ if .Values.persistence.existingClaim }}{{ .Values.persistence.existingClaim }}{{ else }}{{ include "base-app.fullname" . }}-{{ .Values.persistence.name }}{{ end }}
        {{- end }}
      {{- end }}
      {{- if .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- range .Values.imagePullSecrets }}
        - name: {{ . }}
        {{- end }}
      {{- end }}
      {{- if .Values.nodeSelector }}
      nodeSelector:
        {{ toYaml .Values.nodeSelector | nindent 8 }}
      {{- end }}
      {{- if .Values.tolerations }}
      tolerations:
        {{ toYaml .Values.tolerations | nindent 8 }}
      {{- end }}
      {{- if .Values.affinity }}
      affinity:
        {{ toYaml .Values.affinity | nindent 8 }}
      {{- end }}
```

### charts/base-app/templates/service.yaml

```yaml
# Service Template
# Exposes the Deployment via a Kubernetes Service.
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "base-app.fullname" . }}
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort | default .Values.containerPort }}
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: {{ include "base-app.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

### charts/base-app/templates/ingressroute.yaml

```yaml
# IngressRoute Template (Traefik)
# Creates a Traefik IngressRoute for the application if enabled.
{{- if .Values.ingress.enabled }}
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: {{ include "base-app.fullname" . }}
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
  {{- if .Values.ingress.annotations }}
  annotations:
    {{ toYaml .Values.ingress.annotations | nindent 4 }}
  {{- end }}
spec:
  entryPoints:
    {{- range .Values.ingress.entryPoints }}
    - {{ . | quote }}
    {{- end }}
  routes:
    - match: Host(`{{ .Values.ingress.host }}`) && PathPrefix(`{{ .Values.ingress.path }}`)
      kind: Rule
      services:
        - name: {{ include "base-app.fullname" . }}
          port: {{ .Values.service.port }}
  {{- if .Values.ingress.tls.enabled }}
  tls:
    {{- if .Values.ingress.tls.secretName }}
    secretName: "{{ .Values.ingress.tls.secretName }}"
    {{- else if .Values.ingress.tls.certResolver }}
    certResolver: "{{ .Values.ingress.tls.certResolver }}"
    {{- else }}
    {}  # TLS enabled with no secret or resolver: uses default Traefik certificate
    {{- end }}
  {{- end }}
{{- end }}
```

### charts/base-app/templates/pvc.yaml

```yaml
# PersistentVolumeClaim Template
# Creates a PVC for persistence if enabled and no existing claim is provided.
{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "base-app.fullname" . }}-{{ .Values.persistence.name }}
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  accessModes:
    {{ toYaml .Values.persistence.accessModes | nindent 4 }}
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
  {{- if .Values.persistence.storageClass }}
  storageClassName: "{{ .Values.persistence.storageClass }}"
  {{- end }}
{{- end }}
```

### charts/base-app/templates/serviceaccount.yaml

```yaml
# ServiceAccount Template
# Creates a ServiceAccount if serviceAccount.create is true.
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name | default (include "base-app.fullname" .) }}
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
{{- end }}
```

### charts/base-app/templates/secretproviderclass.yaml

```yaml
# SecretProviderClass Template (Azure Key Vault CSI)
# Defines a SecretProviderClass for Azure Key Vault integration if enabled.
{{- if .Values.azureKeyVault.enabled }}
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: {{ include "base-app.fullname" . }}-azure-kv
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  provider: azure
  {{- if .Values.azureKeyVault.syncSecrets }}
  secretObjects:
    - secretName: {{ .Values.azureKeyVault.syncSecretName | default (printf "%s-secrets" (include "base-app.fullname" .)) }}
      type: Opaque
      data:
        {{- range .Values.azureKeyVault.secrets }}
        - objectName: {{ .objectName }}
          key: {{ .secretKey | default .objectName }}
        {{- end }}
  {{- end }}
  parameters:
    usePodIdentity: {{ .Values.azureKeyVault.usePodIdentity | quote }}
    useVMManagedIdentity: {{ .Values.azureKeyVault.useVMManagedIdentity | quote }}
    userAssignedIdentityID: "{{ .Values.azureKeyVault.userAssignedIdentityID }}"
    keyvaultName: "{{ .Values.azureKeyVault.keyVaultName }}"
    tenantId: "{{ .Values.azureKeyVault.tenantId }}"
    objects: |
      array:
      {{- range .Values.azureKeyVault.secrets }}
        - |
          objectName: {{ .objectName }}
          objectType: {{ .objectType | default "secret" }}
          {{- if .objectVersion }}
          objectVersion: {{ .objectVersion }}
          {{- else }}
          objectVersion:
          {{- end }}
      {{- end }}
{{- end }}
```

### charts/base-app/templates/job.yaml

```yaml
# Job Template
# Creates a Kubernetes Job for a one-time batch task if enabled.
{{- if .Values.job.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "base-app.fullname" . }}-job
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  backoffLimit: {{ .Values.job.backoffLimit }}
  completions: {{ .Values.job.completions }}
  parallelism: {{ .Values.job.parallelism }}
  template:
    metadata:
      labels:
        {{ include "base-app.labels" . | nindent 8 }}
    spec:
      restartPolicy: {{ .Values.job.restartPolicy }}
      {{- if .Values.podSecurityContext }}
      securityContext:
        {{ toYaml .Values.podSecurityContext | nindent 8 }}
      {{- end }}
      serviceAccountName: {{- if .Values.serviceAccount.create }}{{ .Values.serviceAccount.name | default (include "base-app.fullname" .) }}{{- else if .Values.serviceAccount.name }}{{ .Values.serviceAccount.name }}{{- end }}
      containers:
        - name: job
          image: "{{ .Values.job.image.repository | default .Values.image.repository }}:{{ .Values.job.image.tag | default .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- if .Values.job.command }}
          command:
            {{ toYaml .Values.job.command | nindent 12 }}
          {{- end }}
          {{- if .Values.job.args }}
          args:
            {{ toYaml .Values.job.args | nindent 12 }}
          {{- end }}
          {{- if .Values.job.env }}
          env:
            {{- range .Values.job.env }}
            - name: {{ .name }}
              value: {{ quote .value }}
            {{- end }}
          {{- end }}
          {{- if .Values.envFrom }}
          envFrom:
            {{- range .Values.envFrom }}
            - {{- if .configMapRef }}
              configMapRef:
                name: {{ .configMapRef.name }}
              {{- else if .secretRef }}
              secretRef:
                name: {{ .secretRef.name }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- if .Values.resources }}
          resources:
            {{ toYaml .Values.resources | nindent 12 }}
          {{- end }}
          {{- if or .Values.persistence.enabled .Values.azureKeyVault.enabled }}
          volumeMounts:
            {{- if .Values.persistence.enabled }}
            - name: {{ .Values.persistence.name }}
              mountPath: {{ .Values.persistence.mountPath }}
            {{- end }}
            {{- if .Values.azureKeyVault.enabled }}
            - name: secrets-store
              mountPath: {{ .Values.azureKeyVault.mountPath }}
              readOnly: true
            {{- end }}
          {{- end }}
      {{- if or .Values.azureKeyVault.enabled .Values.persistence.enabled }}
      volumes:
        {{- if .Values.azureKeyVault.enabled }}
        - name: secrets-store
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: {{ include "base-app.fullname" . }}-azure-kv
        {{- end }}
        {{- if .Values.persistence.enabled }}
        - name: {{ .Values.persistence.name }}
          persistentVolumeClaim:
            claimName: {{ if .Values.persistence.existingClaim }}{{ .Values.persistence.existingClaim }}{{ else }}{{ include "base-app.fullname" . }}-{{ .Values.persistence.name }}{{ end }}
        {{- end }}
      {{- end }}
      {{- if .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- range .Values.imagePullSecrets }}
        - name: {{ . }}
        {{- end }}
      {{- end }}
      {{- if .Values.nodeSelector }}
      nodeSelector:
        {{ toYaml .Values.nodeSelector | nindent 8 }}
      {{- end }}
      {{- if .Values.tolerations }}
      tolerations:
        {{ toYaml .Values.tolerations | nindent 8 }}
      {{- end }}
      {{- if .Values.affinity }}
      affinity:
        {{ toYaml .Values.affinity | nindent 8 }}
      {{- end }}
{{- end }}
```

### charts/base-app/templates/cronjob.yaml

```yaml
# CronJob Template
# Creates a Kubernetes CronJob for scheduled tasks if enabled.
{{- if .Values.cronjob.enabled }}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "base-app.fullname" . }}-cronjob
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  schedule: "{{ .Values.cronjob.schedule }}"
  concurrencyPolicy: {{ .Values.cronjob.concurrencyPolicy | quote }}
  successfulJobsHistoryLimit: {{ .Values.cronjob.successfulJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ .Values.cronjob.failedJobsHistoryLimit }}
  suspend: {{ .Values.cronjob.suspend }}
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            {{ include "base-app.labels" . | nindent 12 }}
        spec:
          restartPolicy: OnFailure
          serviceAccountName: {{- if .Values.serviceAccount.create }}{{ .Values.serviceAccount.name | default (include "base-app.fullname" .) }}{{- else if .Values.serviceAccount.name }}{{ .Values.serviceAccount.name }}{{- end }}
          containers:
            - name: cronjob
              image: "{{ .Values.cronjob.image.repository | default .Values.image.repository }}:{{ .Values.cronjob.image.tag | default .Values.image.tag }}"
              imagePullPolicy: {{ .Values.image.pullPolicy }}
              {{- if .Values.cronjob.command }}
              command:
                {{ toYaml .Values.cronjob.command | nindent 16 }}
              {{- end }}
              {{- if .Values.cronjob.args }}
              args:
                {{ toYaml .Values.cronjob.args | nindent 16 }}
              {{- end }}
              {{- if .Values.cronjob.env }}
              env:
                {{- range .Values.cronjob.env }}
                - name: {{ .name }}
                  value: {{ quote .value }}
                {{- end }}
              {{- end }}
              {{- if .Values.envFrom }}
              envFrom:
                {{- range .Values.envFrom }}
                - {{- if .configMapRef }}
                  configMapRef:
                    name: {{ .configMapRef.name }}
                  {{- else if .secretRef }}
                  secretRef:
                    name: {{ .secretRef.name }}
                  {{- end }}
                {{- end }}
              {{- end }}
              {{- if .Values.resources }}
              resources:
                {{ toYaml .Values.resources | nindent 16 }}
              {{- end }}
              {{- if or .Values.persistence.enabled .Values.azureKeyVault.enabled }}
              volumeMounts:
                {{- if .Values.persistence.enabled }}
                - name: {{ .Values.persistence.name }}
                  mountPath: {{ .Values.persistence.mountPath }}
                {{- end }}
                {{- if .Values.azureKeyVault.enabled }}
                - name: secrets-store
                  mountPath: {{ .Values.azureKeyVault.mountPath }}
                  readOnly: true
                {{- end }}
              {{- end }}
          {{- if or .Values.azureKeyVault.enabled .Values.persistence.enabled }}
          volumes:
            {{- if .Values.azureKeyVault.enabled }}
            - name: secrets-store
              csi:
                driver: secrets-store.csi.k8s.io
                readOnly: true
                volumeAttributes:
                  secretProviderClass: {{ include "base-app.fullname" . }}-azure-kv
            {{- end }}
            {{- if .Values.persistence.enabled }}
            - name: {{ .Values.persistence.name }}
              persistentVolumeClaim:
                claimName: {{ if .Values.persistence.existingClaim }}{{ .Values.persistence.existingClaim }}{{ else }}{{ include "base-app.fullname" . }}-{{ .Values.persistence.name }}{{ end }}
            {{- end }}
          {{- end }}
          {{- if .Values.imagePullSecrets }}
          imagePullSecrets:
            {{- range .Values.imagePullSecrets }}
            - name: {{ . }}
            {{- end }}
          {{- end }}
          {{- if .Values.nodeSelector }}
          nodeSelector:
            {{ toYaml .Values.nodeSelector | nindent 12 }}
          {{- end }}
          {{- if .Values.tolerations }}
          tolerations:
            {{ toYaml .Values.tolerations | nindent 12 }}
          {{- end }}
          {{- if .Values.affinity }}
          affinity:
            {{ toYaml .Values.affinity | nindent 12 }}
          {{- end }}
{{- end }}
```

### charts/base-app/templates/hpa.yaml

```yaml
# Horizontal Pod Autoscaler (HPA) Template
# Creates an HPA to scale the Deployment based on resource usage if enabled.
{{- if .Values.hpa.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "base-app.fullname" . }}
  labels:
    {{ include "base-app.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "base-app.fullname" . }}
  minReplicas: {{ .Values.hpa.minReplicas }}
  maxReplicas: {{ .Values.hpa.maxReplicas }}
  metrics:
    {{- if .Values.hpa.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.hpa.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.hpa.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.hpa.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
```

### charts/base-app/README.md

```md
# base-app Helm Chart

## Overview
This Helm chart (***base-app***) provides a template for deploying a generic application to Azure Kubernetes Service (AKS). It includes all common Kubernetes resources such as Deployment, Service, IngressRoute (Traefik), PersistentVolumeClaim, Job, CronJob, SecretProviderClass for Azure Key Vault, and Horizontal Pod Autoscaler. All components are highly configurable via the `values.yaml` file, allowing application teams to easily tailor the deployment to their app's needs.

## Prerequisites
- **Kubernetes**: An AKS cluster (or any Kubernetes cluster) with Helm installed.
- **Traefik Ingress Controller**: The Traefik ingress controller should be installed in the cluster (for the IngressRoute resource).
- **Secrets Store CSI Driver**: If using Azure Key Vault integration, the Azure Key Vault CSI driver and its SecretProviderClass CRD must be installed in the cluster.

## Usage
1. **Add this chart** to your Helm repository or clone this repository.
2. **Customize values**: Edit the `charts/base-app/values.yaml` file to suit your application. At minimum, set the container image (`image.repository` and `image.tag`) for your app. 
3. **Enable/disable features**: Toggle the features you need (e.g., ingress, persistence, autoscaling, jobs) by setting the corresponding values.
4. **Deploy the chart** using Helm:
   ```bash
   helm install my-app charts/base-app -f my-values.yaml
   ```
   Replace `my-app` with your desired release name. This will create all enabled Kubernetes resources for your application.

## Configuration
All configuration is done via `values.yaml`. Key settings include:

- **Application Image**: Set `image.repository` and `image.tag` to the Docker image of your application. You can also configure `image.pullPolicy` and specify `imagePullSecrets` if pulling from a private registry.
- **Replicas**: `replicaCount` controls the number of pod replicas for the Deployment.
- **Service**: `service.enabled` toggles creation of a Service. Configure `service.type` (ClusterIP/NodePort/LoadBalancer) and `service.port` as needed. The `targetPort` defaults to the container port.
- **Ingress (Traefik)**: `ingress.enabled` toggles creation of a Traefik `IngressRoute`. Set `ingress.host` to your application's domain name and `ingress.path` (default `/`). The chart uses Traefik's CRD by default. If TLS is required, set `ingress.tls.enabled=true` and either provide an existing TLS secret via `ingress.tls.secretName` or specify a Traefik certificate resolver with `ingress.tls.certResolver`. Make sure Traefik is installed and configured to handle IngressRoute resources.
- **Probes**: The chart includes default HTTP health checks. Liveness and readiness probes are enabled by default (checking `path: /` on port `http`). You can adjust these settings under `livenessProbe` and `readinessProbe` (or disable them by setting `enabled: false` for each).
- **Resources and Scheduling**: You can set resource `requests` and `limits` for the container under `resources`. Additionally, control scheduling with `nodeSelector`, `tolerations`, and `affinity` to influence how pods are placed on nodes.
- **Environment Variables**: Use the `env` array to pass environment variables to the container. For example:
  ```yaml
  env:
    - name: ENVIRONMENT
      value: "production"
  ```
  You can also use `envFrom` to bring in all variables from a ConfigMap or Secret.
- **Persistence**: If your application needs a persistent volume, set `persistence.enabled=true`. Adjust `persistence.size` (default 1Gi) and other settings like `storageClass` and `accessModes` as needed. By default, a PersistentVolumeClaim will be created and mounted at `persistence.mountPath` (default `/data`). If you already have a PVC, you can specify its name in `persistence.existingClaim` to use it instead of creating a new one.
- **Azure Key Vault Integration**: For applications that require secrets from Azure Key Vault, set `azureKeyVault.enabled=true`. Configure `azureKeyVault.keyVaultName` and `azureKeyVault.tenantId`, and list the secrets to retrieve under `azureKeyVault.secrets`. Each secret entry should include the Key Vault object name and type (e.g., secret, key, or cert). If `azureKeyVault.syncSecrets=true`, the secrets will also be synced to a Kubernetes Secret (whose name can be set via `azureKeyVault.syncSecretName`). The secrets will be mounted in the container at the path specified by `azureKeyVault.mountPath`. Ensure the pod has appropriate Azure identity permissions to access Key Vault (via Pod Identity or Workload Identity, configured with `usePodIdentity` or managed identity options).
- **Horizontal Pod Autoscaler**: To enable autoscaling, set `hpa.enabled=true`. Configure `minReplicas` and `maxReplicas`, and set the target CPU and/or memory utilization percentages (`targetCPUUtilizationPercentage` and `targetMemoryUtilizationPercentage`) that will trigger scaling. The HPA will target the Deployment created by this chart.
- **Jobs and CronJobs**: The chart can also manage batch jobs.
  - To run a one-time Job (e.g., a database migration or seed job), set `job.enabled=true`. By default it uses the same container image as the main application, but you can override `job.image` if needed. You can also specify a different command/args via `job.command` and `job.args`. The job will run to completion (with `restartPolicy` defaulting to OnFailure) and by default will run once (`completions: 1`).
  - For scheduled tasks, set `cronjob.enabled=true`. Provide a cron schedule in `cronjob.schedule` (for example, `"0 0 * * *"` for daily at midnight). Like the Job, the CronJob uses the main image by default (override with `cronjob.image` if necessary) and you can specify `cronjob.command` and `cronjob.args`. Adjust concurrencyPolicy or suspend as needed. The CronJob will create Jobs on the given schedule.
- **Service Account**: By default, the pods will use a dedicated ServiceAccount created by the chart. If your application needs a specific ServiceAccount (for example, to use Azure AD Pod Identity or Workload Identity), you can set `serviceAccount.create=false` and specify the name in `serviceAccount.name`. Alternatively, set `serviceAccount.name` to a custom name and keep `serviceAccount.create=true` to have the chart create one with that name.

## Structure
This repository is organized as a standard Helm chart:
- `Chart.yaml` – basic information about the chart (name, version, etc.).
- `values.yaml` – default configuration values for the chart.
- `templates/` – Kubernetes manifest templates for Deployment, Service, IngressRoute, PVC, Job, CronJob, SecretProviderClass, HPA, and ServiceAccount. Each template is annotated with comments for clarity.
- `.github/workflows/publish.yaml` – *(Optional)* GitHub Actions workflow to package and publish the chart (for example, to GitHub Pages or a registry) when changes are pushed.

## Example
For example, to deploy a simple web application with an external endpoint:
1. Set your Docker image in `values.yaml` (e.g., `image.repository: myregistry.azurecr.io/myapp` and `image.tag: "v1.0.0"`).
2. Enable the ingress and set the host:
   ```yaml
   ingress:
     enabled: true
     host: "myapp.example.com"
   ```
3. (Optional) If the app requires a database password from Key Vault, enable Azure Key Vault integration and list the secret:
   ```yaml
   azureKeyVault:
     enabled: true
     keyVaultName: "my-keyvault"
     tenantId: "<Azure-Tenant-ID>"
     secrets:
       - objectName: "DbPassword"
         objectType: secret
         secretKey: "DB_PASSWORD"
     syncSecrets: true
   ```
   Ensure the AKS cluster is set up with access to Key Vault (for example, via a managed identity).
4. Install the Helm release. Traefik will route `myapp.example.com` to your service, your app will retrieve `DB_PASSWORD` from Key Vault, and any other enabled features (like HPA or persistence) will be active as configured.

## Notes
- All template files are thoroughly commented for ease of maintenance.
- You can override any field from the default `values.yaml` by providing your own values file or using `--set` flags during installation.
- This chart is designed to be a starting point. Application teams can use it as-is or modify it further to fit their specific requirements.
```

### .github/workflows/publish.yaml

```yaml
name: Release Charts
on:
  push:
    branches: [ main ]
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Configure Git
        run: |
          git config user.name "$GITHUB_ACTOR"
          git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
      - name: Run chart-releaser
        uses: helm/chart-releaser-action@v1.7.0
        with:
          charts_dir: charts
        env:
          CR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```