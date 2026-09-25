{{- /*
    Generate PodDisruptionBudget
*/ -}}
{{- define "gks.shared.pdb" -}}
{{- if .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "gks.shared.fullname" . }}
  labels:
    {{- include "gks.shared.labels" . | nindent 4 }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- else }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "gks.shared.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end -}}
