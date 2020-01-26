#!/bin/bash
INFLUXDB_VERSION="1.7.7"
wget https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUXDB_VERSION}_linux_amd64.tar.gz
mkdir influxdb-${INFLUXDB_VERSION}_linux_amd64
tar -xzf influxdb-${INFLUXDB_VERSION}_linux_amd64.tar.gz -C ./influxdb-${INFLUXDB_VERSION}_linux_amd64 --strip-components=2
cd influxdb-${INFLUXDB_VERSION}_linux_amd64/

# create user
useradd --no-create-home --shell /bin/false influxdb 

# create directories
mkdir -p /etc/influxdb
mkdir -p /var/lib/influxdb

# set ownership
chown influxdb:influxdb /etc/influxdb
chown influxdb:influxdb /var/lib/influxdb

# copy binaries
cp usr/bin/influx /usr/local/bin/
cp usr/bin/influxd /usr/local/bin/

chown influxdb:influxdb /usr/local/bin/influx
chown influxdb:influxdb /usr/local/bin/influxd

# copy config
cp etc/influxdb/influxdb.conf /etc/influxdb/
cp etc/logrotate.d/influxdb /etc/logrotate.d/

chown -R root:root /etc/influxdb/influxdb.conf
chown -R root:root /etc/logrotate.d/influxdb

# config ipaddress
sed -i 's/\# bind-address = \":8086\"/bind-address = \"0.0.0.0:8086\"/' /etc/influxdb/influxdb.conf

# setup systemd
echo '[Unit]
Description=InfluxDB is an open-source, distributed, time series database
Documentation=https://docs.influxdata.com/influxdb/
After=network-online.target

[Service]
User=influxdb
Group=influxdb
LimitNOFILE=65536
EnvironmentFile=-/etc/default/influxdb
ExecStart=/usr/local/bin/influxd -config /etc/influxdb/influxdb.conf $INFLUXD_OPTS
KillMode=control-group
Restart=on-failure

[Install]
WantedBy=multi-user.target
Alias=influxd.service' > /etc/systemd/system/influxdb.service

systemctl daemon-reload
systemctl enable influxdb
systemctl start influxdb