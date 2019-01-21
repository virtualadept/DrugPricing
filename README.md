# Drug Pricing

This imports the data from https://data.medicaid.gov FUL/NADAC csv into a mysql/mariadb database and allows you to run queries on pricing data by NDC and date range.

If you have no idea what FUL or NADAC mean, you probably don't want this.

Meant for an internal website. No security, no auth, use at your own risk.

I'm a pharmacist, not a coder, so expect duct-tape and bailing wire.

Pull requests welcome.  If you actually use this, drop me a line!

How to use:
1. Create the databases using the schema in the perl files.
2. Download the csv dumps of the FUL and NADAC from data.medicaid.gov.
3. Import them via the perl files such as ful_import.pl < FUL.CSV
4. Point PHP script at database.
5. ???
6. Old meme is old.
