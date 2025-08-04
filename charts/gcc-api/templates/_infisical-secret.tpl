{{- /*
    Generate Infisical Secret
*/ -}}
{{- define "gcc.api.infisicalSecret" -}}
{{- with .Values.infisicalSecret -}}
{{- if .enabled }}
{{- $secretName := .name | default (include "gcc.infisical.secretName" $) }}
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: {{ $secretName }}
  namespace: {{ $.Release.Namespace }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
spec:
  hostAPI: {{ $.Values.global.infisical.hostAPI | required "Infisical host api is not provided" | quote }}
  resyncInterval: {{ .resyncInterval | default 120 }}
  authentication: 
    universalAuth:
      secretsScope:
        projectSlug: {{ .projectSlug | required "Infisical project slug is required" | quote }}
        envSlug: {{ .envSlug | required "Infisical environment slug is required" | quote }}
        secretsPath: {{ .secretsPath | required "Infisical secrets path is required" | quote }}
        recursive: {{ .recursive | default false }}
      {{- with ($.Values.global.infisical.credentialsRef | required "Infisical credentials reference is not provided") }}
      credentialsRef:
        secretName: {{ .secretName | required "Infisical secret name not provided" }}
        secretNamespace: {{ .secretNamespace | required "Infisical secret namespace not provided" }}
      {{- end }}
  managedKubeSecretReferences:
    -
      secretType: {{ .secretType | default "Opaque" }}
      secretName: {{ $secretName }}
      secretNamespace: {{ $.Release.Namespace }}
      creationPolicy: {{ .creationPolicy | default "Orphan" }}
{{- end }}
{{- end }}
{{- end }}