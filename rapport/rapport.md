# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra

## Step 1
TODO

## Step 2
### Step 2a
TODO
### Step 2b
* Introduction à comment faire un serveur HTTP en node avec les classes de bases sur https://nodejs.org/en/docs/guides/anatomy-of-an-http-transaction/ 

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

* Installation de express (à faire dans /express-image/src/)
```
npm install --save express
```

* Code de l'application de test express acceptant des connexions sur le port 3000
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

* Poursuite de l'exemple afin de générer aléatoirement des étudiants avec Chance
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