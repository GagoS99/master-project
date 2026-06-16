# DRAFT — review every line before applying.

{{- define "api.fullname" -}}
{{- .Release.Name }}-{{ .Chart.Name }}
{{- end }}

{{- define "api.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{/* ^^^ No trailing blank line — a blank line here gets rendered into the YAML
         and breaks selector matching (extra empty key in the labels map). */}}

{{- define "api.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "api.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
