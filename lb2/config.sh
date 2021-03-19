#!/bin/bash
#
# Hier mit diesem Config File soll vor allem die Datenbank installiert und konfiguriert werden
# Zudem wird die Firewall auf der Vagrant Box aktiviert und der Port 22 und 3306 wird geöffnet
#

# Hier wird das Root Passwort gesetzt damit die Installation ohne Unterbruch weiterläuft
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'

# Hier wird der MySQL-Server und ufw installiert
sudo apt-get install -y mysql-server ufw

# Mit dieser Zeile wird der MySQL Port geöffnet
sudo sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Auf dieser Zeile wird das Passwort für den Root db User geändert und erlaubt das von jeder IP darauf verbunden werden kann
mysql -uroot -padmin <<%EOF%
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'admin';
	FLUSH PRIVILEGES;
%EOF%

# Hier wird ein Restart des services gemacht damit die Konfigurationsänderungen übernommen werden
sudo service mysql restart

# Hier wird die Firewall der Box aktiviert und Port 22 und 3306 für den Host geöffnet
sudo ufw allow from 192.168.55.1 to any port 22
sudo ufw allow from 192.168.55.1 to any port 3306
sudo ufw -f enable

