{{- /*
    Generate Horizontal Pod Autoscaler
*/ -}}
{{- define "gcc.api.hpa" -}}
{{- with .Values.api.autoscaling -}}
{{- if .enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "gcc.api.fullname" $ }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "gcc.api.labels" $ | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "gcc.api.fullname" $ }}
  minReplicas: {{ .minReplicas | default 1 }}
  maxReplicas: {{ .maxReplicas | default 3 }}
  metrics:
    {{- if .targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}