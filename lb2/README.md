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

### config shell File