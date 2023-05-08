{{- /*
    Generate HorizontalPodAutoscaler
*/ -}}
{{- define "gks.shared.hpa" -}}
{{- if .Values.autoscaling.enabled }}
{{- end }}
{{- end }}