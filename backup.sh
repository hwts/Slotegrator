!/bin/bash

# Backup script

# Variables
BACKUP_DIR="backup"
USER="user"
SERVER="192.168.1.1"
DEBUG="false"
FULL_DIR="full"
INC_DIR="inc"
FULL_OLD_DIR="full_old"
INC_OLD_DIR="inc_old"

# Parse command line arguments
while getopts ":d:u:s:h" opt; do
  case $opt in
    d)
      BACKUP_DIR=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    s)
      SERVER=$OPTARG
      ;;
    h)
      echo "Usage: backup.sh [-d backup_dir] [-u user] [-s server] [-h]"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if debug mode is enabled
if [ "$DEBUG" == "true" ]; then
  echo "Debug mode enabled"
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir $BACKUP_DIR
fi

# Create full and incremental directories if they don't exist
if [ ! -d "$BACKUP_DIR/$FULL_DIR" ]; then
  mkdir $BACKUP_DIR/$FULL_DIR
fi

if [ ! -d "$BACKUP_DIR/$INC_DIR" ]; then
  mkdir $BACKUP_DIR/$INC_DIR
fi

# Create full_old and inc_old directories if they don't exist
if [ ! -d "$BACKUP_DIR/$FULL_OLD_DIR" ]; then
  mkdir $BACKUP_DIR/$FULL_OLD_DIR
fi

if [ ! -d "$BACKUP_DIR/$INC_OLD_DIR" ]; then
  mkdir $BACKUP_DIR/$INC_OLD_DIR
fi

# Connect to remote server and copy data
echo "Connecting to $SERVER..."
scp -r $USER@$SERVER:~/data $BACKUP_DIR

# Encrypt and compress data
echo "Encrypting and compressing data..."
gpg --symmetric --cipher-algo AES256 $BACKUP_DIR/data

# Rotate old backups
echo "Rotating old backups..."
logrotate -s $BACKUP_DIR/logrotate.state $BACKUP_DIR/logrotate.conf

