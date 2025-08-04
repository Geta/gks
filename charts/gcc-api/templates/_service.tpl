{{- /*
    Generate Service
*/ -}}
{{- define "gcc.api.service" -}}
{{- with .Values.api.service -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "gcc.api.fullname" $ }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "gcc.api.labels" $ | nindent 4 }}
  {{- if .annotations }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
  {{- end }}
spec:
  type: {{ .type | default "ClusterIP" }}
  ports:
  {{- range .ports }}
    - name: {{ .name | required "Service port name is required" }}
      port: {{ .port | required "Service port is required" }}
      targetPort: {{ .target.name | required "Service target port or name is required" }}
      protocol: {{ .protocol | default "TCP" }}
  {{- end }}
  selector:
    {{- include "gcc.api.selectorLabels" $ | nindent 4 }}
{{- end }}
{{- end }}