#!/bin/bash

set -e

MYSQL_CONF_DIR='/etc/my.cnf'

wget https://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm

rpm -ivh  mysql57-community-release-el7-10.noarch.rpm 

yum update -y
yum -y install mysql-server mysql-devel

sed -i 's/^datadir/#datadir/' $MYSQL_CONF_DIR
sed -i '/datadir/a\datadir=\/data\/mysql\n' $MYSQL_CONF_DIR
sed -i '/^datadir/a\character-set-server=utf8\n' $MYSQL_CONF_DIR
sed -i '/^datadir/a\default-storage-engine=INNODB\n' $MYSQL_CONF_DIR

mkdir /data/mysql -p
chown mysql:mysql -R  /data/mysql
service mysqld start

MYSQL_PID=`ps aux | grep -w mysqld | awk '{ if ($1 == "mysql") { print $2}}'`

start_switch=0
while [[ "$MYSQL_PID" == "" ]]
do
    if [[ start_switch -eq 0 ]]; then
        echo "begin start mysql service ...e"
        service mysqld start > /dev/null 2>&1 &
        start_switch=1
    fi
    sleep 1
    MYSQL_PID=`ps aux | grep -w mysqld | awk '{ if ($1 == "mysql") { print $2}}'`
    echo "start switch is $start_switch, mysql starting ......"

done

MYSQL_PASSWD=`grep "A temporary password" /var/log/mysqld.log | awk 'BEGIN {FS="root@localhost: "}  { print $2 }'` 
PASSWD_LEN=`echo $MYSQL_PASSWD | awk '{ print length($0)}'`

if [[ ${PASSWD_LEN} -eq  0 ]]; then
        echo "none passwd"
    exit
fi
echo "password is "${MYSQL_PASSWD}

mysql --connect-expired-password  -u root -p${MYSQL_PASSWD} <<EOF
set global validate_password_length=1;
set global validate_password_policy=0;
SET PASSWORD = PASSWORD("123456");
grant all privileges on *.* to root@'%' identified by '123456';
flush privileges;
EOF

firewall-cmd --permanent --zone=public --add-port=3306/tcp
systemctl restart firewalld.service
