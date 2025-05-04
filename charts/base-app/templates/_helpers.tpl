{{- /* Return the base chart name or override */ -}}
{{- define "base-app.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- /* Return the full resource name, optionally overridden */ -}}
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

{{- /* Return the chart name and version for labeling */ -}}
{{- define "base-app.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{- /* Return standard labels for all resources */ -}}
{{- define "base-app.labels" -}}
app.kubernetes.io/name: {{ include "base-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ include "base-app.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- /* Return the service account name (defaults to fullname) */ -}}
{{- define "base-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{ .Values.serviceAccount.name }}
{{- else -}}
{{ include "base-app.fullname" . }}
{{- end -}}
{{- end -}}
