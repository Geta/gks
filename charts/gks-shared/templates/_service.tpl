{{- /*
    Generate Service
*/ -}}
{{- define "gcc.shared.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "gcc.shared.fullname" . }}
  labels:
    {{- if .Values.tenant }}
    gcc/tenant: {{ .Values.tenant | quote }}
    {{- end }}
    {{- include "gcc.shared.labels" . | nindent 4 }}
  {{- if .Values.serviceAnnotations }}
  annotations:
    {{- toYaml .Values.serviceAnnotations | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "gcc.shared.selectorLabels" . | nindent 4 }}
{{- end }}