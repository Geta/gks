{{- /*
    Generate DAPR configuration
*/ -}}
{{- define "gcc.dapr-configuration" -}}
{{- with .Values.dapr.configuration -}}
{{- if and $.Values.dapr.enabled .enabled }}
apiVersion: dapr.io/v1alpha1
kind: Configuration
metadata:
  name: configuration
  namespace: {{ $.Release.Namespace }}
spec:
  {{- with .metrics }}
  metrics:
    enabled: {{ .enabled | default false }}
    rules: {{- toYaml .rules | nindent 6 }}
  {{- end }}
  {{- with .logging }}
  logging:
    apiLogging:
      enabled: {{ .enabled | default false }}
      obfuscateURLs: {{ .obfuscateURLs | default false }}
      omitHealthChecks: {{ .omitHealthChecks | default true }}
  {{- end }}
  {{- with .tracing }}
  tracing:
    samplingRate: {{ .samplingRate | default "1" }}
    stdout: {{ .stdout | default true }}
    otel:
      isSecure: {{ $.Values.global.dapr.otel.isSecure | default false }}
      endpointAddress: {{ $.Values.global.dapr.otel.endpoint }}
      protocol: {{ $.Values.global.dapr.otel.protocol | default "grpc" }}
  {{- end }}
  {{- with $.Values.global.dapr.mtls }}
  mtls:
    enabled: {{ .enabled | default false }}
    controlPlaneTrustDomain: {{ .trustDomain | default "cluster.local" }}
    sentryAddress: {{ .sentryAddress | default "dapr-sentry.infra-dapr.svc.cluster.local:443" }}
  {{- end }}
  features: {{ toYaml .features | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}