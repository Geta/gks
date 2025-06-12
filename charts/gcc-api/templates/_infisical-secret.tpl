{{- /*
    Generate Inifisical Secret
*/ -}}
{{- define "gcc.api.infisicalSecret" -}}
{{- with .Values.infisicalSecret -}}
{{- if .create }}
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  {{- $secretName := (printf "%s-secrets" (include "gcc.api.fullname" $)) }}
  name: {{ .name | default $secretName }}
  namespace: {{ $.Release.Namespace }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
spec:
  hostAPI: {{ .hostAPI | required "Infisical host API is required" }}
  resyncInterval: {{ .resyncInterval | default 60 }}
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: {{ .projectSlug | required "Infisical project slug is required" }}
        envSlug: {{ .envSlug | default $.Values.global.environment | required "Infisical environment slug is required" }}
        secretsPath: {{ .secretsPath | required "Infisical secrets path is required" }}
        recursive: {{ .recursive | default false }}
      {{- with .credentialsSecret }}
      credentialsRef:
        secretName: {{ .name | default "infisical-auth-secret" }}
        secretNamespace: {{ .namespace | default (include "gks.tenantRootNamespace" $) }}
      {{- end }}
  {{- with .managedSecret }}
  managedSecretReference:
    secretType: {{ .type | default "Opaque" }}
    secretName: {{ .name | default $secretName }}
    secretNamespace: {{ .namespace | default $.Release.Namespace }}
    creationPolicy: {{ .creationPolicy | default "Orphan" }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}