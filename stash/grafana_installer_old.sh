#!/bin/bash

installdir=/srv
needroot=1
startAsScreen=1

if [[ $needroot=1 && $(whoami) != 'root' ]]; then
    echo "Please execute this script as root! (/srv needs root to write)";
    echo "Exiting...";
fi

grafana=10.4.2
node=1.8.0
prometheus=2.51.2
loki=3.0.0
mysqlv=0.15.1

echo "Mini installer for grafana v2.0";
echo "Made by OverlordAkise";
echo "";

echo "Downloading tars and creating configs..."

wget -q https://dl.grafana.com/enterprise/release/grafana-enterprise-$grafana.linux-amd64.tar.gz
tar -zxf grafana-enterprise-$grafana.linux-amd64.tar.gz
cd grafana-v$grafana
echo "$installdir/grafana-v$grafana/bin/grafana --homepath \"$installdir/grafana-v$grafana\" server web" > start_grafana.sh
cd $installdir

wget -q https://github.com/prometheus/mysqld_exporter/releases/download/v$mysqlv/mysqld_exporter-$mysqlv.linux-amd64.tar.gz
tar -xf mysqld_exporter-$mysqlv.linux-amd64.tar.gz
cd mysqld_exporter-$mysqlv.linux-amd64
echo '[client]
user=mysqlexporter
password=abc123' > mysqld_exporter.cnf

wget -q https://github.com/prometheus/prometheus/releases/download/v$prometheus/prometheus-$prometheus.linux-amd64.tar.gz
tar -xf prometheus-$prometheus.linux-amd64.tar.gz
cd prometheus-$prometheus.linux-amd64
echo "global:
  scrape_interval:     15s
  evaluation_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['127.0.0.1:9090']
  - job_name: grafana
    static_configs:
      - targets: ['127.0.0.1:3000']
  - job_name: linux
    static_configs:
      - targets: ['127.0.0.1:9100']
  - job_name: loki
    static_configs:
      - targets: ['127.0.0.1:3100']" > prometheus.yml
echo "$installdir/prometheus-$prometheus.linux-amd64/prometheus --config.file=prometheus.yml" > start_prometheus.sh
cd $installdir

wget -q https://github.com/prometheus/node_exporter/releases/download/v$node/node_exporter-$node.linux-amd64.tar.gz
tar -xf node_exporter-$node.linux-amd64.tar.gz
cd node_exporter-$node.linux-amd64
echo "$installdir/node_exporter-$node.linux-amd64/node_exporter" > start_node.sh
cd $installdir

mkdir loki-$loki.linux-amd64
cd loki-$loki.linux-amd64
wget -q https://github.com/grafana/loki/releases/download/v$loki/loki-linux-amd64.zip
unzip -q loki-linux-amd64.zip
wget -q https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml
echo "$installdir/loki-$loki.linux-amd64/loki-linux-amd64 -config.file=loki-local-config.yaml" > start_loki.sh
cd $installdir

mkdir promtail-$loki.linux-amd64
cd promtail-$loki.linux-amd64
wget -q https://github.com/grafana/loki/releases/download/v$loki/promtail-linux-amd64.zip
unzip -q promtail-linux-amd64.zip
cd $installdir

echo "Making .sh files executable...";
find . -iname "*.sh" -exec chmod +x {} \;

if [ $startAsScreen=1 ]; then
    echo "Starting services in screens ...";
    echo "WARNING: Not starting mysqld_exporter as password needs to be configured!";
    echo "WARNING: Not starting promtail as logfiles need to be configured!";
    screen -A -d -m -S grafana $installdir/grafana-v$grafana/start_grafana.sh
    screen -A -d -m -S nodeexp $installdir/node_exporter-$node.linux-amd64/start_node.sh
    screen -A -d -m -S prometheus $installdir/prometheus-$prometheus.linux-amd64/start_prometheus.sh
    screen -A -d -m -S loki $installdir/loki-$loki.linux-amd64/start_loki.sh
fi

echo "Writing current versions..."
echo "grafana=$grafana
node=$node
prometheus=$prometheus
loki=$loki
mysqlv=$mysqlv" > _versions.txt

echo "Removing tars..."
rm grafana-enterprise-$grafana.linux-amd64.tar.gz
rm prometheus-$prometheus.linux-amd64.tar.gz
rm node_exporter-$node.linux-amd64.tar.gz
rm mysqld_exporter-$mysqlv.linux-amd64.tar.gz
rm loki-$loki.linux-amd64/loki-linux-amd64.zip

echo "Creating datasources..."
curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Disable-Provenance: true" http://admin:admin@localhost:3000/api/datasources -d \
'{"name":"Prometheus","type":"prometheus","url":"http://127.0.0.1:9090","access":"proxy","basicAuth":false,"isDefault":true}'
curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Disable-Provenance: true" http://admin:admin@localhost:3000/api/datasources -d \
'{"name":"Loki","type":"loki","url":"http://127.0.0.1:3100","access":"proxy","basicAuth":false}'

echo "Creating random grafana password in pass.txt..."
#p=`date +%s | sha256sum | base64 | head -c 32`
p=`strings /dev/urandom | grep -o  '[[:alnum:]]' | head -n 30 | tr -d '\n'`
echo $p > _pass.txt
cd grafana-v$grafana
bin/grafana cli admin reset-admin-password $p > grafana_pwreset_log.txt
cd $installdir

echo "Done!"
echo "Import Node dashboard with ID: 1860"
echo "Do not forget to update firewall settings!"
