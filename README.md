# Docker Apache PHP

Apache - 2.4.17</br>
PHP - 5.6.14<br/>
MySQL - 5.6.27

## To Build

``` bash
$ docker build -t docker-apache-php .
```

### To Run

Use [docker volumes](http://docs.docker.io/use/working_with_volumes/) to expose
your web content to the apache web server.

``` bash
# run docker apache php as deamon with expose your web content to the apache web server
$ CONTAINER=$(docker run -p 80 -p 3306 -v /var/www/html:/var/www/html -d docker-apache-php)

# get the http port
$ docker port $CONTAINER 80
0.0.0.0:49206
```

### To access the database
``` bash
# get the mysql port
$ docker port $CONTAINER 3306
0.0.0.0:49205

# get [dockerhost] IP reading 'inet addr' value
$ ifconfig docker0 | grep 'inet addr'
          inet addr:172.17.42.1  Bcast:0.0.0.0  Mask:255.255.0.0

$ mysql -h172.17.42.1 -uroot -P 49205
```
