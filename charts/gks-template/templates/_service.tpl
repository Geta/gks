{{- /*
    Generate Service
*/ -}}
{{- define "gks.shared.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "gks.shared.fullname" . }}
  labels:
    {{- include "gks.shared.labels" . | nindent 4 }}
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
  {{- if gt (.Values.service.grpcPort | atoi) 0 }}
    - port: {{ .Values.service.grpcPort }}
      targetPort: http
      protocol: TCP
      name: grpc
  {{- end }}
  selector:
    {{- include "gks.shared.selectorLabels" . | nindent 4 }}
{{- end }}