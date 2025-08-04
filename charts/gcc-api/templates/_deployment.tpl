{{- /*
    Generate Deployment
*/ -}}
{{- define "gcc.api.deployment" -}}
{{- with .Values.api -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "gcc.api.fullname" $ }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "gcc.api.labels" $ | nindent 4 }}
    {{- with .deployment.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .deployment.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  replicas: {{ .replicas | default 1  }}
  selector:
    matchLabels:
      {{- include "gcc.api.selectorLabels" $ | nindent 6 }}
  template:
    metadata:
      {{- if .podAnnotations }}
      annotations:
        {{- toYaml .podAnnotations | nindent 8 }}
      {{- end }}
      labels:
        {{- if .podLabels }}
        {{- toYaml .podLabels | nindent 8 }}
        {{- end }}
        app: {{ include "gcc.api.fullname" $ }}
        version: {{ include "gcc.api.platformVersion" $ }}
        {{- include "gcc.api.selectorLabels" $ | nindent 8 }}
    spec:
      {{- with ($.Values.global.imageRegistry | required "Image registry configuration not provided") }}
      imagePullSecrets:
        {{- toYaml .pullSecrets | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "gcc.api.serviceAccountName" $ }}
      securityContext:
        {{- toYaml .podSecurityContext | nindent 8 }}
      volumes:
        {{- toYaml .volumes | nindent 8 }}
      terminationGracePeriodSeconds: {{ .terminationGracePeriodSeconds | default 15 }}
      containers:
        - name: {{ $.Chart.Name }}
          env:
            {{- with $.Values.global.aspnet }}
            - name: ASPNETCORE_ENVIRONMENT
              value: {{ .environment | default (include "gcc.api.envToCaptital" $) | quote }}
            - name: ASPNETCORE_FORWARDEDHEADERS_ENABLED
              value: {{ .forwardedHeaders | quote }}
            - name: DOTNET_USE_POLLING_FILE_WATCHER
              value: {{ .pollingFileWatcher | quote }}
            - name: GCC_SERVICE_NAME
              value: {{ $.Values.name | required "API name is required" | quote }}
            - name: GCC_SERVICE_PROVIDER
              value: {{ $.Values.provider | required "API provider is required" | quote }}
            {{- end }}
            {{- with $.Values.global.otel }}
            {{- if .enabled }}
            - name: OTEL_SERVICE_NAME
              value:  {{ (include "gcc.api.apiName" $) | quote }}
            - name: OTEL_EXPORTER_OTLP_PROTOCOL
              value: {{ .protocol | quote }}
            - name: OTEL_EXPORTER_OTLP_INSECURE
              value: {{ .insecure | quote }}
            {{- with .endpoint }}
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: {{ .host | required "OTEL endpoint host not provided" | quote }}
            {{- if .credentials }}
            - name: OTEL_EXPORTER_OTLP_HEADERS
              value: "Authorization=Basic {{ .credentials }}"
            {{- end }}
            {{- end }}
            {{- with $.Values.otel }}
            {{- if .logs.enabled }}
            - name: GCC_OTEL_LOGS
              value: "otlp"
            {{- end }}
            {{- if .traces.enabled }}
            - name: GCC_OTEL_TRACES
              value: "otlp"
            - name: OTEL_TRACES_SAMPLER
              value: {{ .traces.sampler | quote }}
            - name: OTEL_TRACES_SAMPLER_ARG
              value: {{ .traces.samplingRate | quote }}
            {{- end }}
            {{- if .metrics.enabled }}
            - name: GCC_OTEL_METRICS
              value: "otlp"
            {{- end }}
            {{- end }}
            {{- end }}
            {{- end }}
            {{- if .env }}
            {{- toYaml .env | nindent 12 }}
            {{- end }}
          envFrom:
            {{- with $.Values.infisicalSecret }}
            {{- if .enabled }}
            - secretRef:
                name: {{ .name | default (include "gcc.infisical.secretName" $) }}
            {{- end }}
            {{- end }}
            {{- if .envFrom }}
            {{- toYaml .envFrom | nindent 12 }}
            {{- end }}
          securityContext:
            {{- toYaml .securityContext | nindent 12 }}
          image: "{{ include "harbor.image" $ }}:{{ .image.tag | default (include "gcc.api.platformVersion" $) }}"
          imagePullPolicy: {{ .image.pullPolicy | default "IfNotPresent" }}
          lifecycle:
            {{- toYaml .podLifecycle | nindent 12 }}
          volumeMounts:
            {{- toYaml .volumeMounts | nindent 12 }}
          ports:
          {{- $probePort := 8080 }}
          {{- if .service.ports }}
          {{- $probePort = (index .service.ports 0).target.port }}
          {{- range $index, $item := .service.ports }}
            - name: {{ $item.target.name | required "Target port name not provided" }}
              containerPort: {{ $item.target.port | required "Target port not provided" }}
              protocol: {{ $item.protocol | default "TCP" }}
          {{- end }}
          {{- else }}
          {{- fail "Service ports must be defined" }}
          {{- end }}
          {{- if and .probes.liveness .probes.liveness.enabled }}
          livenessProbe:
            {{- $base := .probes.liveness }}
            {{- $httpGet := $base.httpGet }}
            {{- $_ := set $httpGet "port" $probePort }}
            {{- $_ := set $base "httpGet" $httpGet }}
            {{- toYaml $base | nindent 12 }}
          {{- end }}
          {{- if and .probes.startup .probes.startup.enabled }}
          startupProbe:
            {{- $base := .probes.startup }}
            {{- $httpGet := $base.httpGet }}
            {{- $_ := set $httpGet "port" $probePort }}
            {{- $_ := set $base "httpGet" $httpGet }}
            {{- toYaml $base | nindent 12 }}
          {{- end }}
          {{- if and .probes.readiness .probes.readiness.enabled }}
          readinessProbe:
            {{- $base := .probes.readiness }}
            {{- $httpGet := $base.httpGet }}
            {{- $_ := set $httpGet "port" $probePort }}
            {{- $_ := set $base "httpGet" $httpGet }}
            {{- toYaml $base | nindent 12 }}
          {{- end }}
          resources:
            {{- toYaml .resources | nindent 12 }}
      {{- range .sidecars }}
        - name: {{ .name | required "Container name not provided" }}
          env:
            {{- toYaml .env | nindent 12 }}
          image: {{ .image | required "Image not provided" }}
          imagePullPolicy: {{ .pullPolicy | default "IfNotPresent" }}
          ports:
          {{- range $index, $item := .ports }}
            - name: {{ $item.target.name | required "Target port name not provided" }}
              containerPort: {{ $item.target.port | required "Target port not provided" }}
              protocol: {{ $item.protocol | default "TCP" }}
          {{- end }}
      {{- end }}
      {{- if .nodeSelector }}
      nodeSelector:
        {{- toYaml .nodeSelector | nindent 8 }}
      {{- end }}
      {{- if .affinity }}
      affinity:
        {{- toYaml .affinity | nindent 8 }}
      {{- end }}
      {{- if .tolerations }}
      tolerations:
        {{- toYaml .tolerations | nindent 8 }}
      {{- end }}
{{- end -}}
{{- end -}}