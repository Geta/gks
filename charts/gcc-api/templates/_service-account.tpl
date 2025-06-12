{{- /*
    Generate Servic account
*/ -}}
{{- define "gcc.api.serviceAccount" -}}
{{- with .Values.api.serviceAccount -}}
{{- if .create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "gcc.api.serviceAccountName" $ }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "gcc.api.labels" $ | nindent 4 }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
spec: {}
{{- end -}}
{{- end -}}
{{- end -}}
