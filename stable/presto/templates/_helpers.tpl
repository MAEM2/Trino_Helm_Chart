{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "trino.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trino.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "trino.coordinator" -}}
{{ template "trino.fullname" . }}-coordinator
{{- end -}}

{{- define "trino.worker" -}}
{{ template "trino.fullname" . }}-worker
{{- end -}}

{{- define "trino.hive" -}}
{{ template "trino.fullname" . }}-hive
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trino.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "trino.jmx-exporter" -}}
{{ template "trino.fullname" . }}-jmx-exporter
{{- end -}}

{{- define "alluxio.fullname" -}}
{{- if .Values.alluxio.fullnameOverride -}}
{{- .Values.alluxio.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.alluxio.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "alluxio.worker.shortCircuit.volume" -}}
  {{- if eq .Values.alluxio.shortCircuit.volumeType "hostPath" }}
        - name: alluxio-domain
          hostPath:
            path: {{ .Values.alluxio.shortCircuit.hostPath }}
            type: DirectoryOrCreate
  {{- else }}
        - name: alluxio-domain
          persistentVolumeClaim:
            claimName: "{{ .Values.alluxio.shortCircuit.pvcName }}"
  {{- end }}
{{- end -}}

{{- define "alluxio.worker.resources" -}}
resources:
  limits:
    {{- if .Values.alluxio.worker.resources.limits }}
      {{- if .Values.alluxio.worker.resources.limits.cpu  }}
    cpu: {{ .Values.alluxio.worker.resources.limits.cpu }}
      {{- end }}
      {{- if .Values.alluxio.worker.resources.limits.memory  }}
    memory: {{ .Values.alluxio.worker.resources.limits.memory }}
      {{- end }}
    {{- end }}
  requests:
    {{- if .Values.alluxio.worker.resources.requests }}
      {{- if .Values.alluxio.worker.resources.requests.cpu  }}
    cpu: {{ .Values.alluxio.worker.resources.requests.cpu }}
      {{- end }}Ma
      {{- if .Values.alluxio.worker.resources.requests.memory  }}
    memory: {{ .Values.alluxio.worker.resources.requests.memory }}
      {{- end }}
    {{- end }}
{{- end -}}

{{- define "alluxio.jobWorker.resources" -}}
resources:
  limits:
    {{- if .Values.alluxio.jobWorker.resources.limits }}
      {{- if .Values.alluxio.jobWorker.resources.limits.cpu  }}
    cpu: {{ .Values.alluxio.jobWorker.resources.limits.cpu }}
      {{- end }}
      {{- if .Values.alluxio.jobWorker.resources.limits.memory  }}
    memory: {{ .Values.alluxio.jobWorker.resources.limits.memory }}
      {{- end }}
    {{- end }}
  requests:
    {{- if .Values.alluxio.jobWorker.resources.requests }}
      {{- if .Values.alluxio.jobWorker.resources.requests.cpu  }}
    cpu: {{ .Values.alluxio.jobWorker.resources.requests.cpu }}
      {{- end }}
      {{- if .Values.alluxio.jobWorker.resources.requests.memory  }}
    memory: {{ .Values.alluxio.jobWorker.resources.requests.memory }}
      {{- end }}
    {{- end }}
{{- end -}}

{{- define "alluxio.worker.tieredstoreVolumeMounts" -}}
  {{- if .Values.alluxio.tieredstore.levels }}
    {{- range .Values.alluxio.tieredstore.levels }}
      {{- /* The mediumtype can have multiple parts like MEM,SSD */}}
      {{- if .mediumtype }}
        {{- /* Mount each part */}}
        {{- if contains "," .mediumtype }}
          {{- $type := .type }}
          {{- $path := .path }}
          {{- $parts := splitList "," .mediumtype }}
          {{- range $i, $val := $parts }}
            {{- /* Example: For path="/tmp/mem,/tmp/ssd", mountPath resolves to /tmp/mem and /tmp/ssd */}}
            - mountPath: {{ index ($path | splitList ",") $i }}
              name: {{ $val | lower }}-{{ $i }}
          {{- end}}
        {{- /* The mediumtype is a single value. */}}
        {{- else}}
            - mountPath: {{ .path }}
              name: {{ .mediumtype | replace "," "-" | lower }}
        {{- end}}
      {{- end}}
    {{- end}}
  {{- end}}
{{- end -}}
