{{- /*
  CertManager certificates
*/ -}}
{{- define "gcc.shared.certificates" -}}
{{- if .Values.certificates }}
{{- range .Values.certificates }}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ required "Certificate name is not provided" .name }}
  namespace: {{ default $.Release.Namespace .namespace }}
spec:
  commonName: {{ required "Common name is not provided" .commonName }}
  dnsNames:
    {{- toYaml (required "Dns names are not provided" .dnsNames) | nindent 4 }}
  issuerRef:
    kind: Issuer
    name: {{ required "Certificate issuer is not provided" .issuer }}
  secretName: {{ required "Certificate secret name is not provided" .secretName }}
  {{- if .secretAnnotations }}
  secretTemplate:
    annotations:
      {{- toYaml .secretAnnotations | nindent 6 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}