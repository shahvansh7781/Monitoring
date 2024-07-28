#!/bin/bash
sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

sudo ufw allow 9090/tcp
sudo ufw reload

wget https://github.com/prometheus/prometheus/releases/download/v2.53.1/prometheus-2.53.1.linux-amd64.tar.gz
tar zxvf prometheus-2.53.1.linux-amd64.tar.gz
cd prometheus-2.53.1.linux-amd64

sudo cp prometheus promtool /usr/local/bin/
sudo cp -r console_libraries consoles prometheus.yml /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus

cat << EOF > /etc/prometheus/prometheus.yml

# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "node_exporter"
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        target_label: instance
      - source_labels: [__meta_ec2_public_ip]
        target_label: ip
    ec2_sd_configs:
      - filters:
         - name: "subnet-id"
           values: ["replace_subnet_id"]
        port: 9100

EOF

cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Service
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
