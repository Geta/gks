{{- /*
    Generate DAPR component
*/ -}}
{{- define "gcc.dapr-component" -}}
{{- with .Values.dapr.component -}}
{{- if and $.Values.dapr.enabled .enabled }}
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: {{ .name | default (include "gcc.dapr.componentName" $) }}
  namespace: {{ $.Release.Namespace }}
scopes: 
  - {{ $.Values.dapr.scope | default (include "gcc.api.name" $) }}
spec:
  type: {{ .type | required "DAPR component type is required" }}
  version: {{ .version | required "DAPR component version is required" }}
  metadata:
    {{- with .metadata }}
    {{- with .connectionString }}
    - name: connectionString
    {{- if and .fromInfisicalSecret $.Values.infisicalSecret.enabled }}
      secretKeyRef:
        name: {{ $.Values.infisicalSecret.name | required "Infisical secret is not provided" }}
        key: {{ .secretKey | required "Infisical secret key is not provided" }}
    {{- else }}
      value: {{ .plainTextValue | required "Connection string plaintext value is not provided" }}
    {{- end }}
    {{- end }}
    - name: consumerID
      value: {{ .consumerId | default "{appID}" | quote }}
    - name: clientName
      value: {{ .clientName | default "{appID}" | quote }}
    - name: durable
      value: {{ .durable | default true }}
    - name: deletedWhenUnused
      value: {{ .deletedWhenUnused | default false }}
    - name: autoAck
      value: {{ .autoACK | default false }}
    - name: deliveryMode
      value: {{ .deliveryMode | default 0 }}
    - name: requeueInFailure
      value: {{ .requeueInFailure | default false }}
    - name: prefetchCount
      value: {{ .prefetchCount | default 10 }}
    - name: publisherConfirm
      value: {{ .publisherConfirm | default true }}
    - name: reconnectWait
      value: {{ .reconnectWait | default 0 }}
    - name: concurrencyMode
      value: {{ .concurrencyMode | default "parallel" }}
    - name: enableDeadLetter
      value: {{ .enableDeadLetter | default 0 }}
    - name: maxLen
      value: {{ .maxLen | default 1000 }}
    - name: maxLenBytes
      value: {{ .maxLenBytes | default 1048576 }}
    - name: exchangeKind
      value: {{ .exchangeKind | default "topic" }}
    - name: saslExternal
      value: {{ .saslExternal | default false }}
    - name: heartBeat
      value: {{ .heartBeat | default "10s" }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}