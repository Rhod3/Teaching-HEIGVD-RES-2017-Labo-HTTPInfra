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