{{- /*
    Generate DAPR resiliency
*/ -}}
{{- define "gcc.dapr-resiliency" -}}
{{- with .Values.dapr.resiliency -}}
{{- if and $.Values.dapr.enabled $.Values.dapr.component.enabled .enabled }}
apiVersion: dapr.io/v1alpha1
kind: Resiliency
metadata:
  name: resiliency
  namespace: {{ $.Release.Namespace }}
scopes: 
  - {{ $.Values.dapr.scope | default (include "gcc.api.name" $) }}
spec:
  policies:
  {{- $retryName := printf "%s" "pubsubRetry" }}
  {{- with .retry }}
    {{- if .enabled }}
    retries:
      {{ $retryName }}:
        policy: {{ .policy | default "constant" }}
        duration: {{ .duration | default "1m" }}
        maxRetries: {{ .maxRetries | default 5 }}
    {{- end }}
  {{- end }}
  targets:
    components:
      {{ .name | default (include "gcc.dapr.componentName" $) }}:
        inbound:
          retry: {{ $retryName }}
{{- end }}
{{- end }}
{{- end }}