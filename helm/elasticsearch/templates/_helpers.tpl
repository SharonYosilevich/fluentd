{{- define "elasticsearch.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "elasticsearch.fullname" -}}
{{- printf "%s-%s" (include "elasticsearch.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
