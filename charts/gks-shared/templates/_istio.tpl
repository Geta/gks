{{- /*
  Istio Ingress Routing
*/ -}}
{{- define "gcc.shared.istio" -}}
{{- if .Values.gateways }}
{{- range .Values.gateways }}
---
# Workaround for HTTP01 challenges https://github.com/istio/istio/issues/27643
apiVersion: networking.istio.io/v1beta1
kind: Gateway
{{ $ns := default $.Release.Namespace .namespace }}
metadata:
  name: {{ required "Gateway name is not provided" .name }}-https-redirect
  namespace: {{ $ns }}
spec:
  selector:
    istio: {{ required "Ingress gateway is not specified" .ingressGateway }}
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP2
      hosts: 
      {{- if .hosts }}
      {{- range .hosts }}
        - "{{ $ns }}/{{ . }}"
      {{- end }}
      {{- else }}
        - "{{ $ns }}/*"
      {{- end }}
---
apiVersion: networking.istio.io/v1beta1
kind: Gateway
{{ $ns := default $.Release.Namespace .namespace }}
metadata:
  name: {{ required "Gateway name is not provided" .name }}-https
  namespace: {{ $ns }}
spec:
  selector:
    istio: {{ required "Ingress gateway is not specified" .ingressGateway }}
  servers:
    - port:
        number: 443
        name: https
        protocol: HTTPS
      hosts: 
      {{- if .hosts }}
      {{- range .hosts }}
        - "{{ $ns }}/{{ . }}"
      {{- end }}
      {{- else }}
        - "{{ $ns }}/*"
      {{- end }}
      tls:
        mode: SIMPLE
        credentialName: {{ required "Certificate secret is required" .certificateSecret }}
{{- end }}
{{- end }}
{{- if and (.Values.routing.web) (.Values.routing.web.endpoints) }}
{{- range .Values.routing.web.endpoints }}
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ required "Tenant name is not provided" $.Values.tenant }}-web-{{ required "Endpoint name is required" .name }}-https-redirect
spec:
  hosts:
    {{- if .hosts }}
      {{- toYaml .hosts | nindent 4 }}
    {{- else }}
      {{ "No website hosts provided" | fail }}
    {{- end }}
  http:
    - redirect:
        scheme: https
        redirectCode: 302
  gateways:
    {{- $gw := printf "- %s-https-redirect" (required "Gateway is required" .gateway) -}} 
    {{ $gw | nindent 4 }}
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ required "Tenant name is not provided" $.Values.tenant }}-web-{{ required "Endpoint name is required" .name }}
spec:
  hosts:
    {{- if .hosts }}
      {{- toYaml .hosts | nindent 4 }}
    {{- else }}
      {{ "No website hosts provided" | fail }}
    {{- end }}
  gateways:
    {{- $gw := printf "- %s-https" (required "Gateway is required" .gateway) -}} 
    {{ $gw | nindent 4 }}
  http:
    - route:
        - destination:
            port:
              number: {{ default 80 .service.port }}
            {{ $ns := default $.Release.Namespace .service.namespace -}} 
            host: "{{ .service.host }}.{{ $ns }}.svc.cluster.local"
{{- end }}
{{- end }}
{{- if .Values.routing.api }}
{{- range $endpointIndex, $endpoint := .Values.routing.api.endpoints }}
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ required "Tenant name is not provided" $.Values.tenant }}-api-{{ required "Endpoint name is required" .name }}
spec:
  hosts:
    - {{ required "Host is required" $endpoint.host | quote }}
  gateways:
  {{- $gw := printf "- %s-https" (required "Gateway is required" $endpoint.gateway) -}} 
    {{ $gw | nindent 4 }}
  http:
  {{- if $.Values.routing.api.routes }}
    {{- range $routeIndex, $route := $.Values.routing.api.routes }}
    - 
      match:
        - uri:
          {{- if $route.match.prefix }}
            prefix: "{{ $route.match.prefix }}/"
          {{- else }}
            prefix: "/"
          {{- end }}
      rewrite:
        {{ $rewrite := (default "/" $route.match.rewrite | quote) -}}
        uri: {{ $rewrite }}
      headers:
        request:
          set:
            X-Tenant-Name: {{ $.Values.tenant | quote }}
            X-Forwarded-Prefix: {{ default "/" $route.match.prefix | quote }}
            {{- if $route.headers }}
              {{- toYaml $route.headers | nindent 14 }}
            {{- end }}
      {{- if $endpoint.cors }}
      corsPolicy:
        allowOrigins:
        {{- range $endpoint.cors.origins }}
          - exact: {{ . }}
        {{- end }}
        allowCredentials: {{ default true $endpoint.cors.credentials }}
        allowHeaders:
          - '*'
      {{- end }}
      route:
        - destination:
            port:
              number: {{ default 80 $route.service.port }}
            {{ $ns := default $.Release.Namespace $route.service.namespace -}}
            host: "{{ $route.service.host }}.{{ $ns }}.svc.cluster.local"
    {{- end }}
  {{- else }}
    {{- range $routeIndex, $route := (required "No routes found" .routes) }}
    - 
      match:
        - uri:
          {{- if $route.match.prefix }}
            prefix: "{{ $route.match.prefix }}/"
          {{- else }}
            prefix: "/"
          {{- end }}
      rewrite:
        {{ $rewrite := (default "/" $route.match.rewrite | quote) -}}
        uri: {{ $rewrite }}
      headers:
        request:
          set:
            X-Tenant-Name: {{ $.Values.tenant | quote }}
            X-Forwarded-Prefix: {{ default "/" $route.match.prefix | quote }}
            {{- if $route.headers }}
              {{- toYaml $route.headers | nindent 14 }}
            {{- end }}
      {{- if $endpoint.cors }}
      corsPolicy:
        allowOrigin:
          {{- toYaml $endpoint.cors.origins | nindent 10 }}
        allowCredentials: {{ default true $endpoint.cors.credentials }}
      {{- end }}
      route:
        - destination:
            port:
              number: {{ default 80 $route.service.port }}
            {{ $ns := default $.Release.Namespace $route.service.namespace -}}
            host: "{{ $route.service.host }}.{{ $ns }}.svc.cluster.local"
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}