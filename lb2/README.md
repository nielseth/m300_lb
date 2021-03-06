# M300 LB2 Dokumentation

![IaC Icon](https://www.datocms-assets.com/2885/1547758259-infrastructure-as-codesolution-2x.png?fit=max&fm=png&q=80)

## Inhaltsverzeichnis

  * [1 Einleitung](#1-einleitung)
  * [2 Grafische Übersicht (Netzwerkplan)](#2-grafische--bersicht--netzwerkplan-)
    + [2.1 Erklärung Netzwerkplan](#21-erkl-rung-netzwerkplan)
  * [3 Erklärung von Code](#3-erkl-rung-von-code)
    + [3.1 Vagrantfile](#31-vagrantfile)
    + [3.2 config Shell File](#32-config-shell-file)
  * [4 Benutzen der Umgebung](#4-benutzen-der-umgebung)
  * [5 Testing](#5-testing)
  * [6 Gedanken zu Security](#6-gedanken-zu-security)
  * [7 Quellenverzeichnis](#7-quellenverzeichnis)

## 1 Einleitung
In diesem Dokument wird die **LB2** des Moduls 300 beschrieben. Die Aufgabe war es mit Hilfe von Vagrant ein Infrastructure as Code Projekt machen, indem ein Service oder Serverdienst automatisiert wird. Ich habe mich dazu entschieden mit Vagrant eine Virtualbox VM aufzusetzen welche eine Datenbank enthält sowie Firewall. Mit MySQL Workbench soll dann vom Host aus darauf zugegriffen werden. In der Grafischen Übersicht also im Netzwerk Plan welcher Folgt sollte klar sein wie das Projekt aufgebaut ist. 

## 2 Grafische Übersicht (Netzwerkplan)

![Netzwerkplan LB2](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Netzwerkplan.png)

### 2.1 Erklärung Netzwerkplan
Der Host 192.168.55.1 ist des Gerät, von dem der Befehl Vagrant up ausgeführt wird. Wie man auf der Grafik sehen kann wird eine Vagrant Box mit der Ubuntu OS Version 18.04 aufgesetzt und mit der IP Adresse 192.168.55.200. Auf dieser VM ist die Datenbank und die Firewall, welche alle Verbindungen auf die VM blockt ausser, Verbindungen auf den Port 22 und 3306 vom Host. 

## 3 Erklärung von Code
### 3.1 Vagrantfile
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

7. Hier wird das Shell Script definiert, welches die Virtuelle Maschine verwendet. Das Shell Script hat den config.sh. In diesem Shell Script stehen Commands welche dann auf der Virtuellen Maschine ausgeführt werden: 

	`config.vm.provision "shell", path: "config.sh"`

8. DIe IP Adresse der Virtullen Maschine wird hinter ip: definiert. Private_network bedeuted das die IP-Adresse aus einem Privaten IP-Bereich ist: 

	`config.vm.network "private_network", ip: "192.168.55.200"`

### 3.2 config Shell File
Das config Shell File wird im Vagrantfile referenziert und dieses File enthaltet Commands welche auf der Virtuellen Maschine ausgeführt werden. Gleich unten werden die einzelnen Commands welche im config Shell File vorhanden sind beschrieben. 

1. In diesen beiden Zeilen wird das MySQL root Passwort definiert damit die Installation von MySQL nicht unterbrochen wird. Das liegt daran das die MySQL Server Installation User Input benötigt:

	`sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'`

	`sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'`

2. MySQL Server sowie die Firewall werden in dieser Zeile installiert, das -y wird gebraucht, um User input zu umgehen:

	`sudo apt-get install -y mysql-server ufw`

3. Mit dieser Zeile wird das mysql.cnf File angepasst welches im Ordner /etc/mysql/mysql.conf.d zu finden ist. Die Bind Adresse des Server wird von Localhost zu 0.0.0.0 geändert. By Default sind auf einen MySQL Server nur Verbindungen innerhalb desselben hosts zugelassen *Also nur Verbindungen vom Localhost*. Mit dem Ändern der Bind Adresse werden Verbindungen ausserhalb des Localhosts zugelassen: 

	`sudo sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf`

4. Zuerst wird mit mysql -uroot -padmin der neu installierte MySQL Server geöffnet und danach zwei SQL Befehle ausgeführt. Es wird der root User so angepasst das man von jeder IP-Adresse mit diesem User auf den Server connecten kann. Grundsätzlich ist dies keine allzu schlaue Idee. Mit der Firewall jedoch wird dieser Sicherheitslücke jedoch wieder behoben:

	`mysql -uroot -padmin <<%EOF%
		GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'admin';
		FLUSH PRIVILEGES;
	%EOF%`

5. Nach dem Ändern der MySQL User konfiguration muss der service neugestartet damit die Änderungen übernommen werden. Dies wird mit dieser Zeile gemacht:

	`sudo service mysql restart`

6. Ganz zum Schluss des config Shell Files wird die Firewall konfigueriert. Die Firewall blockt by Default allen incoming traffic. Deshalb habe ich für den Host der Virtuellen Maschine den Port 22 und 3306 geöffnet damit sich dieser zum einen via SSH auf die Virtuelle Maschine verbinden kann und zum anderen via MySQL Workbench den Datenbank Server öffnen kann. Da ich die Ports nur für den Host der Virtuellen Maschine geöffnet habe, ist das Security Problem von vorhin bei Punkt 4 wieder gelöst da nur eine Person, nämlich der Host dden Datenbank Server öffnen kann:

	`sudo ufw allow from 192.168.55.1 to any port 22`

	`sudo ufw allow from 192.168.55.1 to any port 3306`

	`sudo ufw -f enable`

## 4 Benutzen der Umgebung
Die Benutzung dieses Infrastructure as Code ist relativ simple. Ich werde in diesem Kapitel zusammenfassen was es braucht, um diese Umgebung zu verwenden. 

Um diese Umgebung zu starten muss man Sie zuerst mit Hilfe der Git Bash aus dem GitHub clonen. Dazu muss man einfach Git auf dem Rechner installieren. Nach dem clonen der Umgebung sollte man via der Git Bash Console im Verzeichnis ...m300_lb/lb2 den Vagrant up Befehl eingeben so dass die Vagrant Box anhand des Vagrantfiles sowie des config Shell Scripts gestartet wird. 

Da dies ein Service ist muss nach dem Vagrant up Befehl nichts mehr an der Virtuellen Maschine verändert werden. Um nun den Datenbank Server der Virtuellen Maschine zu erreichen muss man via der MySQL Workbench eine neue Verbindung erstellen, MySQL Workbench kann man genau wie Git einfach im Internet installieren. Bei der neuen Verbindung, welche man erstellen sollte um den Datenbank Server zu erreichen sollten die Felder wie folgt aussehen. 

![Verbindung mit Datenbank Server](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Felder-f%C3%BCr-Connection.png)

Bei Password unter Store in Vault kann man dann das Passwort des root Users eingeben welches wir im config shell Script definiert haben. In diesem Fall heisst unser Passwort "admin". 

Nachdem man dies so gemacht hat kann man unten auf OK klicken und es sollte ein neues Feld unter MySQL Connections erscheinen. Man kann nun auf dieses Feld klicken und es sollte ein neues Fenster erscheinen. Wenn dies der Fall ist wurde erfolgreich eine Verbindung zum Datenbank Server aufgebaut. 

## 5 Testing
In diesem Kapitel wird gezeigt das diese Umgebung funktionstüchtig ist. Diese Umgebung wird mit dem Vagrant up Befehl erstellt. Dieser Befehl ist erfolgreich und erzeugt keine Fehlermeldung da nach dem ausführen dieses Befehls in der Git Bash der Befehl `echo $?` ausgeführt wurde welcher die Antwort 0 zurückgab was bedeutet das keine Fehlermeldung im vorherigen Befehl war. 

![Vagrant up check](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Testing-Vagrant-up-check.png)

Um dann zu testen ob der Datenbank Server erfolgreich aufgesetzt wurde, sollte man in der MySQL Workbench eine, wie im Kapitel 4 erklärte neue Verbindung machen. Nach dem man die Felder wie im Bild ausgefüllt hat kann man sehen das unten rechts in diesem Feld die Option Test Connection vorhanden ist. Nach dem man diese Option anklickt sollte ein solches Feld erscheinen, wie man auf dem Bild unten sehen kann. Dies bedeutet dass die Verbindung mit dem Datenbank Server erfolgreich war und das soweit alles funktioniert. 

![db server check](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Testing-db-server-check.png)

Um nun wirklich noch sicher zu gehen ob man nun überhaupt auf dem Datenbank Server arbeiten kann, sollte man einfach die neue Connection öffnen und danach einen SQL Befehl abgeben, in diesem Fall kann man mit dem Befehl `CREATE database Testing;` einfach eine neue Datenbank erstellen. Nach dem Ausführen dieses Befehls in der MySQL Workbench kann man die VM überprüfen und nachsehen ob die Datenbank erstellt wurde. Einloggen kann man sich standartmässig mit Username: vagrant, Passwort: vagrant. 

Wie man auf dem Bild sehen kann wurde die Datenbank erstellt. 

![db create check](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Testing-db-create-vm-check.png)

## 6 Gedanken zu Security
Wie vorhin im Kapitel drei schon erwähnt habe ich mir einige Gedanken zur Security gemacht. Der Datenbank Server enthält einen root User, welchen ich bearbeitet habe so das man von jeder IP Adresse darauf zugreifen kann. Da dies aus Security Sicht keine sehr gute Idee ist habe ich mir Gedanken gemacht, wie ich diese Security Lücke beheben kann. Mir ist dann in den Sinn gekommen das ich einfach eine Firewall aufsetzen muss auf der Virtuellen Maschine welchen allen Incoming Traffic blockiert ausser für den Host der Virtuellen Maschine. Also habe ich dies mit ufw aufgesetzt und definiert das nur vom Host aus eine Verbindung mit dem Port 22 und 3306 gemacht werden kann. Sonst ist jede Art von Verbindung auf die Virtuelle Maschine nicht möglich. Man hätte das Ganze sicher auch einfacher lösen können, aber ich habe in der Zeit keine andere Variante gefunden / nicht anderes hat für mich funktioniert. 

## 7 Quellenverzeichnis

Titelblatt:

https://www.datocms-assets.com/2885/1547758259-infrastructure-as-codesolution-2x.png?fit=max&fm=png&q=80

Bespiele von Vagrantfiles sowie config shell Script:

https://github.com/mc-b/M300/tree/master/vagrant/web

https://github.com/mc-b/M300/tree/master/vagrant/mmdb

Überprüfen eines Commands in Linux:

https://linuxhint.com/check_command_succeeded_bash/

Markdown Guide:

https://www.markdownguide.org/basic-syntax/

Markdown Table of Contents:

https://ecotrust-canada.github.io/markdown-toc/

