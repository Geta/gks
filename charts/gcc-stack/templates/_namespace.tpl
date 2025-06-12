{{- /*
    Generate GCC stack namespace
*/ -}}
{{- define "gcc.stack.namespace" -}}
{{- with .Values.namespace }}
{{- if .create -}}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ include "gcc.stack.namespaceName" $ | quote }}
  labels:
    {{- include "gcc.stack.labels" $ | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}