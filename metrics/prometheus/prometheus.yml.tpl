---
global:
  scrape_interval:     $(var prometheus_scrape_interval)
  scrape_timeout:      $(var prometheus_scrape_timeout)
  evaluation_interval: $(var prometheus_evaluation_interval)

scrape_configs:
  - job_name: 'gateway'
    metrics_path: '/debug/metrics/prometheus'
    static_configs:
$(for h in $(lookup prometheus_gateway_hosts); do
  echo   '      - targets:'
  printf '        - %s:5001\n' $(host=$h var cjdns_ipv6)
  echo   '        labels:'
  printf '          host: %s\n' $h
  echo   '          network: v04x'
done)

  - job_name: 'storage'
    metrics_path: '/debug/metrics/prometheus'
    static_configs:
$(for h in $(lookup prometheus_storage_hosts); do
  echo   '      - targets:'
  printf '        - %s:5001\n' $(host=$h var cjdns_ipv6)
  echo   '        labels:'
  printf '          host: %s\n' $h
  echo   '          network: v04x'
done)

  - job_name: 'mtail'
    metrics_path: '/metrics'
    static_configs:
$(for h in $(lookup prometheus_all_hosts); do
  echo   '      - targets:'
  printf '        - %s:5001\n' $(host=$h var cjdns_ipv6)
  echo   '        labels:'
  printf '          host: %s\n' $h
done)
    metric_relabel_configs:
      - source_labels: [prog]
        regex: .*
        action: replace
        target_label: prog
      - source_labels: [exported_instance]
        regex: .*
        action: replace
        target_label: exported_instance

  - job_name: 'host'
    metrics_path: '/metrics'
    static_configs:
$(for h in $(lookup prometheus_all_hosts); do
  echo   '      - targets:'
  printf '        - %s:5001\n' $(host=$h var cjdns_ipv6)
  echo   '        labels:'
  printf '          host: %s\n' $h
done)

  - job_name: 'blackbox'
    metrics_path: '/metrics'
    static_configs:
$(for h in $(lookup prometheus_all_hosts); do
  echo   '      - targets:'
  printf '        - %s:5001\n' $(host=$h var cjdns_ipv6)
  echo   '        labels:'
  printf '          host: %s\n' $h
done)
    metric_relabel_configs:
      - source_labels: [handler]
        regex: .*
        action: replace
        target_label: handler

  - job_name: 'prometheus'
    metrics_path: '/prometheus/metrics'
    static_configs:
$(for h in $(lookup prometheus_metrics_hosts); do
  echo   '      - targets:'
  printf '        - %s:5001\n' $(host=$h var cjdns_ipv6)
  echo   '        labels:'
  printf '          host: %s\n' $h
done)

{% for src in probers %}
  - job_name: pages_{{src}}
    metrics_path: /probe
    params:
      module: []  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - prometheus.io   # Target to probe
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: 127.0.0.1:9115  # Blackbox exporter.
{% endfor %}

{% for dest in gateway_targets %}
  - job_name: pages_ipfs_io_{{dest}}
    metrics_path: /probe
    params:
      module: [ipfs_io]
      target: [{{dest}}.i.ipfs.io]
    static_configs:
{% for src in probers %}
      - targets:
          - '[{{ cjdns_identities[src].ipv6 }}]:9115'
        labels:
          host: '{{dest}}'
          prober: '{{src}}'
          page: 'ipfs.io'
{% endfor %}
{% endfor %}

{% for dest in gateway_targets %}
  - job_name: pages_ipld_io_{{dest}}
    metrics_path: /probe
    params:
      module: [ipld_io]
      target: [{{dest}}.i.ipfs.io]
    static_configs:
{% for src in probers %}
      - targets:
          - '[{{ cjdns_identities[src].ipv6 }}]:9115'
        labels:
          host: '{{dest}}'
          prober: '{{src}}'
          page: 'ipld.io'
{% endfor %}
{% endfor %}

{% for dest in gateway_targets %}
  - job_name: pages_multiformats_io_{{dest}}
    metrics_path: /probe
    params:
      module: [multiformats_io]
      target: [{{dest}}.i.ipfs.io]
    static_configs:
{% for src in probers %}
      - targets:
          - '[{{ cjdns_identities[src].ipv6 }}]:9115'
        labels:
          host: '{{dest}}'
          prober: '{{src}}'
          page: 'multiformats.io'
{% endfor %}
{% endfor %}

  - job_name: 'watcher'
    metrics_path: '/metrics'
    static_configs:
      - targets:
          - 'mars.i.ipfs.team:9999'
        labels:
          host: mars
