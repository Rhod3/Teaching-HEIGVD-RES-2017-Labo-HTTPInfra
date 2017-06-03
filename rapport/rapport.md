# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra

## Step 1
TODO

## Step 2
### Step 2a
TODO
### Step 2b
Introduction à comment faire un serveur HTTP en node avec les classes de bases sur https://nodejs.org/en/docs/guides/anatomy-of-an-http-transaction/ 

```javascript
var http = require('http');

http.createServer(function(request, response) {
  var headers = request.headers;
  var method = request.method;
  var url = request.url;
  var body = [];
  request.on('error', function(err) {
    console.error(err);
  }).on('data', function(chunk) {
    body.push(chunk);
  }).on('end', function() {
    body = Buffer.concat(body).toString();
    // BEGINNING OF NEW STUFF

    response.on('error', function(err) {
      console.error(err);
    });

    response.statusCode = 200;
    response.setHeader('Content-Type', 'application/json');
    // Note: the 2 lines above could be replaced with this next one:
    // response.writeHead(200, {'Content-Type': 'application/json'})

    var responseBody = {
      headers: headers,
      method: method,
      url: url,
      body: body
    };

    response.write(JSON.stringify(responseBody));
    response.end();
    // Note: the 2 lines above could be replaced with this next one:
    // response.end(JSON.stringify(responseBody))

    // END OF NEW STUFF
  });
}).listen(8080);
```

Installation de express (à faire dans /express-image/src/)
```
npm install --save express
```

Code de l'application de test express acceptant des connexions sur le port 3000
```javascript
var Chance = require('chance');
var chance = new Chance();

var express = require("express");
var app = express();

app.get('/test', function(req, res){
    res.send("Hello RES - accessing /test");
});

app.get('/', function(req, res){
    res.send("Hello RES");
});

app.listen(3000, function () {
    console.log('Accepting http request on port 3000!');
});
```

Poursuite de l'exemple afin de générer aléatoirement des étudiants avec Chance
```javascript
var Chance = require('chance');
var chance = new Chance();

var express = require("express");
var app = express();

app.get('/test', function(req, res){
    res.send("Hello RES - accessing /test");
});

app.get('/', function(req, res){
    res.send(generateStudents());
});

app.listen(3000, function () {
    console.log('Accepting http request on port 3000!');
});


function generateStudents() {
    var numberOfStudents = chance.integer({
        min: 0,
        max: 10
    });
    console.log(numberOfStudents);
    var students = [];
    for (var i = 0; i < numberOfStudents; i++) {
        var gender = chance.gender();
        var birthYear = chance.year({
            min: 1986,
            max: 1996
        });
        students.push({
            firstname: chance.first({
                gender: gender
            }),
            lastName: chance.last(),
            gender: gender,
            birthday : chance.birthday({
                year: birthYear
            })
        });
    };
    console.log(students);
    return students;
}
```

Reconstruction de l'image avec cette nouvelle app
```
docker build -t res/express_students .
```
Une fois l'image construite et lancée avec la commande
```
docker run -p 3000:3000 res/express_students
```
On peut accéder à l'app simplement avec:
```
localhost:3000
```
Si on a installé Docker For Windows et pas DockerToolBox, sinon faut trouver l'adresse à laquelle faut accéder avec un docker inspect qui va bien.

Tuto Postman:
 * Exemple de GET sur l'app
 * Ajout d'un environnement pour définir facilement à qui on s'adresse
 * Faire des exemples de requêtes qu'on peut mettre sur git et partager


## Step 3
### Step 3a
Normalement, quand on fait une requête HTTP, on charge toute la page et on l'affiche. Si du code Javascript s'exécute, il peut arriver que du JS fasse des requête HTTP asynchrone vers d'autres ressources, comme avec une interface graphique faite en HTML/JS. Ces requêtes asynchrones sont des requêtes Ajax. On a besoin d'un reverse proxy pour faire ces requêtes (en particulier pour "contrer" la same-origin policy).

Same-origin policy
> In computing, the same-origin policy is an important concept in the web application security model. Under the policy, a web browser permits scripts contained in a first web page to access data in a second web page, but only if both web pages have the same origin. An origin is defined as a combination of URI scheme, hostname, and port number. This policy prevents a malicious script on one page from obtaining access to sensitive data on another web page through that page's Document Object Model.

Reverse proxy c'est un point d'entrée unique vers plusieurs ressources, ce qui permet de contourner la same-origin policy.

### Step 3b
On veut récupérer les adresses IP des containers qu'on lance. On va donc lancer nos 2 containers en leur donnant un nom
```
docker run -d --name apache_static res/apache
docker run -d --name express_dynamic res/express_students
```
Une les containers lancés, on peut récupérer leur adresse IP avec la commande suivante:
```
docker inspect apache_static | grep -i ipaddress
docker inspect express_dynamic | grep -i ipaddress
```
Dans notre cas, les adresses trouvées sont 172.17.0.2 et 172.17.0.3.

On peut ensuite se connecter à la docker-machine et vérifier que nos 2 containers sont bien entrain de tourner (ci-dessous, les comandes pour le premier container).
```
docker-machine ssh
telnet 172.17.0.2
GET / HTTP/1.0
```

Une fois les 2 machines lancées, on peut lancer le server php:5.6-apache afin de le configurer pour qu'il fonctionne en tant que reverse proxy.

On commence par le lancer:
```
docker run -it -p 8080:80 php:5.6-apache /bin/bash
```
On peut ensuite se rendre dans le dossier */etc/apache2/* pour accéder aux différents fichiers de configuration de apache.

Dans le dossier */site-available* on trouve le fichier 000-dafault.conf, qui correspond au virtual-host de base.

On fait une copie de ce fichier ce config, c'est ce qui va nous servir de base pour créer celui du reverse proxy.
```
cp 000-default.conf 001-reverse-proxy.conf
```

On modifie ensuite ce fichier pour y mettre notre config
```
<VirtualHost *:80>

        ServerName demo.res.ch

        ServerAdmin webmaster@localhost

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        ProxyPass "/api/students/" "http://172.17.0.3:3000/"
        ProxyPassReverse "/api/students/" "http://172.17.0.3:3000/"

        ProxyPass "/" "http:172.17.0.2:80/"
        ProxyPassReverse "/" "http:172.17.0.2:80/"

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

Il faut ensuite activer les modules *proxy* et *proxy_http*. Une fois ces modules activés, on peut reload le service apache avec la commande suivante:
```
service apache2 reload
```
Notre reverse proxy est maintenant manuellement installé. Néamoins, cette configuration sera perdu si le conteneur est arrêté, il convient donc de créer une image docker pour faire ceci automatiquement.

### Step 3c
