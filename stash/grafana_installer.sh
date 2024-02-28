
echo "Mini installer for grafana";
echo "Made by OverlordAkise";
echo "";

echo "Downloading tars and creating configs..."

wget https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.2.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-10.2.2.linux-amd64.tar.gz
echo "./grafana-v10.2.2/bin/grafana server --homepath \"grafana-v10.2.2\" web" > start_grafana.sh

#wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.0/mysqld_exporter-0.15.0.linux-amd64.tar.gz
#tar -xvf mysqld_exporter-0.15.0.linux-amd64.tar.gz
#nano mysqld_exporter.cnf
#    [client]
#    user=mysqlexporter
#    password=abc123

#echo './mysqld_exporter-0.15.0.linux-amd64/mysqld_exporter --config.my-cnf mysqld_exporter.cnf --collect.global_status --collect.info_schema.innodb_metrics --collect.auto_increment.columns --collect.info_schema.processlist --collect.binlog_size --collect.info_schema.tablestats --collect.global_variables --collect.info_schema.query_response_time --collect.info_schema.userstats --collect.info_schema.tables --collect.perf_schema.tablelocks --collect.perf_schema.file_events --collect.perf_schema.eventswaits --collect.perf_schema.indexiowaits --collect.perf_schema.tableiowaits' > start_mysql.sh

wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar -xvf prometheus-2.45.0.linux-amd64.tar.gz
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
      - targets: ['localhost:9100']" > prometheus.yml
echo "./prometheus-2.45.0.linux-amd64/prometheus --config.file=prometheus.yml" > start_prometheus.sh

wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
echo "./node_exporter-1.7.0.linux-amd64/node_exporter" > start_node.sh

echo "Starting services..."
chmod +x start_grafana.sh start_node.sh start_prometheus.sh
screen -A -d -m -S grafana ./start_grafana.sh
screen -A -d -m -S nodeexp ./start_node.sh
screen -A -d -m -S prometheus ./start_prometheus.sh

echo "Removing tars..."
rm grafana-enterprise-10.2.2.linux-amd64.tar.gz
rm prometheus-2.45.0.linux-amd64.tar.gz
rm node_exporter-1.7.0.linux-amd64.tar.gz

echo "Done!"





# wget https://github.com/grafana/loki/releases/download/v2.9.4/loki-linux-amd64.zip

# wget https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip


