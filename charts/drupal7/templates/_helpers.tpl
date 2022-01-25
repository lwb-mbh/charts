{{/*
Expand the name of the chart.
*/}}
{{- define "deploy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deploy.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "deploy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deploy.labels" -}}
helm.sh/chart: {{ include "deploy.chart" . }}
{{ include "drupal7.deploy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "drupal7.deploy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deploy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: drupal
tier: frontend
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "deploy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "deploy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "gitlabPullSecret" }}
{{- with .Values.global.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{- define "helpers.list-drupal7-env-variables"}}
- name: APPLICATION
  value: {{ .Release.Name | quote }}
- name: TZ
  value: {{ .Values.global.plain.dbTZ | quote }}
- name: APP_DB_HOST
{{- if .Values.global.plain.dbExternal }}
  value: {{ .Values.global.plain.dbIP | quote }}
{{- else }}
  value: {{ printf "%s-%s" .Release.Name "mariadb" | trunc 63 | quote }}
{{- end }}
- name: APP_DB_PORT
  value: {{ .Values.global.plain.dbPort | quote }}
- name: APP_DB_DB
  value: {{ .Values.global.plain.dbDatabase | quote }}
- name: APP_DB_USER
  value: {{ .Values.global.plain.dbUser | quote }}
- name: CORE_DB_HOST
  value: {{ .Values.env.plain.dbCoreHost | quote }}
- name: CORE_DB_PORT
  value: {{ .Values.env.plain.dbCorePort | quote }}
- name: CORE_DB_DB
  value: {{ .Values.env.plain.dbCoreDatabase | quote }}
- name: CORE_DB_USER
  value: {{ .Values.env.plain.dbCoreUser | quote }}
{{- end }}

{{/*
Name of backup
*/}}
{{- define "deploy.backup.name" -}}
{{- printf "%s-%s" (include "deploy.fullname" .) "backup" | trunc 63 }}
{{- end }}

{{/*
Name of import
*/}}
{{- define "deploy.import.name" -}}
{{- printf "%s-%s" (include "deploy.fullname" .) "import" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Import path name
*/}}
{{- define "deploy.import.subPath" -}}
{{- printf "%s/%s/%s" .Chart.Name "production" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Backup path name
*/}}
{{- define "deploy.backup.subPath" -}}
{{- printf "%s/%s/%s" .Chart.Name ( default "stage" .Values.global.plain.environment ) .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of backup env secrets
*/}}
{{- define "deploy.backup.env.secrets" -}}
{{- printf "%s-%s-%s-%s" (include "deploy.fullname" .) "backup" "env" "secrets" | trunc 63 }}
{{- end }}

{{/*
Name of import env secrets
*/}}
{{- define "deploy.import.env.secrets" -}}
{{- printf "%s-%s-%s-%s" (include "deploy.fullname" .) "import" "env" "secrets" | trunc 63 | trimSuffix "-" }}
{{- end }}