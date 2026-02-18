{{- define "kibana.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "kibana.fullname" -}}
{{- printf "%s-%s" (include "kibana.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
