#!/usr/bin/perl
#
# This is to import the FUL amounts into the db.  Of course it uses a *completely* different
# schema than nadac.  Thanks Obama!
#
#13,ACETAMINOPHEN; CODEINE PHOSPHATE,300MG;15MG,TABLET,ORAL,TAB,0.054582,0.12948,100,00093-0050-01,Yes,Y,2018,12
#
#CREATE TABLE ful(
#	rowid INT AUTO_INCREMENT,
#	product_group INT NOT NULL,
#	ingredient VARCHAR(255) NOT NULL,
#	strength VARCHAR(16) NOT NULL,
#	dosage VARCHAR(16) NOT NULL,
#	route VARCHAR(16) NOT NULL,
#	mdr_unit_type VARCHAR(16),
#	weighted_average_amps FLOAT(10) UNSIGNED,
#	aca_ful FLOAT(10) UNSIGNED,
#	package_size INT NOT NULL,
#	ndc VARCHAR(12) NOT NULL,
#	a_rated INT NOT NULL,
#	aca_ful_calculation_basis VARCHAR(16) NOT NULL,
#	year INT NOT NULL,
#	month INT NOT NULL,
#	date DATETIME NOT NULL,
#	PRIMARY KEY (rowid,ndc,date));
#

$|=1;

use DBI;

$dbh = DBI->connect("DBI:mysql:pricing","pricing","pricing") or die ("Cannot connect to db: $!\n");
print "Connected to the DB...... Now importing data\n";


# Prepare the query thats going to enlarge my VM's anus.
$db=$dbh->prepare("INSERT INTO ful (product_group,ingredient,strength,dosage,route,mdr_unit_type,weighted_average_amps,aca_ful,package_size,ndc,a_rated,aca_ful_calculation_basis,year,month,date) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

$numimported = 0;

foreach $csv (<STDIN>) {
	chomp $csv;
	# Yeah, this is ghetto.
	($product_group,$ingredient,$strength,$dosage,$route,$mdr_unit_type,$weighted_average_amps,$aca_ful,$package_size,$ndc,$a_rated,$aca_ful_calculation_basis,$year,$month) = split(',',$csv);

	# Unlike the NADAC there isn't any date mangling/formatting or strange "'s.... We think.	
	#
	# THEY SERIOUSLY PUT THE -'s IN THE NDC? YOU FUCKS!
	$ndc =~ tr/-//d;
	$date = "$year-$month-15";

	$db->execute($product_group,$ingredient,$strength,$dosage,$route,$mdr_unit_type,$weighted_average_amps,$aca_ful,$package_size,$ndc,$a_rated,$aca_ful_calculation_basis,$year,$month,$date);
	
	# Keep track if this is still going.
	$numimported++;
	if ($numimported % 1000 == 0) {
		print " $numimported ";
	} else { print "."; }

}

# Clean up shit, flush the buffers, and shut 'er down (shes pumpin mud).
print "\n\nBing! Fries are done! $numimported were imported\n\n";
$db->finish();
$dbh->disconnect();
