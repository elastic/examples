resource "google_pubsub_topic" "audit_log_to_es" {
  name = "audit-logs-to-es"
}

resource "google_pubsub_subscription" "audit_log_to_es" {
  name  = "audit-logs-to-es"
  topic = google_pubsub_topic.audit_log_to_es.name
}

resource "google_pubsub_topic" "audit_log_to_es_errors" {
  name = "audit-logs-to-es-errors"
}

resource "google_logging_project_sink" "audit_log_to_es" {
  name        = "audit-logs-to-es"
  description = "Sink Audit logs with sampling for Dataflow Elasticsearch forwarder"

  destination = "pubsub.googleapis.com/${google_pubsub_topic.audit_log_to_es.id}"
  filter      = "protoPayload.@type=\"type.googleapis.com/google.cloud.audit.AuditLog\" and sample(insertId, ${var.audit_log_sampling})"

  unique_writer_identity = true
}

resource "google_dataflow_flex_template_job" "forward_audit_logs_to_es" {
  provider = google-beta
  name     = "forward-audit-logs-to-es"

  on_delete = var.audit_log_on_job_delete

  container_spec_gcs_path = "gs://dataflow-templates/${var.dataflow_template_version}/flex/PubSub_to_Elasticsearch"

  parameters = {
    dataset = "audit"

    connectionUrl = var.connection_url
    apiKey        = var.api_key

    inputSubscription = google_pubsub_subscription.audit_log_to_es.id
    errorOutputTopic  = google_pubsub_topic.audit_log_to_es_errors.id

    batchSize = var.audit_log_forwarder_batch_size
  }
}
