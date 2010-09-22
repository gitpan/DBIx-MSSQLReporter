#!perl -w
#
# Name:
#	sql8-Demo-3.pl
#
# Purpose:
#	A CGI scrip to demonstrate retrieving system and user data.
#
# Warning:
#	For MS SQL Server,  you must set $connexion to MSDE | ODBC | ADO_SQL | ADO_NTLM | ADO_ODBC.
#	For MS Data Engine, you must set $connexion to MSDE | ODBC.
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

use CGI;
use DBIx::MSSQLReporter;

use constant ACTION_DISPLAY_TABLE	=> 'Display table';
use constant ACTION_INTRODUCTION	=> 'Connect to DB server';
use constant ACTION_LIST_TABLES		=> 'List table names';
use constant HEADING				=> 'Display Tables';

# ---------------------------------------------------------------
# This hash lists the names of the fields on the form.
# A for loop like 'for (keys(%formField) )' is the most
# convenient way to refer to all fields on the form.

my(%formField)	=
(
	tableName 	=> '',
);

# ---------------------------------------------------------------

sub connect
{
	# Constants.
	my($sql8)		= 'SQL Server';
	my($server)		= 'localhost';
	my($user)		= 'sa';
	my($password)	= 'perl';
	my($database)	= 'tempdb';		# Must be known for ODBC.

	# Variables.
	my($connexion)	= 'ODBC';		# Must be a key into %DSN.

	my(%DSN) =
	(
		MSDE		=>
		{
			dsn		=> 'DSN=LocalServer',
			heading	=> 'Using ODBC Driver Manager via DSN=LocalServer',
			mode	=> 'ODBC',
		},
		ODBC		=>
		{
			dsn		=> "Driver={$sql8};Server=$server;Database=$database;uid=$user;pwd=$password;",
			heading	=> 'Using ODBC Driver Manager via DBI::ODBC',
			mode	=> 'ODBC',
		},
	);

	my($connect)	= "dbi:$DSN{$connexion}{'mode'}(RaiseError=>1, PrintError=>1, Taint=>1):$DSN{$connexion}{'dsn'}";
	my($reporter)	= DBIx::MSSQLReporter -> new(connexion => $connect);

	$reporter;

}	# End of connect.

# ---------------------------------------------------------------

sub displayTable
{
	my($cgi, $formData, $reporter)				= @_;
	# Strip off 'User table: ' etc.
	$$formData{'tableName'}						=~ s/^.+?\:\s+(.+)$/$1/;
	my($fieldName, $fieldType, $fieldPrecision)	= $reporter -> get_fieldNames($$formData{'tableName'});
	my($sql)									= 'select ' . join(', ', @$fieldName) . " from $$formData{'tableName'}";
	my($select)									= $reporter -> select($sql);
	my($html)									= $reporter -> hash2Table($select);

	print	$cgi -> header(),
		$cgi -> start_html({title => HEADING}),
		$cgi -> h1({align => 'center'}, $$formData{'tableName'}),
		$cgi -> h3({align => 'center'}, 'SQL: ' . $sql),
		$html,
		$cgi -> start_form(),
		$cgi -> submit({
			name	=> 'action',
			value	=> ACTION_LIST_TABLES}),
		$cgi -> end_form(),
		$cgi -> hr(),
		"<A HREF='http://savage.net.au/index.html'>Ron Savage's home page</A></ADDRESS>",
		$cgi -> end_html(),
		"\n";

	exit(0);
}
# ---------------------------------------------------------------

sub printIntroForm
{
	my($cgi) = @_;

	print	$cgi -> header(),
		$cgi -> start_html({title => HEADING}),
		$cgi -> h1({align => 'center'}, HEADING),
		$cgi -> start_form(),
		$cgi -> submit({
			name	=> 'action',
			value	=> ACTION_INTRODUCTION}),
		$cgi -> end_form(),
		$cgi -> hr(),
		"<A HREF='http://savage.net.au/index.html'>Ron Savage's home page</A></ADDRESS>",
		$cgi -> end_html(),
		"\n";

}	# End of printIntroForm.

# ---------------------------------------------------------------

sub processForm
{
	my($action, $cgi, $formData)	= @_;
	my($reporter)					= &connect();
	my($tableName)					= $reporter -> get_tableNames();
	my($viewName)					= $reporter -> get_viewNames();
	my($sysTableName)				= $reporter -> get_sysTableNames();
	my($sysViewName)				= $reporter -> get_sysViewNames();
	@$tableName						= map{"User table: $_"} @$tableName;
	@$viewName						= map{"User view:  $_"} @$viewName;
	@$sysTableName					= map{"Sys table:  $_"} @$sysTableName;
	@$sysViewName					= map{"Sys view:   $_"} @$sysViewName;
	$tableName						=  [@$tableName, @$viewName, @$sysTableName, @$sysViewName];

	&displayTable($cgi, $formData, $reporter) if ($action eq ACTION_DISPLAY_TABLE);

	print	$cgi -> header(),
		$cgi -> start_html({title => HEADING}),
		$cgi -> h1({align => 'center'}, HEADING),
		$cgi -> start_form(),
		'Choose a table: ',
		$cgi -> popup_menu({
			name		=> 'tableName',
			value		=> $tableName,
			default		=> $$tableName[0]}),
		$cgi -> p(),
		$cgi -> submit({
			name	=> 'action',
			value	=> ACTION_DISPLAY_TABLE}),
		' ',
        $cgi -> reset('Reset form'),
		$cgi -> end_form(),
		$cgi -> hr(),
		"<A HREF='http://savage.net.au/index.html'>Ron Savage's home page</A></ADDRESS>",
		$cgi -> end_html(),
		"\n";

	exit(0);

}	# End of processForm.

# ---------------------------------------------------------------

# The next line is needed due to a bug in Cookie.pm,
# unless you assume every browser infallibly sets it...
$ENV{'SCRIPT_NAME'}	= $0;
$ENV{'PATH'}		= '';
my($cgi)			= CGI -> new();

# Recover the action.
my($action) = $cgi -> param('action');

# Recover the data, if any, from the current form.
my($key, %formData);

for $key (keys(%formField) )
{
	$formData{$key}	= $cgi -> param($key);
}

# If there is any action, process the data on the form.
# If there is no action, simply drop thru and display the form.
&processForm($action, $cgi, \%formData) if ($action ne '');

&printIntroForm($cgi);

exit(0);
