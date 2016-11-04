#!/usr/bin/env bash

all_prometheus_git="https://github.com/prometheus/prometheus.git"
all_prometheus_ref="36fbdcc30fd13ad796381dc934742c559feeb1b5"

all_prometheus_flags=("-storage.local.memory-chunks=512288"
                      "-storage.local.retention=8760h0m0s"
                      "-web.external-url=http://metrics.ipfs.team/prometheus")

all_prometheus_scrape_interval="15s"
all_prometheus_scrape_timeout="10s"
all_prometheus_evaluation_timeout="15s"
