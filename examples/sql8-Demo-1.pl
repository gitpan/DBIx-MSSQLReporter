#!perl -w
#
# Name:
#	sql8-Demo-1.pl
#
# Purpose:
#	Demonstrate creating a table, inserting data, and retrieving that data,
#	under MS SQL Server 7 or MS Data Engine.
#
# Warning:
#	For MS SQL Server,  you must set $connexion to MSDE | ODBC | ADO_SQL | ADO_NTLM | ADO_ODBC.
#	For MS Data Engine, you must set $connexion to MSDE | ODBC.
#
# Note:
#	The table created, myTable, is not dropped for 2 reasons:
#	o So that you can use some other tool to examine it, eg Query Analyzer
#	o So it is available for sql8Demo2.pl
#
# Version
#	1.00	20-Feb-2000
#
# Author:
#	Robert Dorfman <dorfmanr@home.com>
#	Ron Savage <ron@savage.net.au>
#	http://savage.net.au/index.html
#
# Licence:
#	Australian Copyright (c) 1999-2002 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use DBI;

# ---------------------------------------------------------------

my($trace_level) = 0;

DBI->trace($trace_level);

# Constants.
my($sql8)		= 'SQL Server';
my($server)		= 'localhost';
my($user)		= 'sa';
my($password)	= 'perl';
my($database)	= 'tempdb';		# Must be known for ODBC.
my($tableName)	= 'myTable';

# Variables.
my($connexion)	= 'ODBC';		# Must be a key into %DSN and %connexion.

my(%DSN) =
(
	MSDE		=>
		{
			dsn		=> "DSN=LocalServer",
			heading	=> 'Using ODBC Driver Manager via DSN=LocalServer',
			mode	=> 'ODBC',
		},
	ODBC		=>
		{
			dsn		=> "Driver={$sql8};Server=$server;Database=$database;uid=$user;pwd=$password;",
			heading	=> 'Using ODBC Driver Manager via DBI::ODBC',
			mode	=> 'ODBC',
		},
	ADO_SQL		=>
		{
			dsn		=> "Provider=SQLOLEDB;Server=$server;Uid=$user;Pwd=$password;",
			heading	=> 'Using OLE DB provider with sql8 Authentication',
			mode	=> 'ADO',
		},
	ADO_NTLM	=>
		{
			dsn		=> "Provider=SQLOLEDB;Server=$server;Trusted_Connection=yes",
			heading	=> 'Using OLE DB provider with NTLM Authentication',
			mode	=> 'ADO',
		},
	ADO_ODBC	=>
		{
			dsn		=> "Driver={$sql8};Server=$server;Uid=$user;Pwd=$password;",
			heading	=> 'Using ODBC Driver Manager via DBI::ADO',
			mode	=> 'ADO',
		},
);

my($connect) = "dbi:$DSN{$connexion}{'mode'}(RaiseError=>1, PrintError=>1, Taint=>1):$DSN{$connexion}{'dsn'}";

print "$0 \n";
print "Heading:        $DSN{$connexion}{'heading'} \n";
print "DSN:            $DSN{$connexion}{'dsn'} \n";
print "Connect string: $connect \n\n";

# Connect.
print "Connecting ... \n\n";

my($dbh) = DBI->connect($connect) || die("Can't connect: $DBI::errstr");

# Drop table, if already present.
print "Dropping table: $tableName \n";

my($sql) = qq{
	if exists (select * from sysobjects where id = object_id('$tableName') )
		drop table $tableName};

print "SQL: $sql \n\n";

my($rv) = $dbh -> do($sql) || die("Can't do statement: $DBI::errstr");

# Create table.
print "Creating table: $tableName \n";

$sql = qq{CREATE TABLE $tableName (
		CODE varchar(10) NOT NULL,
		DESCRIPTION varchar(30) NOT NULL,
		COLOR int NOT NULL)};

print "SQL: $sql \n\n";

$rv = $dbh -> do($sql) || die("Can't do statement: $DBI::errstr");

# Populate table.
print "Populating table: $tableName \n";

my($sth, $rc);

while (<DATA>)
{
	chomp;
	my(@field) = split(/\|/, $_);
	# Note the single quotes in the varchar fields.
	$sql = "insert into $tableName (code, description, color) values ('$field[0]', '$field[1]', $field[2])";
	print "SQL: $sql \n";
	$sth	= $dbh -> prepare($sql) || die("Can't prepare statement: $DBI::errstr");
	$rc		= $sth->execute() || die("Can't execute statement: $DBI::errstr");
}

print "\n";

# Retrieve data.
$sql = qq{select code, description, color from $tableName};

print "Fetching from table: $tableName \n";
print "SQL: $sql \n\n";

$sth	= $dbh->prepare($sql) || die("Can't prepare statement: $DBI::errstr");
$rc		= $sth->execute() || die("Can't execute statement: $DBI::errstr");

print "Code\tColor\tDescription \n";

my($hashRef);
my($recordCount) = 0;

while($hashRef = $sth -> fetchrow_hashref() )
{
	$recordCount++;
	print "$$hashRef{'code'}\t\t$$hashRef{'color'}\t\t$$hashRef{'description'} \n";
}

print "\n";
print "Record count: $recordCount \n\n";
print "Disconnecting... \n";

$rc = $dbh -> disconnect();

# Success.
print "Success \n";
exit 0;

__END__
A01|One|101
B02|Two|202
C03|Three|303
D04|Four|404
