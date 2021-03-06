#!/usr/bin/perl
#
# This is going to import the NADAC into the db with the following schema:
#
# CREATE TABLE nadac(
# rowid INT AUTO_INCREMENT,
# ndc_description varchar(255) NOT NULL,
# ndc varchar(12) NOT NULL,
# nadac_per_unit float(10) NOT NULL,
# effective_date DATE NOT NULL,
# pricing_unit varchar(5),
# pharmacy_type_indicator varchar(10),
# otc varchar(1),
# explanation_code varchar(10),
# classification_for_rate_setting varchar(10),
# corresponding_generic_drug_nadac_per_unit float(10),
# corresponding_generic_drug_effective_date datetime,
# as_of_date datetime,
# PRIMARY KEY (rowid));
#

# Turn terminal buffering off!
$|=1;

use DBI;

$dbh = DBI->connect("DBI:mysql:pricing","pricing","pricing") or die ("Cannot connect to db: $!\n");
print "Connected to the DB...... Now importing data\n\n";

$numimported = 0;

# Since we're dealing with 1/2 a gig of the same query, we'll prepare it now so we can shotgun the data in
$db=$dbh->prepare("INSERT INTO nadac (ndc_description,ndc,nadac_per_unit,effective_date,pricing_unit,pharmacy_type_indicator,otc,explanation_code,classification_for_rate_setting,corresponding_generic_drug_nadac_per_unit,corresponding_generic_drug_effective_date,as_of_date) values (?,?,?,?,?,?,?,?,?,?,?,?)");

foreach $csv (<STDIN>) {
	chomp $csv;
	# NAFTIN 2% GEL,54766077260,8.31743,06/20/2018,GM,C/I,N,"4, 5",B,,,12/12/2018
	# Having a "4, 5" in one field defeats the purpose of a CSV!@#!@
	# We dont care about shit in here, so just outright delete it.
	$csv =~ s/\"[0-9]\, *[0-9]\"//g;
	$csv =~ s/\"[0-9]\, *[0-9]\, *[0-9]\"//g;
	
	# I swear I cant win.
	$csv =~ tr/"//d;

	# Yeah, this is ghetto.
	($ndc_description,$ndc,$nadac_per_unit,$effective_date,$pricing_unit,$pharmacy_type_indicator,$otc,$explanation_code,$classification_for_rate_setting,$corresponding_generic_drug_nadac_per_unit,$corresponding_generic_drug_effective_date,$as_of_date) = split(',',$csv);
	

	# This is more ghetto
	# Rearrange the D/M/Y -> Y/M/D cuz Freedom Units rule!
	($edmonth,$edday,$edyear) = split ('/',$effective_date);
	$effective_date = "$edyear-$edmonth-$edday";
	($cdedmonth,$cdedday,$cdedyear) = split('/',$corresponding_generic_drug_effective_date);
	$corresponding_generic_drug_effective_date = "$cdedyear-$cdedmonth-$cdedday";
	($afdmonth,$afdday,$afdyear) = split('/',$as_of_date);
	$as_of_date = "$afdyear-$afdmonth-$afdday";
	

	$db->execute($ndc_description,$ndc,$nadac_per_unit,$effective_date,$pricing_unit,$pharmacy_type_indicator,$otc,$explanation_code,$classification_for_rate_setting,$corresponding_generic_drug_nadac_per_unit,$corresponding_generic_drug_effective_date,$as_of_date);
        
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
