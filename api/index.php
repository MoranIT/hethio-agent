<?php

require 'libraries/Slim/Slim.php';
\Slim\Slim::registerAutoloader();


$app = new \Slim\Slim(array(
	'debug' => true
));


function OutputResponse($response, $singular, $multiple = null, $format = 'html') {
	global $app;

	$format = strtolower($format);
	
	$isArray = true;  //assume array of arrays/objects
	$responses = $response;
	while (list($key, $val) = each($response)) { 
		if (!is_numeric($key)) {  //objects must be associative arrays
			$isArray = false;  //if any of the keys are not numeric, then it is an object
			$responses = array($response);
			break;
		}
	}

	if ($format == "json") {
		$app->response->headers->set('Content Type', 'application/json');
		echo json_encode($response);
	} else if ($format == "xml") {
		
		$app->response->headers->set('Content Type', 'text/xml');
		echo '<?xml version="1.0" encoding="UTF-8"?>';
		if ($isArray && !is_null($multiple)) { echo "<".$multiple.">"; }	
		foreach($responses as $response) {
			echo "<".$singular.">\n";
			while (list($key, $val) = each($response)) { echo "<$key>$val</$key>\n"; }
			echo "</".$singular.">\n";
		}
		if ($isArray && !is_null($multiple)) { echo "</".$multiple.">\n"; }
		
	} else {
		if (is_null($multiple)) {
			echo "<h1>".$singular."</h1>\n";
		} else {
			echo "<h1>".$multiple."</h1>\n";
		}

		echo "<table>\n";

		echo "<thead><tr>\n";
		if ($isArray) { $firstitem = $responses[0]; } else { $firstitem = $response; }
		while(list($key, $val) = each($firstitem)) {
			echo "<th>".$key."</th>\n";
		}
		echo "</tr></thead>\n";

		echo "<tbody>\n";
		foreach($responses as $response) {
			echo "<tr>\n";
			while (list($key, $val) = each($response)) { 
				//echo "<td>".$key."</td>\n";
				echo "<td>".$val."</td>\n"; 
			}
			echo "</tr>\n";
		}
		echo "</tbody>\n";

		echo "</table>\n";
	}

}

function GetLastLine($file) {
	$line = null;
	if (is_file($file)) {
		$line = '';
		$f = fopen($file, 'r');
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
	}
	return $line;
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



$app->get('/temp(/)(/:format)', function($format = 'html') {
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


$app->get('/publicip(/)(/:format)', function($format = 'html') {
	$response['ipaddress'] = "Unknown";
	$response['timestamp'] = null;

	$line = GetLastLine('/opt/minion/log/publicip.log');
	if (!is_null($line)) {
		$l = explode('|',$line); //publicip|timestamp
		$response['ipaddress'] = $l[0];
		$response['timestamp'] = $l[1];
	}
	OutputResponse($response, "publicip", "publicips", $format);
});


$app->get('/speedtest(/)(/:format)', function($format = 'html') {
	$response['download'] = null;
	$response['upload'] = null;
	$response['timestamp'] = null;

	$line = GetLastLine('/opt/minion/log/speedtest.log');
	if (!is_null($line)) {
		$l = explode('|',$line); //download|upload|timestamp
		$response['download'] = $l[0];
		$response['upload'] = $l[1];
		$response['timestamp'] = $l[2];
	}
	OutputResponse($response, "speedtest", "speedtests", $format);
});



$app->run();