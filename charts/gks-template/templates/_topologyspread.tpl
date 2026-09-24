{{- /*
    Generate topologySpreadConstraints
*/ -}}
{{- define "gks.shared.topologySpreadConstraints" -}}
{{- if .Values.topologySpreadConstraints }}
{{- toYaml .Values.topologySpreadConstraints }}
{{- else if .Values.topologySpread.enabled }}
- maxSkew: {{ .Values.topologySpread.maxSkew }}
  topologyKey: {{ .Values.topologySpread.topologyKey }}
  whenUnsatisfiable: {{ .Values.topologySpread.whenUnsatisfiable }}
  nodeTaintsPolicy: {{ .Values.topologySpread.nodeTaintsPolicy }}
  {{- if eq .Values.type "Deployment" }}
  matchLabelKeys:
    - pod-template-hash
  {{- end }}
  labelSelector:
    matchLabels:
      {{- include "gks.shared.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end -}}
