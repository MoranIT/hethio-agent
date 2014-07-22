<?php

require 'vendor/autoload.php';

$app = new \Slim\Slim();

$app->get('/', function () {
	echo "Minion v1.0";
});

$app->get('/hello/:name', function ($name) {
	echo "Hello, $name";
});



$app->run();