Тестировалось на ubuntu 22.04

# Задание 1 iptables

Скрипт настройки iptables

### 1. Даем права на исполнение 
```bash
chmod +x ./iptables.sh
```

### 2. Применяем правила iptables
```bash
./iptables.sh
```

# Задание 2 ansible
```bash
cd ./ansible
```
```bash
ansible-playbook -i production site.yml
```

# Задание 3 backup

Необходимые переменные:

### 1. Даем права на исполнение 
```bash
chmod +x ./backup.sh
```

### 3. Запускаем бекап
```bash
./backup.sh
```
