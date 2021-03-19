# M300 LB2 Dokumentation

## Inhaltsverzeichnis

## Einleitung
In diesem Dokument wird die **LB2** des Moduls 300 beschrieben. Die Aufgabe war es mit Hilfe von Vagrant ein Infrastructure as Code Projekt machen indem ein Service oder Serverdienst automatisiert wird. Ich habe mich dazu entschieden mit Vagrant eine Virtualbox VM aufzusetzen welche eine Datenbank enthält sowie Firewall. Mit MySQL Workbench soll dann vom Host aus darauf zugegriffen werden. In der Grafischen Übersicht also im Netzwerk Plan welcher Folgt sollte klar sein wie das Projekt aufgebaut ist. 

## Grafische Übersicht

![Netzwerkplan LB2](https://github.com/nielseth/m300_lb/blob/main/lb2/images/Netzwerkplan.png)

## Erklärung von Code
### Vagrantfile
Mit dem Vagrantfile wird die Vagrant Box erstellt. Gleich unten sind die einzelnen Commands beschrieben im Vagrantfile

1. Config des Virtuellen Maschine wird definiert: `Vagrant.configure("2") do |config|`

2. Ubuntu 18.04 wird als OS der Virtuellen Maschine definiert: 
`config.vm.box = "ubuntu/bionic64"`

3. Der Hostname der Virtuellen Maschine wird definiert: 
`config.vm.hostname = "m300lb2"`

4. VirtualBox wird als Provider der Virtuellen Maschine definiert. Dies bedeuted das die Virtuelle Maschine auf VirtualBox läuft: 
`config.vm.provider "virtualbox" do |vb|`

5. Der RAM der Virtuellen Maschine wird mit dieser Zeile definiert: 
`vb.memory = "2048"`

6. Der Name der Virtuellen Maschine in VirtualBox selber wird hier definiert: `vb.name = "m300lb2"`
*Der Name ist nicht dasselbe wie der vorher definierte Hostname*

7. Hier wird das Shell Script definiert welches die Virtuelle Maschine verwendet. Das Shell Script hat den config.sh. In diesem Shell Script stehen Commands welche dann auf der Virtuellen Maschine ausgeführt werden: 
`config.vm.provision "shell", path: "config.sh"`

8. DIe IP Adresse der Virtullen Maschine wird hinter ip: definiert. Private_network bedeuted das die IP-Adresse aus einem Privaten IP-Bereich ist. 
`config.vm.network "private_network", ip: "192.168.55.200"`

### config shell File