#!/bin/bash

grafana=10.3.3
node=1.7.0
prometheus=2.50.1
loki=2.9.5

echo "Mini installer for grafana";
echo "Made by OverlordAkise";
echo "";

echo "Downloading tars and creating configs..."

wget https://dl.grafana.com/enterprise/release/grafana-enterprise-$grafana.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-$grafana.linux-amd64.tar.gz
echo "./grafana-v$grafana/bin/grafana server --homepath \"grafana-v$grafana\" web" > start_grafana.sh

#wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.0/mysqld_exporter-0.15.0.linux-amd64.tar.gz
#tar -xvf mysqld_exporter-0.15.0.linux-amd64.tar.gz
#nano mysqld_exporter.cnf
#    [client]
#    user=mysqlexporter
#    password=abc123

#echo './mysqld_exporter-0.15.0.linux-amd64/mysqld_exporter --config.my-cnf mysqld_exporter.cnf --collect.global_status --collect.info_schema.innodb_metrics --collect.auto_increment.columns --collect.info_schema.processlist --collect.binlog_size --collect.info_schema.tablestats --collect.global_variables --collect.info_schema.query_response_time --collect.info_schema.userstats --collect.info_schema.tables --collect.perf_schema.tablelocks --collect.perf_schema.file_events --collect.perf_schema.eventswaits --collect.perf_schema.indexiowaits --collect.perf_schema.tableiowaits' > start_mysql.sh

wget https://github.com/prometheus/prometheus/releases/download/v$prometheus/prometheus-$prometheus.linux-amd64.tar.gz
tar -xvf prometheus-$prometheus.linux-amd64.tar.gz
echo "global:
  scrape_interval:     15s
  evaluation_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  - job_name: grafana
    static_configs:
      - targets: ['localhost:3000']
  - job_name: linux
    static_configs:
      - targets: ['localhost:9100']
  - job_name: loki
    static_configs:
      - targets: ['localhost:3100']" > prometheus.yml
echo "./prometheus-$prometheus.linux-amd64/prometheus --config.file=prometheus.yml" > start_prometheus.sh

wget https://github.com/prometheus/node_exporter/releases/download/v$node/node_exporter-$node.linux-amd64.tar.gz
tar -xvf node_exporter-$node.linux-amd64.tar.gz
echo "./node_exporter-$node.linux-amd64/node_exporter" > start_node.sh

wget https://github.com/grafana/loki/releases/download/v$loki/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml
echo "./loki-linux-amd64 -config.file=loki-local-config.yaml" > start_loki.sh

echo "Starting services..."
chmod +x start_grafana.sh start_node.sh start_prometheus.sh start_loki.sh
screen -A -d -m -S grafana ./start_grafana.sh
screen -A -d -m -S nodeexp ./start_node.sh
screen -A -d -m -S prometheus ./start_prometheus.sh
screen -A -d -m -S loki ./start_loki.sh

echo "Writing current versions..."
echo "grafana=$grafana
node=$node
prometheus=$prometheus
loki=$loki" > _versions.txt

echo "Removing tars..."
rm grafana-enterprise-$grafana.linux-amd64.tar.gz
rm prometheus-$prometheus.linux-amd64.tar.gz
rm node_exporter-$node.linux-amd64.tar.gz
rm loki-linux-amd64.zip

echo "Creating datasources..."
curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Disable-Provenance: true" http://admin:admin@localhost:3000/api/datasources -d \
'{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","basicAuth":false,"isDefault":true}'
curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Disable-Provenance: true" http://admin:admin@localhost:3000/api/datasources -d \
'{"name":"Loki","type":"loki","url":"http://localhost:3100","access":"proxy","basicAuth":false}'

echo "Creating random grafana password in pass.txt..."
#p=`date +%s | sha256sum | base64 | head -c 32`
p=`strings /dev/urandom | grep -o  '[[:alnum:]]' | head -n 30 | tr -d '\n'`
echo $p > _pass.txt
cd grafana-v$grafana
bin/grafana cli admin reset-admin-password $p
cd ..

echo "Done!"
echo "Import Node dashboard with ID: 1860"
echo "Do not forget to update firewall settings!"

# wget https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip


