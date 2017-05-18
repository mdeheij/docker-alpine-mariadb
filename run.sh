#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

if [ ! -d /var/lib/mysql/mysql ]; then
	chown -R mysql:mysql /var/lib/mysql

	mysql_install_db --user=mysql > /dev/null

	ROOT_PASSWORD=`pwgen 16 1`
	echo "ROOT PASSWORD: $ROOT_PASSWORD"

	MYSQL_DATABASE=${MYSQL_DATABASE:-""}
	MYSQL_USER=${MYSQL_USER:-""}
	MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

	tmpfile=`mktemp`
	if [ ! -f "$tmpfile" ]; then
	    return 1
	fi

	cat << EOF > $tmpfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$ROOT_PASSWORD") WHERE user='root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
EOF

	if [ "$MYSQL_DATABASE" != "" ]; then
	    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tmpfile
	    if [ "$MYSQL_USER" != "" ]; then
		echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tmpfile
	    fi
	fi

	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tmpfile
	rm -f $tmpfile
fi

exec /usr/bin/mysqld --user=mysql --console
