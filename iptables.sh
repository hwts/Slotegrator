#!/bin/bash

# Создаем конфиг для логирования цепочек
echo ':msg, contains, "Iptables: ALL_PORTS" -/var/log/iptables_all_ports.log' > /etc/rsyslog.d/iptables_all_ports.conf

echo ':msg, contains, "Iptables: APP_DB" -/var/log/iptables_app_db.log' > /etc/rsyslog.d/iptables_app_db.conf

echo ':msg, contains, "Iptables: USERS" -/var/log/iptables_users.log' > /etc/rsyslog.d/iptables_users.conf

echo ':msg, contains, "Iptables: LIMIT_PORT_USERS" -/var/log/iptables_limit_port_users.log' > /etc/rsyslog.d/iptables_limit_port_users.conf

echo ':msg, contains, "Iptables: OUTPUT_PORTS" -/var/log/iptables_output_ports.log' > /etc/rsyslog.d/iptables_output_ports.conf

echo ':msg, contains, "Iptables: DROP_ALL" -/var/log/iptables_drop_all.log' > /etc/rsyslog.d/iptables_drop_all.conf

# Рестуртуем службу
systemctl restart rsyslog.service

# Очищаем существующие правила
iptables -F
iptables -X

# применяем правила
iptables-restore < ./iptables.txt
