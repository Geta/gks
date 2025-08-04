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
{{- printf "%s-%s" .Chart.Name (include "gcc.api.platformVersion" $) | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Common labels
*/ -}}
{{- define "gcc.api.labels" -}}
helm.sh/chart: {{ include "gcc.api.chart" . }}
{{ include "gcc.api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "gcc.api.platformVersion" $ | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
gcc/customer: {{ .Values.global.customer | required "Customer is not provided" }}
gcc/tenant: {{ .Values.global.tenant | required "Tenant is not provided" }}
gcc/environment: {{.Values.global.environment | required "Environment is not provided" }}
gcc/api-name: {{ .Values.name | required "Api name not provided" }}
gcc/api-provider: {{ .Values.provider | required "Api provider not provided" }}
{{- end }}

{{- /*
Selector labels
*/ -}}
{{- define "gcc.api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gcc.api.name" $ }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- /*
Platform version
*/ -}}
{{- define "gcc.api.platformVersion" -}}
{{- with $.Values.global.stack }}
{{- if .enabled }}
{{- .version | required "Stack version is not provided" }}
{{- else }}
{{- $.Chart.Version }}
{{- end }}
{{- end }}
{{- end }}

{{- /*
    Api name formatter
*/ -}}
{{- define "gcc.api.apiName" -}}
{{- printf "%s-%s-api" (.Values.name | required "Api name not provided") (.Values.provider | required "Api provider not provided") }}
{{- end }}

{{- /*
    Environment to captital
*/ -}}
{{- define "gcc.api.envToCaptital" -}}
{{- $env := $.Values.global.environment | trim -}}
{{- $first := substr 0 1 $env -}}
{{- $rest := substr 1 (len $env | int) $env -}}
{{ printf "%s%s" (upper $first) $rest -}}
{{- end }}

{{- /*
    Environment name formatter
*/ -}}
{{- define "gcc.api.envName" -}}
{{- $env := ($.Values.global.environment | required "Environment is not provided") }}
{{- ternary "" (printf "/%s" $env) (eq $env "production") }}
{{- end }}

{{- /*
Create the name of the service account to use
*/ -}}
{{- define "gcc.api.serviceAccountName" -}}
{{- with .Values.api.serviceAccount }}
{{- if .create }}
{{- .name | default (include "gcc.api.name" $) }}
{{- else }}
{{- .name | default "default" }}
{{- end }}
{{- end }}
{{- end }}

{{- /*
Create GKS root customer namespace
*/ -}}
{{- define "gks.tenantRootNamespace" -}}
{{- $customer := ($.Values.global.customer | required "Customer name not provided" ) }}
{{- $envValue := ($.Values.global.environment | required "Environment is not provided") }}
{{- $env := (ternary "" (printf "/%s" $envValue) (eq $envValue "production")) }}
{{- printf "%s-%s-%s" "tenant" $customer $env }}
{{- end }}

{{- /*
Create Harbor repository name
*/ -}}  
{{- define "harbor.image" -}}
{{- $registry := (.Values.global.imageRegistry | required "Image registry configuration is not provided") }}
{{- $apiName := (include "gcc.api.apiName" $)}}
{{- $env := (include "gcc.api.envName" $) }}
{{- .Values.api.image.repository | default (printf "%s%s%s" $registry.basePath $apiName $env) }}
{{- end }}

{{- /*
    Dapr component name
*/ -}}
{{- define "gcc.dapr.componentName" -}}
{{- $type := ($.Values.dapr.component.type | required "Component type is not provided") }}
{{- replace "." "-" $type }}
{{- end }}

{{- /*
    Infisical secret name
*/ -}}
{{- define "gcc.infisical.secretName" -}}
{{- printf "%s-secrets" (include "gcc.api.name" $) | quote }}
{{- end }}