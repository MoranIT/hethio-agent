<?php

require 'libraries/Slim/Slim.php';
\Slim\Slim::registerAutoloader();


$app = new \Slim\Slim(array(
	'debug' => true
));


function OutputResponse($response, $singular, $multiple = null, $format = 'html') {
	$format = strtolower($format);
	var isArray = (is_array($response));
	if ($isArray) {
		$responses = $response;
	} else { $responses = array($response); }

}








$app->get('/', function () {
	echo file_get_contents('/opt/minion/api/index.html');
});
$app->get('/api(/)', function () {
	echo file_get_contents('/opt/minion/api/api.html');
});
$app->get('/contact(/)', function () {
	echo file_get_contents('/opt/minion/api/contact.html');
});



//One is using this command: cat /sys/class/thermal/thermal_zone0/temp. 
//This will return the temperature in millicentigrade, with quick 
//conversions to centigrade being something like (in your language of choice) 
//value / 1000.0 and to Fahrenheit value / 1000.0 * 9/5 + 32.
$app->get('/temp(/)(/:format)', function($format = 'html') use($app) {
	$response['millicentigrade'] = null;
	$response['centigrade'] = null;
	$response['fahrenheit'] = null;
	$response['timestamp'] = time();

	if (is_file('/sys/class/thermal/thermal_zone0/temp')) {
		$response['millicentigrade'] = trim(file_get_contents('/sys/class/thermal/thermal_zone0/temp'));
		$response['centigrade'] = $response['millicentigrade'] / 1000;
		$response['fahrenheit'] = $response['centigrade'] * 9/5 + 32;
		$response['timestamp'] = date ("Y-m-d H:i:s", filemtime('/sys/class/thermal/thermal_zone0/temp'));
	}
	OutputResponse($response, "temp", "temps", $format);
});




$app->get('/publicip(/)(/:format)', function($format = 'html') use($app) {
	$response['ipaddress'] = "Unknown";
	$response['timestamp'] = null;

	if (is_file('/opt/minion/log/publicip.log')) {
		$response['ipaddress'] = trim(file_get_contents('/opt/minion/log/publicip.log'));
		$response['timestamp'] = date ("Y-m-d H:i:s", filemtime('/opt/minion/log/publicip.log'));
	}
	OutputResponse($response, "publicip", "publicips", $format);
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
	OutputResponse($response, "speedtest", "speedtests", $format);
});



$app->run();