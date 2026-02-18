{{- define "fluentd.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "fluentd.fullname" -}}
{{- printf "%s-%s" (include "fluentd.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
