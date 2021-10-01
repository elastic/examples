variable "project_id" {
  type        = string
  description = "The GCP Project ID."
}

variable "region" {
  type        = string
  description = "GCP region to create resources into."
}

variable "connection_url" {
  type        = string
  description = "The Elasticsearch Cloud ID or connection URL."
}

variable "api_key" {
  type        = string
  description = "The Elasticsearch API key."
}

variable "dataflow_template_version" {
  type        = string
  description = "GCP Dataflow Flex template version. See https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming."
  default     = "latest"
}

# Audit logs
variable "audit_log_sampling" {
  type        = number
  description = "Sampling fraction (0 to 1) for Audit logs"
  default     = 1
}

variable "audit_log_forwarder_batch_size" {
  type        = number
  description = "Batch size for Audit logs fowarder job"
  default     = 1000
}

variable "audit_log_on_job_delete" {
  type        = string
  description = "Action to perform when Audit logs forwarder job is deleted (drain or cancel)"
  default     = "drain"
}
