<?php

require 'vendor/autoload.php';

$app = new \Slim\Slim();


$app->get('/', function () {
	echo "Minion v1.0";
});

$app->get('/hello/:name/:format', function ($name, $format = "html") use($app) {
	echo "Hello, $name";
});


$app->get('/speedtest(/)(/:format)', function($format = 'html') use($app) {
	$response['status'] = "Unknown";
	$response['download'] = null;
	$response['upload'] = null;
	$response['timestamp'] = null;

	if (is_file('/var/log/speedtest.log')) {
		$line = '';
		$f = fopen('/var/log/speedtest.log', 'r');
		$cursor = -1;
		fseek($f, $cursor, SEEK_END);
		$char = fgetc($f);
		while ($char === "\n" || $char === "\r") {
		    fseek($f, $cursor--, SEEK_END);
		    $char = fgetc($f);
		}
		while ($char !== false && $char !== "\n" && $char !== "\r") {
		    $line = $char . $line;
		    fseek($f, $cursor--, SEEK_END);
		    $char = fgetc($f);
		}

		$l = explode('|',$line); //download|upload|test-timestamp

		$response['status'] = "Successful";
		$response['download'] = $l[0];
		$response['upload'] = $l[1];
		$response['timestamp'] = $l[2];
	}

	$format = strtolower($format);
	if ($format == "json") {
		$app->response->headers->set('Content Type', 'application/json');
		echo json_encode($response);
	} else if ($format == "xml") {
		$app->response->headers->set('Content Type', 'text/xml');
		return $app->render('speedtest.xml', $response);
	} else {
		print_r($response);
	}
});



$app->run();