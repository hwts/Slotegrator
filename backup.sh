#!/bin/bash

# vars
BACKUP_NAME="backup"
BACKUP_MODE="inc"
STORE_TIME="60"
DEBUG_MODE="0"
SSH_KEY="/Users/user/.ssh/aeroem"
BACKUP_SRC="/mnt/docker_volumes"
SRC_USER="backup"
SRC_SERVER="192.168.8.53"

### full backup dirs
BACKUP_FULL_DEST="/Users/hwts/backups/Full"
BACKUP_FULL_OLD_DEST="/Users/hwts/backups/FullOld"

### inc backup dirs
BACKUP_INC_DEST="/Users/hwts/backups/Full"
BACKUP_INC_OLD_DEST="/Users/hwts/backups/FullOld"

DATE_NOW="$(date +"%Y-%m-%d_%H-%M")"

### Ключи и аргументы
while getopts ":m:b:d:u:n:s:vh" arg; do
  case $arg in
    m)
      BACKUP_MODE=$OPTARG
      ;;
    b)
      BACKUP_SRC=$OPTARG
      ;;
    d)
      BACKUP_DEST=$OPTARG
      ;;
    u)
      SRC_USER=$OPTARG
      ;;
    n)
      BACKUP_NAME=$OPTARG
      ;;
    s)
      SRC_SERVER=$OPTARG
      ;;
    v)
      DEBUG_MODE=1
      ;;
    h)
      echo "Usage: backup.sh [-m backup_mode] [-b source_backup_dir] [-d dest_backup_dir] [-u user] [-n backup_name] [-s server] [-v enable_debug] [-h help]"
      exit 0
      ;;
    \?)
      echo "Неверный формат -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Опция -$OPTARG требует аргумента." >&2
       exit 1
      ;;
  esac
done

if [ "$DEBUG_MODE" == "1" ]; then
  echo "Проверка корректности переменных"
fi

if [ "$BACKUP_MODE" != "full" ] && [ "$BACKUP_MODE" != "inc" ]; then
  echo "Error: Некоректное значение, установите тип бекапа full или inc" >&2
  exit 1
fi

if [ "$BACKUP_NAME" == "" ]; then
  echo "Error: Не заданно имя бекапа" >&2
  exit 1
 fi
 
if [ "$BACKUP_SRC" == "" ]; then
  echo "Error: Не задан путь для бекапа" >&2
  exit 1
fi

if [ "$SSH_KEY" == "" ]; then
  echo "Error: Не указан путь до ssh ключа" >&2
  exit 1
fi

if [ "$SRC_USER" == "" ]; then
  echo "Error: Не указан пользователь" >&2
  exit 1
fi

if [ "$SRC_SERVER" == "" ]; then
  echo "Error: Не указан адрес сервера" >&2
  exit 1
fi

if [ "$DEBUG_MODE" == "1" ]; then
  echo "Создание директорий для бекапа"
fi

### Создаем директории если не существуют
if [ ! -d "$BACKUP_FULL_DEST" ]; then
  mkdir -p  $BACKUP_FULL_DEST
fi

if [ ! -d "$BACKUP_FULL_OLD_DEST" ]; then
  mkdir -p $BACKUP_FULL_OLD_DEST
fi

if [ ! -d "$BACKUP_INC_DEST" ]; then
  mkdir -p $BACKUP_INC_DEST
fi

if [ ! -d "$BACKUP_INC_OLD_DEST" ]; then
  mkdir -p $BACKUP_INC_OLD_DEST
fi

if [ "$DEBUG_MODE" == "1" ]; then
  echo "Запуск $BACKUP_MODE бекапа"
fi

if [ "$BACKUP_MODE" == "full" ]; then

  BACKUP_DEST=$BACKUP_FULL_DEST
  BACKUP_OLD_DEST=$BACKUP_FULL_OLD_DEST
  BACKUP_DEST_DATE=$BACKUP_OLD_DEST/$BACKUP_NAME-$DATE_NOW


  rsync -az -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY" \
  "$SRC_USER"@"$SRC_SERVER":"$BACKUP_SRC" $BACKUP_OLD_DEST/$BACKUP_NAME
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Копирование файлов завершено успешно"
  else
    echo "Копирование файлов завершено c ошибками"
  fi

  cd "$BACKUP_OLD_DEST" && tar -czPf "$BACKUP_DEST_DATE".tar.gz ./$BACKUP_NAME 
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Архивация файлов завершена успешно"
  else
    echo "Архивация файлов завершена c ошибками"
  fi
  
  find ./$BACKUP_NAME -maxdepth 0 -type d -exec rm -rf {} \;
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Удаление старых файлов завершена успешно"
  else
    echo "Удаление старых файлов завершена c ошибками"
  fi

  rm -f "$BACKUP_DEST/latest"
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
     echo "Удаление ссылки на последний бекап завершена успешно"
  else
    echo "Удаление ссылки на последний бекап завершена c ошибками"
  fi

  ln -s "$BACKUP_DEST_DATE".tar.gz "$BACKUP_DEST/latest"
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Создание ссылки на последний бекап завершена успешно"
  else
    echo "Создание ссылки на последний бекап завершена c ошибками"
  fi

  cd $BACKUP_DEST && ls -1tr $BACKUP_DEST | head -n -1 | xargs rm -rf
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Отбор и удаление заархивированных завершен успешно"
  else
    echo "Отбор и удаление заархивированных завершен c ошибками"
  fi

  find "$BACKUP_OLD_DEST/" -maxdepth 1 -type f -mmin +$STORE_TIME -exec rm -rf {} \;
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Удаление старых бекапов завершено успешно"
  else
    echo "Удаление старых бекапов завершено c ошибками"
  fi

elif [ "$BACKUP_MODE" == "inc" ]; then

  BACKUP_DEST=$BACKUP_INC_DEST
  BACKUP_OLD_DEST=$BACKUP_INC_OLD_DEST
  BACKUP_DEST_DATE=$BACKUP_OLD_DEST/$BACKUP_NAME-$DATE_NOW

  mkdir -p $BACKUP_OLD_DEST/"$BACKUP_NAME"-"$DATE_NOW"
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Создание директории для нового бекапа завершено успешно"
  else
    echo "Создание директории для нового бекапа завершено c ошибками"
  fi

  rsync -az -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY" \
  --link-dest="$BACKUP_DEST" "$SRC_USER"@"$SRC_SERVER":"$BACKUP_SRC" "$BACKUP_DEST_DATE"
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Копирование файлов завершено успешно"
  else
    echo "Копирование файлов завершено c ошибками"
  fi

  rm -f "$BACKUP_DEST/latest"
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
     echo "Удаление ссылки на последний бекап завершена успешно"
  else
    echo "Удаление ссылки на последний бекап завершена c ошибками"
  fi

  ln -s "$BACKUP_DEST_DATE" "$BACKUP_DEST/latest"
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
     echo "Создание ссылки на последний бекап завершена успешно"
  else
    echo "Создание ссылки на последний бекап завершена c ошибками"
  fi

  find "$BACKUP_OLD_DEST/" -maxdepth 1 -type d -mmin +$STORE_TIME -exec rm -rf {} \;
  if [ $? -eq 0] && [ "$DEBUG_MODE" == "1" ]; then
    echo "Удаление старых бекапов завершено успешно"
  else
    echo "Удаление старых бекапов завершено c ошибками"
  fi
  
fi