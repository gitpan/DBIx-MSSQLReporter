#!perl -w
#
# Name:
#	sql8-Demo-2.pl
#
# Purpose:
#	Demonstrate retrieving system and user data.
#
# Warning:
#	For MS SQL Server,  you must set $connexion to MSDE | ODBC | ADO_SQL | ADO_NTLM | ADO_ODBC.
#	For MS Data Engine, you must set $connexion to MSDE | ODBC.
#
# Note:
#	This program displays table myTable in 2 different ways. This table is created
#	by running sql8Demo1.pl.
#
# Version
#	1.00	20-Feb-2000
#
# Author:
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

use DBIx::MSSQLReporter;

# ---------------------------------------------------------------

# Constants.
my($sql8)		= 'SQL Server';
my($server)		= 'localhost';
my($user)		= 'sa';
my($password)	= 'perl';
my($database)	= 'tempdb';		# Must be known for ODBC.
my($tableName)	= 'myTable';	# Must exist within $database.

# Variables.
my($connexion)	= 'ODBC';		# Must be a key into %DSN.

my(%DSN) =
(
	MSDE	=>
		{
			dsn		=> 'DSN=LocalServer',
			heading	=> 'Using ODBC Driver Manager via DSN=LocalServer',
			mode	=> 'ODBC',
		},
	ODBC	=>
		{
			dsn		=> "Driver={$sql8};Server=$server;Database=$database;uid=$user;pwd=$password;",
			heading	=> 'Using ODBC Driver Manager via DBI::ODBC',
			mode	=> 'ODBC',
		},
);

my($connect) = "dbi:$DSN{$connexion}{'mode'}(RaiseError=>1, PrintError=>1, Taint=>1):$DSN{$connexion}{'dsn'}";

print "$0 \n";
print "Heading:        $DSN{$connexion}{'heading'} \n";
print "DSN:            $DSN{$connexion}{'dsn'} \n";
print "Connect string: $connect \n\n";

# Connect.
print "Connecting ... \n\n";

my($reporter) = DBIx::MSSQLReporter -> new(connexion => $connect);

# Print.
print "System databases: \n";
my($sysDbName) = $reporter -> get_sysDbNames();
print join("\n", @$sysDbName), "\n\n";

print "User databases: \n";
print join("\n", @{$reporter -> get_dbNames()}), "\n\n";

print "System tables for db: $database: \n";
print join("\n", @{$reporter -> get_sysTableNames()}), "\n\n";

print "User tables for db: $database: \n";
print join("\n", @{$reporter -> get_tableNames()}), "\n\n";

print "System views for db: $database: \n";
print join("\n", @{$reporter -> get_sysViewNames()}), "\n\n";

print "User views for db: $database: \n";
print join("\n", @{$reporter -> get_viewNames()}), "\n\n";

print "Fields in table or view: $tableName: \n";
my($fieldName, $fieldType, $fieldPrecision) = $reporter -> get_fieldNames($tableName);
print join("\n", map{"Field: $$fieldName[$_]. Type: $$fieldType[$_]. Precision: $$fieldPrecision[$_]"} 0 .. $#{$fieldName}), "\n\n";

print "Fetching from table: $tableName \n";
my($sql) = 'select ' . join(', ', @$fieldName) . " from $tableName";
print "SQL: $sql \n\n";

print "Results of SQL printed by DBI's dump_results(): \n";
my($sth) = $reporter -> do($sql);
$sth -> dump_results();
$sth -> finish();
print "\n\n";

my($sep) = '===';
print "Results of SQL printed by our hash2Table(): \n";
my($select)	= $reporter -> select($sql, $sep);
my($html)	= $reporter -> hash2Table($select, $sep);
print $html;
print "\n";

# Disconnect.
print "Disconnecting... \n";

# Success.
print "Success \n";
exit 0;
