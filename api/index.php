<?php

require 'libraries/Slim/Slim.php';
\Slim\Slim::registerAutoloader();


$app = new \Slim\Slim(array(
	'debug' => true
));


$app->get('/', function () {
	echo file_get_contents('/opt/minion/api/index.html');
});
$app->get('/api(/)', function () {
	echo file_get_contents('/opt/minion/api/api.html');
});
$app->get('/contact(/)', function () {
	echo file_get_contents('/opt/minion/api/contact.html');
});

$app->get('/publicip(/)(/:format)', function($format = 'html') use($app) {
	$response['ipaddress'] = "Unknown";
	$response['timestamp'] = null;

	if (is_file('/opt/minion/log/publicip.log')) {
		$response['ipaddress'] = trim(file_get_contents('/opt/minion/log/publicip.log'));
		$response['timestamp'] = date ("Y-m-d H:i:s", filemtime('/opt/minion/log/publicip.log'));
	}

	$format = strtolower($format);
	if ($format == "json") {
		$app->response->headers->set('Content Type', 'application/json');
		echo json_encode($response);
	} else if ($format == "xml") {
		$app->response->headers->set('Content Type', 'text/xml');

		echo '<?xml version="1.0" encoding="UTF-8"?>';
		//echo '<publicips>';
		echo '	<publicip>';
		echo '		<ipaddress>'.$response['status'].'</ipaddress>';
		echo '		<timestamp>'.$response['timestamp'].'</timestamp>';
		echo '	</publicip>';
		//echo '</publicips>';
	} else {
		print_r($response);
	}
});


$app->get('/speedtest(/)(/:format)', function($format = 'html') use($app) {
	$response['status'] = "Unknown";
	$response['download'] = null;
	$response['upload'] = null;
	$response['timestamp'] = null;

	if (is_file('/opt/minion/log/speedtest.log')) {
		$line = '';
		$f = fopen('/opt/minion/log/speedtest.log', 'r');
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

		echo '<?xml version="1.0" encoding="UTF-8"?>';
		echo '<speedtests>';
		echo '	<speedtest>';
		echo '		<status>'.$response['status'].'</status>';
		echo '		<download>'.$response['download'].'</download>';
		echo '		<upload>'.$response['upload'].'</upload>';
		echo '		<timestamp>'.$response['timestamp'].'</timestamp>';
		echo '	</speedtest>';
		echo '</speedtests>';
	} else {
		print_r($response);
	}
});



$app->run();