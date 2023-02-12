#!/bin/bash

# vars
BACKUP_NAME="backup"
#### full - полный бекап, inc - инкрементный
BACKUP_MODE="inc"
#DEBUG_MODE="false" Режим debug будет доступен в след версии скрипта
#ROTATE="" Режим Logrotate будет доступен в след версии скрипта
SSH_KEY="./id_rsa"
BACKUP_SRC="/files"
SRC_USER="user"
SRC_SERVER="10.10.33.101"

### full backup dirs
BACKUP_FULL_DEST="/mnt/backups/Full"
BACKUP_FULL_OLD_DEST="/mnt/backups/FullOld"

### inc backup dirs
BACKUP_INC_DEST="/mnt/backups/Inc"
BACKUP_INC_OLD_DEST="/mnt/backups/IncOld"

DATE_NOW="$(date +"%Y-%m-%d_%H-%M")"

### Ключи и аргументы
while getopts ":m:b:d:u:n:s:h" arg; do
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
    h)
      echo "Usage: backup.sh [-m backup_mode] [-b source_backup_dir] [-d dest_backup_dir] [-u user] [-n backup_name] [-s server] [-v debug] [-h help]"
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


### Проверка корректности опций
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

### backup

if [ "$BACKUP_MODE" == "full" ]; then

  BACKUP_DEST=$BACKUP_FULL_DEST
  BACKUP_OLD_DEST=$BACKUP_FULL_OLD_DEST

  rsync -az -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY" \
  "$SRC_USER"@"$SRC_SERVER":"$BACKUP_SRC" $BACKUP_DEST;
   cd "$BACKUP_DEST" && tar -czPf ./"$BACKUP_NAME"-"$DATE_NOW".tar.gz  ."$BACKUP_SRC"
  find ./* -maxdepth 0 -type d -exec rm -rf {} \;
fi

if [ "$BACKUP_MODE" == "inc" ]; then

  BACKUP_DEST=$BACKUP_INC_DEST
  BACKUP_OLD_DEST=$BACKUP_INC_OLD_DEST

  mkdir -p $BACKUP_OLD_DEST/"$BACKUP_NAME"-"$DATE_NOW"
  rsync -az -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY" \
  --link-dest="$BACKUP_DEST" "$SRC_USER"@"$SRC_SERVER":"$BACKUP_SRC" $BACKUP_OLD_DEST/"$BACKUP_NAME"-"$DATE_NOW"
  rm -rf "$BACKUP_DEST"
  ln -s "$BACKUP_OLD_DEST/$BACKUP_NAME-$DATE_NOW" "$BACKUP_DEST"
fi
