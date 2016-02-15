// File: config/scripts/dns_transform.groovy
def alerts = [:]
for(item in ctx.payload.aggregations.by_domain.buckets) {
    alerts[item.key] = [
        total_requests : item.doc_count,
        unique_hostnames : item.unique_hostnames.value,
        total_bytes_in : item.total_bytes_in.value,
        total_bytes_out : item.total_bytes_out.value,
        total_bytes : item.total_bytes_in.value + item.total_bytes_out.value,
    ]
}
return [alerts: alerts]
