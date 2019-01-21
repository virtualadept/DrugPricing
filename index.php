<?php

$mysqli = mysqli_connect('127.0.0.1','pricing','pricing','pricing') or die ("$mysqli_connect_error");

// Lets start the static webpage shit.
print "<HTML>\n
	<HEAD><TITLE>Franks Awesome Pricing Lookup!</TITLE>\n
	<style>\n
	table {
  		width:100%;
	}
	table, th, td {
  		border: 1px solid black;
  		border-collapse: collapse;
	}
	th, td {
  		padding: 5px;
  		text-align: left;
	}
	table#t01 tr:nth-child(even) {
  		background-color: #eee;
	}
		table#t01 tr:nth-child(odd) {
 		background-color: #fff;
	}
	table#t01 th {
  		background-color: black;
  		color: white;
	}
	</style>\n
	<BODY>\n";


// Grab the GET variables and scrub them of injection material.
$fullndc = $mysqli->real_escape_string($_GET['fullndc']);
$startmonth = $mysqli->real_escape_string($_GET['startmonth']);
$startyear = $mysqli->real_escape_string($_GET['startyear']);
$endmonth = $mysqli->real_escape_string($_GET['endmonth']);
$endyear = $mysqli->real_escape_string($_GET['endyear']);

// Debug output
$debug = "<center>------Log Start------</center>\n";
$debug .= "<p><b>" . date(DATE_RFC2822) . "</b>\n";

// Entry Form
print "<center><form action=\"index.php\" method=\"get\">\n
	NDC: <input type=\"text\" name=\"fullndc\" value=$fullndc size=11 maxlength=11><br>\n
	Start Month: <input type=\"text\" name=\"startmonth\" value=$startmonth size=2 maxlength=2>\n
	Start Year: <input type=\"text\" name=\"startyear\" value=$startyear size=4 maxlength=4><br>\n
	End Month: <input type=\"text\" name=\"endmonth\" value=$endmonth size=2 maxlength=2>\n
	End Year: <input type=\"text\" name=\"endyear\" value=$endyear size=4 maxlength=4><br>\n
	<input type=\"submit\"><br>\n
	</form></center><hr>\n";
	if (!$fullndc) { exit; }


// START SANITY CHECKS
//
// Is this variable even a number?
if (!is_numeric($fullndc) || !is_numeric($startmonth) || !is_numeric($startyear) || !is_numeric($endmonth) || !is_numeric($endyear)) {
	print "Try entering in some numbers jackwad!\n";
	exit;
}

// Is the NDC the proper length.  How about the month and year?
if (strlen($fullndc) != 11) { print "Missing a few NDC digits!\n"; exit; }
if (($startmonth < 1) || ($startmonth > 12)) { print "Check your month!\n"; exit; }
if (($endmonth < 1) || ($endmonth > 12)) { print "Check your month!\n"; exit; }
//
// END SANITY CHECKS

// Strip last 2 off of NDC for Jeff
$ndc = substr($fullndc,0,-2);

// START HEADER
//
print "<table id=\"t01\">";
print "<tr>\n";
$headerquery = "SELECT ndc,ndc_description FROM nadac WHERE ndc LIKE \"$ndc%\" LIMIT 1";
if ($headerresult = mysqli_query($mysqli,$headerquery)){
	while ($header = mysqli_fetch_assoc($headerresult)) {
		echo "<th><center>Query NDC:$ndc</center></th><th><center>Full NDC:" . $header['ndc'] . "</center></th>\n<th><center>" . $header['ndc_description'] . "</center></th><th><center>From: $startmonth-$startyear</center></th><th><center>To: $endmonth-$endyear</center></th><br>\n";
	}
}
print "</tr>\n";
//
// END HEADER


// START FUL GRAB
//
print "<tr><td><b><center>FUL PER UNIT</center></b></td><td><b><center>AS OF DATE</center></b></td></tr>";
$fulquery = "SELECT DISTINCT(aca_ful),date,month,year FROM ful WHERE ndc LIKE \"$ndc%\" AND date BETWEEN CAST(\"$startyear-$startmonth-01\" AS DATE) AND CAST(\"$endyear-$endmonth-31\" AS DATE)  ORDER BY date DESC";
//print "<b>$fulquery</b><br>\n";
$fultime = microtime(true);
if ($fulresult = mysqli_query($mysqli,$fulquery)) {
	$fultime = microtime(true)-$fultime;
	if (mysqli_num_rows($fulresult) == 0) {
		print "<td><center>No FUL Data Found</center></td>\n";
	}
	while ($ful = mysqli_fetch_assoc($fulresult)){
		echo "<td>" . $ful['aca_ful'] . "</td><td>" . $ful['year'] . "-" . $ful['month'] . "</td></tr>";
	}
}
//
// END FUL GRAB


// START NADAC GRAB
//
print "<tr><td><b><center>NADAC PER UNIT</center></b></td><td><b><center>AS OF DATE</center></b></td></tr>";
$nadacquery = "SELECT DISTINCT(nadac_per_unit),as_of_date FROM nadac WHERE ndc LIKE \"$ndc%\" AND as_of_date BETWEEN CAST(\"$startyear-$startmonth-01\" AS DATE) AND CAST(\"$endyear-$endmonth-31\" AS DATE)  ORDER BY as_of_date DESC";
//print "<b>$nadacquery</b><br>\n";
$nadactime = microtime(true);
if ($nadacresult = mysqli_query($mysqli,$nadacquery)) {
	$nadactime = microtime(true)-$nadactime;
	if (mysqli_num_rows($nadacresult) == 0) {
		print "<td><center>No NADAC Data Found</center></td>\n";
	}
	while ($nadac = mysqli_fetch_assoc($nadacresult)) {
		echo "<td>" . $nadac['nadac_per_unit'] . "</td><td>" . $nadac['as_of_date'] . "</td></tr>";
	}
}
//
// END NADAC GRAB

print "</table>";
$debug .="<li>Full NDC $fullndc - Query NDC $ndc<br>\n";
$debug .= "<li>We are running a query on $ndc from $startmonth-$startyear to $endmonth-$endyear<BR>\n";
$debug .= "<li> FUL query took: $fultime seconds\n";
$debug .= "<li> NADAC query took: $nadactime seconds\n";











print "<hr><br><br>\n";
print "<center>$debug<br>------Log End------</center>";
print "</body>\n</html>\n";
