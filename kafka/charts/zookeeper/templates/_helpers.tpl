{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "zookeeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zookeeper.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zookeeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
reate unified labels for kafka components
*/}}

{{- define "common.matchLabels" -}}
app.kubernetes.io/name: {{ include "zookeeper.name" .  }}
app.kubernetes.io/instance: {{ .Release.Name  }}
{{- end -}}

{{- define "common.metaLabels" -}}
helm.sh/chart: {{ include "zookeeper.chart" .  }}
app.kubernetes.io/managed-by: {{ .Release.Service  }}
{{- end -}}

{{- define "zookeeper.matchLabels" -}}
app.kubernetes.io/name: {{ include "zookeeper.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "zookeeper.labels" -}}
{{ include "common.metaLabels" .  }}
{{ include "zookeeper.matchLabels" . }}
{{- end -}}

{{- define "replication.factor" }}
{{- $replicationFactorOverride := index .Values "configurationOverrides" "offsets.topic.replication.factor" }}
{{- default .Values.replicas $replicationFactorOverride }}
{{- end -}}

{{/*
Create a server list string based on fullname, namespace, # of servers
in a format like "zkhost1:port:port;zkhost2:port:port"
*/}}
{{- define "zookeeper.serverlist" -}}
{{- $namespace := .Release.Namespace }}
{{- $name := include "zookeeper.fullname" . -}}
{{- $serverPort := .Values.ports.server -}}
{{- $leaderElectionPort := .Values.ports.election -}}
{{- $zk := dict "replicas" (list) -}}
{{- range $idx, $v := until (int .Values.replicas) }}
{{- $noop := printf "%s-%d.%s-headless.%s:%d:%d" $name $idx $name $namespace (int $serverPort) (int $leaderElectionPort) | append $zk.replicas | set $zk "servers" -}}
{{- end }}
{{- printf "%s" (join ";" $zk.replicas) | quote -}}
{{- end -}}
