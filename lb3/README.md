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
Mit dem docker-compose.yaml File werden beide Container erstellt. Gleich unten sind die einzelnen Commands des docker-compose.yaml Files beschrieben. 

1. Die Version des docker-compose Files wird definiert. Das Tag services steht immer zu beginn eines docker-compose Files.

    `version: '2.2'`
    
    `services:`

2. Datenbank Server Container wird mit dieser Zeile definiert. 

    `postgresql:`

3. Das Image des Datenbank Server wird definiert in diesem Fall heisst das Image bitnami/postgresql:11

    `image: 'bitnami/postgresql:11'`

4. In diesen Zeilen wird die Security der VM und im betracht genommen. Es wird eine Memory Limite definiert von 1024 MB. Eine Memory Reservation von 256 MB wird auch definiert so das dieser Container immer mindestens soviel Memory zur Verfügung hat. Zudem wird definiert das dieser Container 0.5 cpus verwenden kann also 50% der Cpu Kapazität. 

    `mem_limit: 1024M`
    
    `mem_reservation: 256M`
    
    `cpus: 0.5`

5. Die Umgebungsvariablen welche Verwendet werden, werden hier definiert. Es werden einfach Datenbank Name definiert sowie der Username des Datenbank Users. Diese Umgebungsvariablen wird der Redmine Container verwenden für das erstellen / einloggen in die Datenbank. 

    `environment:`
      
      `- ALLOW_EMPTY_PASSWORD=yes`
      
      `- POSTGRESQL_USERNAME=bn_redmine`
      
      `- POSTGRESQL_DATABASE=bitnami_redmine`

6. Docker Volume wird definiert, zeigt auf /bitnami/postgresql des Containers.

    `volumes:`
      
      `- 'postgresql_data:/bitnami/postgresql'`

7. Redmine Web Server Container wird in dieser Zeile definiert.

    `redmine:`

8. Image welches verwendet wird, wird definiert, im Falle des Web Servers heisst das Image bitnami/redmine:4

    `image: 'bitnami/redmine:4'`

9. In diesen Zeilen wird die Security der VM und im betracht genommen. Es wird eine Memory Limite definiert von 512 MB. Eine Memory Reservation von 128 MB wird auch definiert so das dieser Container immer mindestens soviel Memory zur Verfügung hat. Zudem wird definiert das dieser Container 0.5 cpus verwenden kann also 50% der Cpu Kapazität. Dies ist dasselbe wie beim Datenbank Container, es wurden einfach andere Werte verwendet. 

    `mem_limit: 512M`

    `mem_reservation: 128M`

    `cpus: 0.5`

10. Hier wird das Port Forwarding des Web Server Containers gemacht. Dieses Port Forwarding kann man auf dem Netzwerkplan auch schon sehen. Es wird einfach Port 3000 des Containers auf Port 80 der VM gemapped. 
    
    `ports:`

      `- '80:3000'`

11. Die Umgebungsvariablen welche verwendet werden sind hier definiert. Wie man sehen kann sind es die selben Werte wie vorhin bei den Datenbank Server Umgebungsvariablen. Der Web Server Container benötigt nämlich die Werte dieser Umgebungsvariablen um sich bei dem Datenbank Server Container einzuloggen und eine Datenbank zu erstellen. 

    `environment:`

      `- REDMINE_DB_POSTGRES=postgresql`

      `- REDMINE_DB_USERNAME=bn_redmine`

      `- REDMINE_DB_NAME=bitnami_redmine`

12. Docker Volume wird definiert und zeigt auf /bitnami des Containers

    `volumes:`

      `- 'redmine_data:/bitnami'`

13. In dieser Zeile wird definiert das der Redmine Container erst startet wenn der Postgresql Datenbank Server Container gestartet ist. Dies wird gemacht um Konflikten und Fehlermeldungen aus dem Weg zu gehen. 
    
    `depends_on:`

      `- postgresql`

14. Dies wird benötigt für die Docker Volumes, ohne diesen Driver angaben könnte das Docker Volume nicht erstellt werden / es würde eine Fehlermeldung beim starten der Container erscheinen. 

`volumes:`

  `postgresql_data:`

    `driver: local`

  `redmine_data:`

    `driver: local`

### 3.2 docker-compose.dev.yaml File
Das docker-compose.dev.yaml File wird für Testing Gründe verwendet. Mit Merged Docker-Compose Files wird zuerst das docker-compose.yaml File ausgeführt und danach das docker-compose.dev.yaml File. Mit dem docker-compose.dev.yaml File werden dann einfach alle Änderungen zum docker-compose.yaml File übernommen. In diesem Fall sind es andere Memory  und CPU Limiten und ein anderes Image. 

1. Zuerst werden wie vorhin im docker-compose.yaml File die Version definiert sowie der Service Tag steht. 

    `version: '2.2'`

    `services:`

2. Wie vorhin beim docker-compose.yaml File wird der selbe Container Name verwendet. Es wird aber jedoch nicht das bitnami/postgresql:11 Image verwendet sondern das latest Image. Dazu sind andere Memory und CPU Limiten definiert. 
  
    `postgresql:`
    
    `image: 'bitnami/postgresql:latest'`

    `mem_limit: 512M`

    `mem_reservation: 128M`

    `cpus: 0.25`

3. Zum Schluss sind noch die selben Umgebungsvariablen definiert sowie das selbe Docker Volume
    
    `environment:`

      `- ALLOW_EMPTY_PASSWORD=yes`

      `- POSTGRESQL_USERNAME=bn_redmine`

      `- POSTGRESQL_DATABASE=bitnami_redmine`

    `volumes:`

      `- 'postgresql_data:/bitnami/postgresql'`


## 4 Benutzen der Umgebung


## 5 Testing


## 6 Gedanken zu Security


## 7 Quellenverzeichnis

