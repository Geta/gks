{{- /*
    Generate Deployment
*/ -}}
{{- define "gcc.shared.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "gcc.shared.fullname" . }}
  labels:
    {{- if .Values.tenant }}
    gcc/tenant: {{ .Values.tenant | quote }}
    {{- end }}
    {{- include "gcc.shared.labels" . | nindent 4 }}
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
      {{- include "gcc.shared.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        app: {{ include "gcc.shared.fullname" . }}
        version: {{ .Chart.Version }}
        {{- include "gcc.shared.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "gcc.shared.serviceAccountName" . }}
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
            - name: http
              containerPort: 80
              protocol: TCP
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