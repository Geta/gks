{{- /*
Expand the name of the chart.
*/ -}}
{{- define "gcc.api.name" -}}
{{- default .Chart.Name .Values.api.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "gcc.api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.api.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.api.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- /*
Create chart name and version as used by the chart label.
*/ -}}
{{- define "gcc.api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Common labels
*/ -}}
{{- define "gcc.api.labels" -}}
helm.sh/chart: {{ include "gcc.api.chart" . }}
{{ include "gcc.api.selectorLabels" . }}
{{- include "gcc.api.platformLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- /*
Selector labels
*/ -}}
{{- define "gcc.api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gcc.api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- /*
Platform labels
*/ -}}
{{- define "gcc.api.platformLabels" }}
{{- if .Values.isStack }}
platform.getadigital.ai/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{- /*
Create the name of the service account to use
*/ -}}
{{- define "gcc.api.serviceAccountName" -}}
{{- with .Values.api.serviceAccount }}
{{- if .create }}
{{- .name | default (printf "%s-%s-api" $.Values.name $.Values.provider) }}
{{- else }}
{{- .name | default "default" }}
{{- end }}
{{- end }}
{{- end }}

{{- /*
Create GKS root customer namespace
*/ -}}
{{- define "gks.tenantRootNamespace" -}}
{{- $internalValues := fromYaml (.Files.Get "internal-values.yaml") }}
{{- printf "%s-%s-%s" $internalValues.tenantNamespacePrefix ($.Values.global.customer | required "Customer name not provided" ) ($.Values.global.environment | required "Environment is not provided") }}
{{- end }}

{{- /*
Create Harbor repository name
*/ -}}  
{{- define "harbor.repository" -}}
{{- $internalValues := fromYaml (.Files.Get "internal-values.yaml") }}
{{- .Values.api.image.repository | default (printf "%s%s-api%s" $internalValues.imageRepoBasePath (.Values.name | required "API name not provided") (ternary "" (printf "/%s" $.Values.global.environment) (eq $.Values.global.environment "production") | required "Environment is not provided")) }}
{{- end }}