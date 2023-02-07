# Задание 1 iptables

### 1. Создаем файлы для логирования цепочек 
 
/etc/rsyslog.d/iptables_all_ports.conf
```bash
:msg, contains, "Iptables: ALL_PORTS" -/var/log/iptables_all_ports.log
```

/etc/rsyslog.d/iptables_app_db.conf
```bash
:msg, contains, "Iptables: APP_DB" -/var/log/iptables_app_db.log
```

/etc/rsyslog.d/iptables_users.conf
```bash
:msg, contains, "Iptables: USERS" -/var/log/iptables_users.log
```

/etc/rsyslog.d/iptables_limit_port_users.conf
```bash
:msg, contains, "Iptables: LIMIT_PORT_USERS" -/var/log/iptables_limit_port_users.log
```

/etc/rsyslog.d/iptables_output_ports.conf
```bash
:msg, contains, "Iptables: OUTPUT_PORTS" -/var/log/iptables_output_ports.log
```

/etc/rsyslog.d/iptables_drop_all.conf
```bash
:msg, contains, "Iptables: DROP_ALL" -/var/log/iptables_drop_all.log
```

### 2. Перезагружаем службу
```bash
systemctl restart rsyslog.service
```
### 3.применяем правила iptables
```bash
iptables-restore < iptables.txt
```
