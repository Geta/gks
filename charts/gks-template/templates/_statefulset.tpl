{{- /*
    Generate StatefulSet
*/ -}}
{{- define "gks.shared.statefulset" -}}
{{- if eq .Values.type "StatefulSet" }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "gks.shared.fullname" . }}
  labels:
    {{- include "gks.shared.labels" . | nindent 4 }}
  {{- with .Values.deploymentAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "gks.shared.selectorLabels" . | nindent 6 }}
  serviceName: {{ include "gks.shared.fullname" . }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
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
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
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
          lifecycle:
            {{- toYaml .Values.podLifecycle | nindent 12 }}
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
        {{- range .Values.sidecars }}
        - name: {{ .name }}
          env:
            {{- toYaml .env | nindent 12 }}
          image: {{ .image }}
          ports:
          {{- range .ports }}
            - containerPort: {{ .containerPort }}
              protocol: {{ .protocol }}
              name: {{ .name }}
          {{- end }}
        {{- end }}
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
{{- end -}}