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
    {{- with .deployment }}
    {{- if .labels }}
    {{- toYaml .labels | nindent 4 }}
    {{- end }}
    {{- if .annotations }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
    {{- end }}
    {{- end }}
spec:
  replicas: {{ .replicas }}
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
        version: {{ $.Chart.Version }}
        {{- include "gcc.api.selectorLabels" $ | nindent 8 }}
    spec:
      {{- if .imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml .imagePullSecrets | nindent 8 }}
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
            {{- toYaml .env | nindent 12 }}
          envFrom:
            {{- toYaml .envFrom | nindent 12 }}
          securityContext:
            {{- toYaml .securityContext | nindent 12 }}
          image: "{{ include "harbor.repository" $ }}:{{ .image.tag | default $.Chart.AppVersion }}"
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
            - 
              name: {{ $item.target.name | required "Target port name not provided" }}
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
            - 
              name: {{ $item.target.name | required "Target port name not provided" }}
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