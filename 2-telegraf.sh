#!/bin/bash
TELEGRAF_VERSION="1.12.4"
INFLUXDB_ADDRESS="prd-influxdb.senao.com.tw:8086"
HOSTNAME="influxdb-host"
wget https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz
tar -zxvf telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz
cd telegraf
cp usr/bin/telegraf /usr/local/bin

# create user
useradd --no-create-home --shell /bin/false telegraf
chown node_exporter:node_exporter /usr/local/bin/telegraf

mkdir /etc/telegraf
mkdir /etc/telegraf/telegraf.d
cp etc/telegraf/telegraf.conf /etc/telegraf/

# config influxdb ipaddress
sed -i 's/\# urls = \[\"http:\/\/127.0.0.1:8086\"\]/urls = \[\"http:\/\/'"$INFLUXDB_ADDRESS"'\"\]/' /etc/telegraf/telegraf.conf
# config hostname
sed -i 's/hostname = \"\"/hostname = \"'$HOSTNAME'\"/' /etc/telegraf/telegraf.conf


echo '[Unit]
Description=The plugin-driven server agent for reporting metrics into InfluxDB
Documentation=https://github.com/influxdata/telegraf
After=network.target

[Service]
EnvironmentFile=-/etc/default/telegraf
User=telegraf
ExecStart=/usr/local/bin/telegraf -config /etc/telegraf/telegraf.conf -config-directory /etc/telegraf/telegraf.d $TELEGRAF_OPTS
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartForceExitStatus=SIGPIPE
KillMode=control-group

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/telegraf.service

# enable telegraf in systemctl
systemctl daemon-reload
systemctl enable telegraf
systemctl start telegraf

