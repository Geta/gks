{{- /*
    Generate Prometheus Probe
*/ -}}
{{- define "gcc.shared.monitoring.probe" -}}
{{- if $.Values.monitoring.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: Probe
metadata:
  name: {{ include "gcc.shared.fullname" . }}
spec:
  prober:
    url: {{ default "prometheus-blackbox-exporter.prometheus-blackbox-exporter.svc:9115" $.Values.monitoring.prober }}
  module: http_2xx
  targets:
    staticConfig:
      static:
        - {{ default $.Values.routing.web.host $.Values.monitoring.target }}
      relabelingConfigs:
        - sourceLabels: [__address__]
          targetLabel: tenant
          replacement: {{ required "Tenant not specified" $.Values.tenant }}
{{- end }}
{{- end }}