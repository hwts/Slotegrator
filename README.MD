# Задание 1 iptables

Скрипт настройки iptables

### 1. Скачиваем репозиторий
```bash
git clone https://github.com/hwts/Slotegrator.git
```

### 2. Даем права на исполнение 
```bash
chmod +x ./iptables.sh
```

### 3. Применяем правила iptables
```bash
sh ./iptables.sh
```

# Задание 2 iptables
Тестировалось на ubuntu 22.04
```bash
cd ./ansible
```
```bash
ansible-playbook -i production site.yml
```
