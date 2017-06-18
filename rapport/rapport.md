# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
Ce rapport contient un résumé des différentes configurations pour chaque étape ainsi que des instructions plus détaillées sur ce qui a été fait selon les différents webcast.

Il est à noter que le résultat de chaque étape est identique au contenu des webcasts. La branche *fb-personal-content* a été créé à partir du contenu de l'étape 5 et contient du contenu personnalisé afin de répondre aux divers critères d'originalité.

## Step 1
### Configuration finale
Le contenu de cette étape est disponible sur la branche *fb-apache-static*. Dans le dossier *docker-images/apache-php-images/* se trouve tout le nécessaire pour construire une image docker d'un serveur httpd (créé à partir d'une image docker php:7.0-apache) présentant du contenu HTTP statique (contenu situé dans le dossier *content/*). Le contenu utilisé dans cette branche correspond à celui utilisé dans le webcast. Il a été changé dans la branche *fb-personal-content* pour le template *Greyscale*.

Pour consulter le résultat de cette étape, il suffit de lancer le script *demo_step1.sh* et de se connecter à la bonne adresse IP au port 8080 (vraisemblablement celle de la docker-machine ou simplement localhost suivant l'installation docker utilisée).

### Step 1a
Dans cette première étape, nous avons construit une nouvelle image Docker à partir d’une image php:7.0 (qui contient un serveur httpd)

Nous avons ensuite construit une nouvelle image à partir de cette dernière afin de lui transmettre du contenu http récupéré depuis un fournisseur de site web de type « One Page Bootstrap ».

Une fois cette image construite, il suffit de lancer un container et de s’y connecter « directement » : on récupère l’adresse IP de la docker-machine et on se connecte à cette adresse au port 8888 depuis n’importe quel browser.


## Step 2
### Configuration finale
Le contenu de cette étape est disponible sur la branche *fb-express-dynamic*. Dans le dossier *docker-images/express-images/* se trouve tout le nécessaire pour construire une image Docker d'un serveur Node.js renvoyant du contenu généré dynamiquement à chaque connexion.

Dans cette branche, le contenu correspond à celui du webcast: une liste d'étudiants. Il a néanmoins été changé dans la branche *fb-personal-content* pour renvoyer le résultat d'un jet de dé à 100 faces.

Pour consulter le résultat de cette étape, il suffit de lancer le script *demo_step2.sh* et de se connecter à la bonne adresse IP au port 3000 (vraisemblablement celle de la docker-machine ou simplement localhost suivant l'installation docker utilisée).

Si l'image créée ne démarre pas correctement, lancer la commande *npm install* dans le dossier */docker-images/express-images/src/* peut aider.

### Step 2a
Introduction à comment faire une application Node.js utilisable depuis un container.
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
### Configuration finale
Le contenu de cette étape est disponible sur la branche *fb-apache-reverse-proxy*. Dans le dossier *docker-images/apache-reverse-proxy/* se trouve tout le nécessaire pour construire une image Docker d'un serveur serveur reverse-proxy permettant d'accéder:
* Au contenu statique à l'adresse : *http://demo.res.ch:8080/*
* Au contenu dynamique à l'adresse : *http://demo.res.ch:8080/api/students/*

Pour pouvoir accéder à ces sites, il faut lancer le script *demo_step3.sh* et ajouter la ligne suivante au fichier hosts:
```
*Adresse docker-machine* demo.res.ch
```

ATTENTION: Les adresses IP sont codées en dur dans les configurations du reverse-proxy, il est donc important de lancer les containers dans le bon ordre (celui du script).
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
Une fois les containers lancés, on peut récupérer leur adresse IP avec la commande suivante:
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
Notre reverse proxy est maintenant manuellement installé. Néanmoins, cette configuration sera perdue si le conteneur est arrêté, il convient donc de créer une image docker pour faire ceci automatiquement.

### Step 3c

Nous allons configurer notre Dockerfile comme suit, afin qu'il mette à chaque démarrage du conteneur ce que nous avons fait manuellement à l'étape 3b.
```
FROM php:5.6-apache

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

Le dossier */conf* contient les fichiers *000-default.conf* et *001-reverse-proxy.conf*. Voici le contenu de ces fichiers, semblables à quelques différences à l'étape 3b
```
<VirtualHost *:80>
</VirtualHost>
```
```
<VirtualHost *:80>
    ServerName demo.res.ch

    #ErrorLog ${APACHE_LOG_DIR}/error.log
    #CustomLog ${APACHE_LOG_DIR}/access_log combined

    ProxyPass "/api/students/" "http://172.17.0.3:3000"
    ProxyPassReverse "/api/students/" "http://172.17.0.3:3000"

    ProxyPass "/" "http://172.17.0.2:80"
    ProxyPassReverse "/" "http://172.17.0.2:80"
</VirtualHost>
```

On peut ensuite tester le tout en accédant depuis un navigateur à l'adresse *http://192.168.99.100:8080/* (l'adresse IP a été trouvée à l'aide de la commande *docker-machine inspect*). On peut constater une erreur de type *Forbidden* puisqu'on tombe sur la configuration du virtual host 000 qui ne nous laisse pas accéder à du contenu. Il aurait fallu spécifier l'entête *Host:* dans la requête HTTP, ce que nous allons faire ci-dessous.

On peut commencer par écrire cette requête nous-même (après nous être connecté au serveur):
```
telnet 192.168.99.100 8080

GET /api/students/ HTTP/1.0
Host: demo.res.ch

```
Cette requête correspond au virtualhost 001 et nous renvoie un Json avec des personnes générées aéatoirement, comme prévu. Si on met autre chose comme ressource à get, par exemple "/api/student", on recoit une 404 vu qu'on a êté redirigé par l'autre règle de la conf 001 (donc sur le serveur apache static) et que le serveur apache fournissant du contenu statique n'a pas de ressource "/api/students".

Pour que ca marche directement depuis le navigateur, il ajouter la ligne suivante au fichier *hosts*
```
192.168.99.100 demo.res.ch
```
On peut tester avec *ping demo.res.ch*. Si on accède depuis un navigateur à *demo.res.ch:8080*, on accède au serveur apache static et sa page bootstrap, tandis que si on accède à *demo.res.ch:8080/api/students/*, le navigateur nous affiche le fichier Json généré par le serveur express-dynamic.

## Step 4
### Configuration finale
Le contenu de cette étape est disponible sur la branche *fb-ajax-jquery*. Dans cette branche, on simplement modifier le contenu statique contenu dans */docker-images/apache-php-images/* afin que la page affichée effectue des requêtes AJAX vers le serveur renvoyant du contenu dynamique.

Pour tester cette étape, il suffit de lancer le script *demo_step4.sh*. On peut ensuite se connecter sur *demo.res.ch:8080* pour osberver le résultat.

Comme pour les étapes 1 et 2, une version personnalisé du contenu est disponible sur la branche *fb-personal-content*.

### Step 4a
On commence par installer vim sur toutes les images qu'on a créé jusqu'à maintenant. On fait ca en rajoutant les lignes suivantes à leur Dockerfile respectif:
```
RUN apt-get update && \
  apt-get install -y vim
```
Il faut ensuite ne pas oublier de rebuild les images et de les redémarrer dans le bon ordre étant donné que les adresses IP dans le reverse proxy sont codés en dur.

Remarques: il est possible qu'il faille refaire un npm install là où se trouve le fichier package.json des images pour que les images se build correctement (particulièrement si npm-modules manque)

Ensuite, il faut rajouter un script javascript dans le index.html de notre template Bootstrap pour qu'il aille charger du contenu généré aléatoirement sur l'image express_students.

Voici le code à rajouter dans index.html:
```html
<!-- Custom script -->
<script src="js/students.js"></script>
```
Et voici un exemple de script (TODO le modifier pour faire un truc original) :
```javascript
$(function() {
    console.log("coucou");

    function loadStudents(){
        $.getJSON( "/api/students/", function (students) {
            var msg = "Nobody";
            if ( students.length > 0 ) {
                msg = students[0].firstname + " " + students[0].lastname;
            }
            $(".skills").text(message);
        });
    };
    loadStudents();
    setInterval(loadStudents, 5000);
});
```
On peut ensuite lancer les 3 containers à la suite (ordre important car adresse IP codée en dur) et se connecter à demo.res.ch:8080 depuis un browser pour constater que ca marche.

## Step 5
### Configuration finale
Le contenu de cette étape est disponible sur la branche *fb-dynamic-configuration*. Dans cette branche, on a modifié la création de l'image du serveur reverse-proxy afin que lorsque le serveur se lance, il exécute en plus un fichier php qui va écrire lui-même le fichier de config du serveur. Etant donné que l'on passe en variable d'environnement les adresses IP statique et dynamique de nos containers, le script PHP va les utiliser pour configurer correctement le serveur. On a donc maintenant un moyen de configurer le reverse proxy à son lancement et non plus à la création de l'image.

Pour tester cette étape, il suffit de lancer le script *demo_step5.sh* et de lancer la dernière commande avec les bonnes adresses:
```
docker run -e STATIC_APP=172.17.0.x:80 -e DYNAMIC_APP=172.17.0.y:3000 --name apache_rp -p 8080:80 res/apache_rp
```

Le résultat est disponible sur *demo.res.ch:8080*

### Step 5a
On peut passer des variables au démarrage d'un container à l'aide de l'option *-e*.

L'image docker php5.6 lance un script apache2-foreground à son lancement. 
On va le copier et y ajouter de nouvelles fonctionnalités afin de récupérer les variables dynamiques que l'on a passé à notre machine.

Ces variables vont ensuite aider à produire à l'aide d'un peu de PHP le nouveau fichier de configuration *001-reverse-proxy.conf* avec les bonnes adresses. Voici le code PHP générant ce fichier de config:
```php
<?php
 $ip_adress_static = getenv('STATIC_APP');
 $ip_adress_dynamic = getenv('DYNAMIC_APP');
?>
<VirtualHost *:80>
    ServerName demo.res.ch

    ProxyPass '/api/students/' 'http://<?php print "$ip_adress_dynamic"?>/'
    ProxyPassReverse '/api/students/' 'http://<?php print "$ip_adress_dynamic"?>/'

    ProxyPass '/' 'http://<?php print "$ip_adress_static"?>/'
    ProxyPassReverse '/' 'http://<?php print "$ip_adress_static"?>/'
</VirtualHost>
```

## Fb-personal-content
Cette branche a été créé à partir du contenu l'étape 5. Elle contient simplement des modifications vis-à-vis du contenu afin de l'originaliser.

Ainsi, le contenu statique se base désormais sur le template *Greyscale* et sert à afficher le résultat d'un jet d'un dé 100 toutes les 2 secondes.

Pour tester cette étape, il suffit de lancer le script *demo_personalContent.sh* et de lancer la dernière commande avec les bonnes adresses:
```
docker run -e STATIC_APP=172.17.0.x:80 -e DYNAMIC_APP=172.17.0.y:3000 --name apache_rp -p 8080:80 res/apache_rp
```
Le résultat est disponible sur *demo.res.ch:8080*