{{- /*
    Generate DAPR subscriptions
*/ -}}
{{- define "gcc.dapr-subscription" -}}
{{- range .Values.dapr.subscriptions -}}
{{- if and $.Values.dapr.enabled $.Values.dapr.component.enabled .enabled }}
apiVersion: dapr.io/v2alpha1
kind: Subscription
metadata:
  name: {{ .name | required "Subscription name not specified" }}
  namespace: {{ $.Release.Namespace }}
scopes: 
  - {{ $.Values.dapr.scope | default (include "gcc.api.name" $) }}
spec:
  pubsubname: {{ .name | default (include "gcc.dapr.componentName" $) }}
  topic: {{ .topic | required "Subscription topic not provided" }}
  {{- if .deadLetterTopic }}
  deadLetterTopic: {{ .deadLetterTopic }}
  {{- end }}
  routes: 
    default: {{ .route | required "Subscription route not specified" }}
  {{- if .routingKey }}
  metadata:
    routingKey: {{ .routingKey }}
  {{- end }}
---
{{- end }}
{{- end }}
{{- end }}