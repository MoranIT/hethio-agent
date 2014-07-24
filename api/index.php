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
	reset($responses);

	if ($format == "json") {
		$app->response->headers->set('Content Type', 'application/json');
		echo json_encode($response);
	} else if ($format == "xml") {
		
		$app->response->headers->set('Content Type', 'text/xml');
		echo '<?xml version="1.0" encoding="UTF-8"?>';
		if ($isArray && !is_null($multiple)) { echo "<".$multiple.">"; }	
		foreach($responses as $response) {
			reset($response);
			echo "<".$singular.">\n";
			while (list($key, $val) = each($response)) { echo "<$key>$val</$key>\n"; }
			echo "</".$singular.">\n";
		}
		if ($isArray && !is_null($multiple)) { echo "</".$multiple.">\n"; }
		
	} else {
		if ($isArray && !is_null($multiple)) {
			echo "<h1>".$multiple."</h1>\n";
		} else {
			echo "<h1>".$singular."</h1>\n";
		}

		echo "<table>\n";

		reset($responses[0]);
		echo "<thead><tr>\n";
		while(list($key, $val) = each($responses[0])) {
			echo "<th>".$key."</th>\n";
		}
		echo "</tr></thead>\n";

		echo "<tbody>\n";
		foreach($responses as $response) {
			reset($response);
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

function GetLastLines($file, $lines_count) {
	$result = array();
	if (is_file($file)) {
		$lines = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
		if (count($lines) < $lines_count) { $lines_count = count($lines); }
		for ($i = count($lines)-($lines_count + 1); $i < count($lines); $i++) {
		  array_push($result, $lines[$i]);
		}
	}
	return $result;
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
		if (strpos($line, '|') !== FALSE) {
			$l = explode('|',$line); //publicip|timestamp
			$response['ipaddress'] = $l[0];
			$response['timestamp'] = $l[1];
		} else {
			$response['ipaddress'] = $line;
			$response['timestamp'] = date ("Y-m-d H:i:s", time());
		}
	} else {  //logs could have just been rotated
		$line = GetLastLine('/opt/minion/log/publicip.1.log');
		if (!is_null($line)) {
			if (strpos($line, '|') !== FALSE) {
				$l = explode('|',$line); //publicip|timestamp
				$response['ipaddress'] = $l[0];
				$response['timestamp'] = $l[1];
			} else {
				$response['ipaddress'] = $line;
				$response['timestamp'] = date ("Y-m-d H:i:s", time());
			}
		}
	}
	OutputResponse($response, "publicip", "publicips", $format);
});


$app->get('/speedtest(/)(/:format)', function($format = 'html') {
	$response['download'] = null;
	$response['upload'] = null;
	$response['timestamp'] = null;

	$line = GetLastLine('/opt/minion/log/speedtest.log');
	if (!is_null($line)) {
		if (strpos($line, '|') !== FALSE) {
			$l = explode('|',$line); //download|upload|timestamp
			$response['download'] = $l[0];
			$response['upload'] = $l[1];
			$response['timestamp'] = $l[2];
		}
	} else {  //logs could have just been rotated
		$line = GetLastLine('/opt/minion/log/speedtest.1.log');
		if (!is_null($line)) {
			if (strpos($line, '|') !== FALSE) {
				$l = explode('|',$line); //download|upload|timestamp
				$response['download'] = $l[0];
				$response['upload'] = $l[1];
				$response['timestamp'] = $l[2];
			}	
		}
	}
	OutputResponse($response, "speedtest", "speedtests", $format);
});


$app->get('/speedtests(/)(/:count(/:format))', function($count = 10, $format = 'html') {
	if (!is_numeric($count)) {  //user passing in format and wants 10
		$format = $count;
		$count = 10;
	}


	$responses = array();
	$lines = GetLastLines('/opt/minion/log/speedtest.log', $count);
	if (count($lines) > 0) {
		foreach($lines as $line) {
			$response = array();
			if (strpos($line, '|') !== FALSE) {
				$l = explode('|',$line); //download|upload|timestamp
				$response['download'] = $l[0];
				$response['upload'] = $l[1];
				$response['timestamp'] = $l[2];

				array_push($responses, $response);
			}
		}
	}
	OutputResponse($responses, "speedtest", "speedtests", $format);
});




$app->run();