{{- /*
    Generate Service
*/ -}}
{{- define "gks.shared.service" -}}
{{- if eq .Values.type "Deployment" }}
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
      targetPort: {{ .Values.service.targetPort }}
      protocol: {{ .Values.service.protocol }}
      name: http
  {{- range .Values.service.extraPorts }}
    - port: {{ .port }}
      targetPort: {{ .name }}
      protocol: {{ default "TCP" .protocol }}
      name: {{ .name }}
  {{- end }}
  selector:
    {{- include "gks.shared.selectorLabels" . | nindent 4 }}
{{- end }}
{{- if eq .Values.type "StatefulSet" }}
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
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: {{ .Values.service.protocol }}
      name: http
  clusterIP: None
  selector:
    {{- include "gks.shared.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end }}