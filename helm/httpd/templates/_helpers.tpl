{{- define "httpd.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "httpd.fullname" -}}
{{- printf "%s-%s" (include "httpd.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
