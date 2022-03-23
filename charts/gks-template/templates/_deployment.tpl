{{- /*
    Generate Deployment
*/ -}}
{{- define "gks.shared.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "gks.shared.fullname" . }}
  labels:
    {{- include "gks.shared.labels" . | nindent 4 }}
  {{- with .Values.deploymentAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "gks.shared.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        app: {{ include "gks.shared.fullname" . }}
        version: {{ .Chart.Version }}
        {{- include "gks.shared.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "gks.shared.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      volumes:
        {{- toYaml .Values.volumes | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          envFrom:
            {{- toYaml .Values.envFrom | nindent 12 }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          volumeMounts:
            {{- toYaml .Values.volumeMounts | nindent 12 }}
          ports:
            - containerPort: {{ .Values.service.port }}
              protocol: TCP
              name: http
          {{- range .Values.service.extraPorts }}
            - containerPort: {{ .port }}
              protocol: TCP
              name: {{ .name }}
          {{- end }}
          {{- if .Values.probes.liveness }}
          livenessProbe:
            {{- toYaml .Values.probes.liveness | nindent 12 }}
          {{- end }}
          {{- if .Values.probes.startup }}
          startupProbe:
            {{- toYaml .Values.probes.startup | nindent 12 }}
          {{- end }}
          {{- if .Values.probes.readiness }}
          readinessProbe:
            {{- toYaml .Values.probes.readiness | nindent 12 }}
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end -}}