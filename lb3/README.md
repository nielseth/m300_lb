# M300 LB3 Dokumentation

## Inhaltsverzeichnis


## 1 Einleitung
In diesem Dokument wird die **LB3** des Moduls 300 beschrieben. Die Aufgabe war es mit Hilfe von Docker und Docker-Compose ein Projekt zu machen, indem ein Service oder Serverdienst automatisiert wird. Ich habe mich dazu entschieden das Projektmanagement Tool Redmine mit Hilfe von Docker aufzusetzen. Es werden mit Hilfe eines docker-compose.yaml File zwei Container erstellt, ein Web Server und ein Datenbank Server. In der Grafischen Übersicht sollte gut aufgezeigt sein in welcher Umgebung das Ganze läuft.

## 2 Grafische Übersicht (Netzwerkplan)
![Netzwerkplan LB3](https://github.com/nielseth/m300_lb/blob/main/lb3/Images/Netzwerkplan.png)


### 2.1 Erklärung Netzwerkplan
Auf meinem Laptop in dieser Grafik auch Host gennant läuft eine Vagrant VM mit der Ubuntu Version 16.04. In dieser VM laufen die beiden Container. Zum einen der Postgresql Datenbank Server und zum anderen der Web Server für Redmine. Dieser Web Server Container hat ein Port Forwarding von Port 3000 auf den Port 80 der Vagrant VM. Die Vagrant VM hat ein Port Forwarding von Port 80 auf den Host Port 8080. Wenn also nun der Web Server in der Vagrant VM im auf dem Container läuft so kann man sich via localhost:8080 auf den Web Server verbinden. 

## 3 Erklärung von Code

### 3.1 docker-compose.yaml File

### 3.2 dockerr-compose.dev.yaml File

## 4 Benutzen der Umgebung


## 5 Testing


## 6 Gedanken zu Security


## 7 Quellenverzeichnis

