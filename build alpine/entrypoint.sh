#!/bin/sh

#File to edit
config_file='/var/www/localhost/htdocs/config.php'
httpd_file='/etc/apache2/httpd.conf'
wakeonlanscript='/bin/wakeonlan.sh'


function create_or_restore_from_backup {
  FILE="$1"
  FILE_BAK="$FILE.bak"
  
  if [ -f "$FILE_BAK" ]; then
    echo "backup exists - restoring $FILE"    
  else
    echo "Creating backup $FILE_BAK"
  fi
}

#Searches $1 and replaces with $2 in $file
function search_and_replace {
  sed -i.bak 's|'$1'|'$2'|g' $3
}

create_or_restore_from_backup(${config_file})
create_or_restore_from_backup(${httpd_file})
create_or_restore_from_backup(${wakeonlanscript})


#RWSOLS
#Does everything for ENV-vars with RWSOLS_*
printenv | grep RWSOLS_ | while read v; do
  name=${v%%=*}
  value=${v#*=}

  #Checks if REPLACE_envvar is in $file
  if grep -q "REPLACE_$name" "$config_file"; then
    search_and_replace REPLACE_$name ${value} ${config_file}
  fi
done

#Settings RWSOLS_HASH for keyphrase
echo "search_and_replace PASSPHRASE"
RWSOLS_HASH=$(php -r "echo utf8_encode(password_hash(trim('$PASSPHRASE'), PASSWORD_DEFAULT));")

search_and_replace RWSOLS_HASH $RWSOLS_HASH $config_file


#APACHE2 port mapping

OLD_PORT="80"
NEW_PORT="$APACHE2_PORT"

OLD_IFACE="eth0"
NEW_IFACE="$INTERFACE_FOR_WOL"

echo "search_and_replace $OLD_PORT with $NEW_PORT"



search_and_replace ${OLD_PORT} ${NEW_PORT} $httpd_file


echo "search_and_replace $OLD_IFACE with $NEW_IFACE"
search_and_replace ${OLD_IFACE} ${NEW_IFACE} $wakeonlanscript


mkdir -p /var/log/apache2

export APACHE_LOG_DIR=/var/log/apache2

#Starting apache2
echo "Starting Apache2: httpd -D FOREGROUND"
set -e

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND "$@"
