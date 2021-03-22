# M300 LB2 Dokumentation

## Inhaltsverzeichnis

## Einleitung
In diesem Dokument wird die **LB2** des Moduls 300 beschrieben. Die Aufgabe war es mit Hilfe von Vagrant ein Infrastructure as Code Projekt machen indem ein Service oder Serverdienst automatisiert wird. Ich habe mich dazu entschieden mit Vagrant eine Virtualbox VM aufzusetzen welche eine Datenbank enthält sowie Firewall. Mit MySQL Workbench soll dann vom Host aus darauf zugegriffen werden. In der Grafischen Übersicht also im Netzwerk Plan welcher Folgt sollte klar sein wie das Projekt aufgebaut ist. 

## Grafische Übersicht

![Netzwerkplan LB2](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Netzwerkplan.png)

## Erklärung von Code
### Vagrantfile
Mit dem Vagrantfile wird die Vagrant Box erstellt. Gleich unten sind die einzelnen Commands beschrieben im Vagrantfile.

1. Config des Virtuellen Maschine wird definiert: 

	`Vagrant.configure("2") do |config|`

2. Ubuntu 18.04 wird als OS der Virtuellen Maschine definiert: 

	`config.vm.box = "ubuntu/bionic64"`

3. Der Hostname der Virtuellen Maschine wird definiert: 

	`config.vm.hostname = "m300lb2"`

4. VirtualBox wird als Provider der Virtuellen Maschine definiert. Dies bedeuted das die Virtuelle Maschine auf VirtualBox läuft: 

	`config.vm.provider "virtualbox" do |vb|`

5. Der RAM der Virtuellen Maschine wird mit dieser Zeile definiert: 

	`vb.memory = "2048"`

6. Der Name der Virtuellen Maschine in VirtualBox selber wird hier definiert: 

	`vb.name = "m300lb2"`
*Der Name ist nicht dasselbe wie der vorher definierte Hostname*

7. Hier wird das Shell Script definiert welches die Virtuelle Maschine verwendet. Das Shell Script hat den config.sh. In diesem Shell Script stehen Commands welche dann auf der Virtuellen Maschine ausgeführt werden: 

	`config.vm.provision "shell", path: "config.sh"`

8. DIe IP Adresse der Virtullen Maschine wird hinter ip: definiert. Private_network bedeuted das die IP-Adresse aus einem Privaten IP-Bereich ist: 

	`config.vm.network "private_network", ip: "192.168.55.200"`

### config Shell File
Das config Shell File wird im Vagrantfile referenziert und dieses File enthaltet Commands welche auf der Virtuellen Maschine ausgeführt werden. Gleich unten werden die einzelnen Commands welche im config Shell File vorhanden sind beschrieben. 

1. In diesen beiden Zeilen wird das MySQL root Passwort definiert damit die Installation von MySQL nicht unterbrochen wird. Das liegt daran das die MySQL Server Installation User input benötigt:

	`sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'`

	`sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'`

2. MySQL Server sowie die Firewall werden in dieser Zeile installiert, das -y wird gebraucht um User input zu umgehen:

	`sudo apt-get install -y mysql-server ufw`

3. Mit dieser Zeile wird das mysql.cnf File angepasst welches im Ordner /etc/mysql/mysql.conf.d zu finden ist. Die Bind Adresse des Server wird von Localhost zu 0.0.0.0 geändert. By Default sind auf einen MySQL Server nur Verbindungen innerhalb des selben hosts zugelassen *Also nur Verbindungen vom Localhost*. Mit dem ändern der Bind Adresse werden Verbindungen ausserhalb des Localhosts zugelassen: 

	`sudo sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf`

4. Zuerst wird mit mysql -uroot -padmin der neu installierte MySQL Server geöffnet und danach zwei SQL Befehle ausgeführt. Es wird der root User so angepasst das man von jeder IP-Adresse mit diesem User auf den Server connecten kann. Grundsätzlich ist dies keine allzu schlaue Idee. Mit der Firewall jedoch wird dieser Sicherheitslücke jedoch wieder behoben:

	`mysql -uroot -padmin <<%EOF%
		GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'admin';
		FLUSH PRIVILEGES;
	%EOF%`

5. Nach dem ändern der MySQL User konfiguration muss der service neugestartet damit die Änderungen übernommen werden. Dies wird mit dieser Zeile gemacht:

	`sudo service mysql restart`

6. Ganz zum Schluss des config Shell Files wird die Firewall konfigueriert. Die Firewall blockt by Default allen incoming und outbound traffic. Deshalb habe ich für den Host der Virtuellen Maschine den Port 22 und 3306 geöffnet damit sich dieser zum einen via SSH auf die Virtuelle Maschine verbinden kann und zum anderen via MySQL Workbench den Datenbank Server öffnen kann. Da ich die Ports nur für den Host der Virtuellen Maschine geöffnet habe, ist das Security Problem von vorhin bei Punkt 4 wieder gelöst da nur eine Person, nämlich der Host dden Datenbank Server öffnen kann:

	`sudo ufw allow from 192.168.55.1 to any port 22`

	`sudo ufw allow from 192.168.55.1 to any port 3306`

	`sudo ufw -f enable`
