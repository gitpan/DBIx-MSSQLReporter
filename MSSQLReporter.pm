package DBIx::MSSQLReporter;

# Name:
#	DBIx::MSSQLReporter.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Tabs:
#	4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 1999-2002 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use vars qw($AUTOLOAD $VERSION @ISA @EXPORT @EXPORT_OK);

use Carp;
use DBI qw(:sql_types);

require Exporter;

@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

@EXPORT		= qw();

$VERSION	= '1.01';

# -----------------------------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------------------------

# Encapsulated class data.
# This is a list of attributes the user
# can use when calling DBIx::MSSQLReporter -> new().
# I call these standard attributes, as opposed
# to non-standard attributes which the user
# should not refer to in the call to new().
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-88477-779-1
#	Chapter 3
{
	my(%_attribute) =
	(	# Name		=> default
		_connexion	=> '',
	);

	# Return the default for any attribute.
	sub _default_for
	{
		my($self, $attribute) = @_;

		$_attribute{$attribute};

	}	# End of _default_for.

	# Return the standard attributes.
	sub _standard_keys
	{
		keys(%_attribute);

	}	# End of _standard_keys.

	# Tested, to some extent, with SQL Server and Postgres.
	# Authors:
	#	Dominique Cretel <dominique.cretel@sema.be>
	#	Ron Savage <ron@savage.net.au>
	my(%_field_type) =
	(
		'-1'	=> 'Text',
		'1'		=> 'Char',
		'2'		=> '2 - unknown',
		'3'		=> 'Decimal',
		'4'		=> 'Integer',
		'5'		=> 'Smallint',
		'6'		=> '6 - unknown',
		'7'		=> 'Double precision',
		'8'		=> 'Double precision',
		'9'		=> 'Date',
		'10'	=> 'Time',
		'11'	=> 'Datetime/Timestamp',
		'12'	=> 'Varchar',
		'13'	=> '13 - unknown',
		'14'	=> '14 - unknown',
		'15'	=> '15 - unknown',
		'16'	=> '16 - unknown',
		'17'	=> '17 - unknown',
		'18'	=> '18 - unknown',
		'19'	=> '19 - unknown',
		'20'	=> '20 - unknown',
	);

	# Return readable type for numeric type.
	sub _field_type
	{
		my($self, $field) = @_;

		$_field_type{$field};
	}

}	# End of encapsulated class data.

# ------------------------------------------------------------------------
# Execute any SQL command.

sub do
{
	my($self, $sql)	= @_;
	my($dbh)		= $self -> {'_dbh'};
	my($sth)		= $dbh -> prepare($sql) or croak $DBI::errstr;

	$sth -> execute() or croak $DBI::errstr;

	$sth;

}	# End of do.

# ------------------------------------------------------------------------
# Drop a database.

sub dropDB
{
	my($self, $dbName) = @_;

	my($dbh)	= $self -> {'_dbh'};
	my($result)	= $dbh -> do("drop database $dbName");

	croak $DBI::errstr if (! $result);

}	# End of dropDB.

# ------------------------------------------------------------------------
# Drop a table.

sub dropTable
{
	my($self, $tableName) = @_;

	my($dbh)	= $self -> {'_dbh'};
	my($result)	= $dbh -> do("if exists (select * from sysobjects where id = object_id(N'[dbo].[$tableName]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table [dbo].[$tableName]");

	croak $DBI::errstr if (! $result);

}	# End of dropTable.

# -----------------------------------------------------------------
# Get the names of all user databases.
# $sysDbCount is the number of system database names to ignore, 4 by default.

sub get_dbNames
{
	my($self, $sysDbCount)	= @_;
	$sysDbCount				= 4 if (! $sysDbCount);
	my($dbh)				= $self -> {'_dbh'};

	# See MS SQL Server 7.0/Books On Line/(Search) sysdatabases/(Result) sysdatabases (T-SQL).
	# dbId	Name
	#	1	master
	#	2	tempDb
	#	3	model
	#	4	msDb
	#	?	msSqlWeb
	my($araRef)	= $dbh -> selectcol_arrayref("select * from master.dbo.sysdatabases where dbid > $sysDbCount") or croak $dbh -> errstr;
	@$araRef	= map{lc} sort @$araRef;

	$araRef;

}	# End of get_dbNames.

# -----------------------------------------------------------------
# Get the names of all fields in the given table.

sub get_fieldNames
{
	my($self, $tableName)	= @_;
	my($dbh)				= $self -> {'_dbh'};
	my($sth)				= $self -> do("select * from $tableName where 1 = 0");
	my($name)				= $sth -> {NAME};
	my(@type)				= map{$self -> _field_type($_)} @{$sth -> {TYPE} };
	my($precision)			= $sth -> {PRECISION};

	($name, \@type, $precision);

}	# End of get_fieldNames.

# -----------------------------------------------------------------
# Get the names of all user tables in the current database.

sub get_tableNames
{
	my($self)	= @_;
	my($dbh)	= $self -> {'_dbh'};
	my($araRef) = $dbh -> selectcol_arrayref("select name from sysobjects where OBJECTPROPERTY(id, N'IsUserTable') = 1") or croak $dbh -> errstr;
	@$araRef	= map{lc} sort @$araRef;

	$araRef;

}	# End of get_tableNames.

# -----------------------------------------------------------------
# Get the names of all user views in the current database.

sub get_viewNames
{
	my($self)	= @_;
	my($dbh)	= $self -> {'_dbh'};
	my($araRef) = $dbh -> selectcol_arrayref("select name from sysobjects where OBJECTPROPERTY(id, N'IsView') = 1 and objectProperty(id, N'IsMSShipped') = 0") or croak $dbh -> errstr;
	@$araRef	= map{lc} sort @$araRef;

	$araRef;

}	# End of get_viewNames.

# -----------------------------------------------------------------
# Get the names of all system databases.
# $sysDbCount is the number of system database names to recognize, 4 by default.

sub get_sysDbNames
{
	my($self, $sysDbCount)	= @_;
	$sysDbCount				= 4 if (! $sysDbCount);
	my($dbh)				= $self -> {'_dbh'};

	# See MS SQL Server 7.0/Books On Line/(Search) sysdatabases/(Result) sysdatabases (T-SQL).
	# dbId	Name
	#	1	master
	#	2	tempDb
	#	3	model
	#	4	msDb
	#	?	msSqlWeb
	my($araRef)	= $dbh -> selectcol_arrayref("select * from master.dbo.sysdatabases where dbid <= $sysDbCount") or croak $dbh -> errstr;
	@$araRef	= map{lc} sort @$araRef;

	$araRef;

}	# End of get_sysDbNames.

# -----------------------------------------------------------------
# Get the names of all system tables in the current database.

sub get_sysTableNames
{
	my($self)	= @_;
	my($dbh)	= $self -> {'_dbh'};
	my($araRef) = $dbh -> selectcol_arrayref("select name from sysobjects where OBJECTPROPERTY(id, N'IsSystemTable') = 1") or croak $dbh -> errstr;
	@$araRef	= map{lc} sort @$araRef;

	$araRef;

}	# End of get_sysTableNames.

# -----------------------------------------------------------------
# Get the names of all system views in the current database.

sub get_sysViewNames
{
	my($self)	= @_;
	my($dbh)	= $self -> {'_dbh'};
	my($araRef) = $dbh -> selectcol_arrayref("select name from sysobjects where OBJECTPROPERTY(id, N'IsView') = 1 and objectProperty(id, N'IsMSShipped') = 1") or croak $dbh -> errstr;
	@$araRef	= map{lc} sort @$araRef;

	$araRef;

}	# End of get_sysViewNames.

# ------------------------------------------------------------
# Convert a hash reference into an HTML table.
# $sep separates the values of different rows in each column.
# It defaults to $;.

sub hash2Table
{
	my($self, $hashRef, $sep, $keyRef)	= @_;
	$sep								= $; if (! $sep);

	# By default, the columns are displayed in the order
	# specified by $keyRef, where $keyRef is a reference
	# to a hash, and in that hash the keys are the column
	# names and the sort order is given by the 'order' subkey.
	# Eg:
	#	my(%key) =
	#	(
	#		hostName	=>
	#			{
	#				data	=> '',
	#				order	=> 1,
	#			},
	#		userName	=>
	#			{
	#				data	=> '',
	#				order	=> 2,
	#			},
	#		dbName		=>
	#			{
	#				data	=> '',
	#				order	=> 3,
	#			},
	#	);

	# If the 2nd parameter is not a hash,
	# fabricate a hash to sort on.
	my(@key) = sort(keys(%$hashRef) );

	if (ref($keyRef) ne 'HASH')
	{
		$keyRef = {};

		my($order) = 0;
		my($key);

		for $key (@key)
		{
			$order++;
			$$keyRef{$key}	= {};
			$$keyRef{$key}{'order'}	= $order;
		}
	}

	# Determine the column order.
	@key = sort {$$keyRef{$a}{'order'} cmp $$keyRef{$b}{'order'} } @key;

	# The keys will be the column headings.
	my($html) = "\n<table border=1>\n\t<tr>\n";
	my($key);

	for $key (@key)
	{
		$html .= "\t\t<th>$key</th>\n";
	}

	$html .= "\t</tr>\n";

	# Get the # of rows of data.
	my(@row)	= keys(%$hashRef);
	@row		= split(/$sep/, $$hashRef{$row[0]});
	my($row);

	# Display each row.
	for $row (0 .. $#row)
	{
		$html .= "\t<tr>\n";

		# Display the row in sorted order.
		for $key (@key)
		{
			my(@field) = split(/$sep/, $$hashRef{$key});
			$html .= "\t\t<td>" . $field[$row] . "</td>\n";
		}

		$html .= "\t</tr>\n";
	}

	# The '\n's just make the output easy to debug.
	$html .= "</table>\nRow count: " . ($#row + 1) . "\n";

	# Return the HTML.
	$html;

}	# End of hash2Table.

# -----------------------------------------------------------------

sub new
{
	my($caller, %arg)	= @_;
	my($caller_is_obj)	= ref($caller);
	my($class)			= $caller_is_obj || $caller;
	my($self)			= bless {}, $class;

	# These are non-standard class data, and so are not
	# in the encapsulated class data set above.
	$self -> {'_dbh'}	= '';
	$self -> {'_sql'}	= '';

	# Initialize all standard attributes.
	for my $attributeName ($self -> _standard_keys() )
	{
		my($argName) = ($attributeName =~ /^_(.*)/);

		# Did the caller provide a value?
		if (exists($arg{$argName}) )
		{
			$self -> {$attributeName} = $arg{$argName};
		}
		else
		{
			# If the caller is an object, use its values.
			if ($caller_is_obj)
			{
				$self -> {$attributeName} = $caller -> {$attributeName};
			}
			else
			{
				# Otherwise, use our defaults.
				$self -> {$attributeName} = $self -> _default_for($attributeName);
			}
		}
	}

	$self -> {'_dbh'} = DBI->connect($self -> {'_connexion'},
										{
											PrintError	=> 0,
											RaiseError	=> 0,
										}) || croak "Can't connect: $DBI::errstr\n";
	$self -> {'_dbh'} -> {LongReadLen} = 65534;

	return $self;

}	# End of new.

# ------------------------------------------------------------------------
# Execute a select command.
# Return the hash ref of the data.
# This can be passed straight to hash2Table.
# $sep separates the values of different rows in each column.
# It defaults to $;.

sub select
{
	my($self, $sql, $sep)	= @_;
	$sep					= $; if (! $sep);
	$self -> {'_select'}	= {};
	my($sth)				= $self -> do($sql);

	my($rowRef, $key);

	# Build a hash, $self -> {'_select'}, where the keys are the column headings,
	# ie the field names, and the values are the column data, separated by $sep.
	while ( ($rowRef = $sth -> fetchrow_hashref() ) )
	{
		for $key (keys(%$rowRef) )
		{
			$$rowRef{$key}				= 'NULL'				if (! defined($$rowRef{$key}) );
			$self -> {'_select'}{$key}	.= "$sep$$rowRef{$key}"	if (defined($self -> {'_select'}{$key}) );
			$self -> {'_select'}{$key}	= $$rowRef{$key}		if (! defined($self -> {'_select'}{$key}) );
		}
	}

	$sth -> finish();

	$self -> {'_select'};

}	# End of select.

# -----------------------------------------------------------------

sub DESTROY
{
	my($self) = @_;

	$self -> {'_dbh'} -> disconnect();

}	# End of DESTROY.

# -----------------------------------------------------------------
# Fabricate accessors and mutators on-the-fly.

sub AUTOLOAD
{
	no strict 'refs';

	my($self, $newval) = @_;

	# Was it a get... method?
	if ($AUTOLOAD =~ /.*::get(_\w+)/)
	{
		my($attributeName)	= $1;
		*{$AUTOLOAD}		= sub { return $_[0] -> {$attributeName}; };
		return $self -> {$attributeName};
	}

	# Was it a set... method?
	if ($AUTOLOAD =~ /.*::set(_\w+)/)
	{
		my($attributeName)	= $1;
		*{$AUTOLOAD}		= sub { $_[0] -> {$attributeName} = $_[1]; return; };
		$self -> {$1}		= $newval;
		return;
	}

	# Must have been a mistake then...
	croak "No such method: $AUTOLOAD";

}	# End of AUTOLOAD.

# -----------------------------------------------------------------

# Autoload methods go after =cut, and are processed by the autosplit program.

1;

__END__

=head1 NAME

DBIx::MSSQLReporter - An module to connect Perl to MS SQL Server and MS Data Engine

=head1 SYNOPSIS

This is complete, runnable program.

Since you only use this module after installing MS SQL Server or MS Data Engine,
you should not even have to worry about the DSN.

	#!perl -w
	use strict;
	use DBIx::MSSQLReporter;

	my($connect) = "dbi:ODBC(RaiseError=>1, PrintError=>1, Taint=>1):DSN=LocalServer";
	my($reporter) = DBIx::MSSQLReporter -> new(connexion => $connect);

	print "User tables: \n";
	print join("\n", @{$reporter -> get_tableNames()}), "\n\n";

=head1 DESCRIPTION

C<DBIx::MSSQLReporter> encapsulates the connection between Perl and MS SQL Server.

C<DBIx::MSSQLReporter> was written so that I could teach myself about MS SQL Server and
MSDE, and as part of my Perl tutorial series.

It should be clear from the name that this module is database-engine-specific. If you
plan on writing code which is independent of any particular database, look elsewhere.

See the URI, below, for my demos sql7Demo[23].pl, which both use this module.

sql7Demo2.pl is a command-line program. sql7Demo3.pl is a CGI script.

Lastly, note that this module has a chequered future: I may well re-write it to fit
under the umbrella of DBIx::Easy, or someone else working independently may have
already released such a module.

=head1 INSTALLATION

You install C<DBIx::MSSQLReporter>, as you would install any perl module,
by running these commands:

	perl Makefile.PL
	make
	make test
	make install

=head1 CONSTRUCTOR new

The constructor takes 1 parameter and 1 value for that parameter.

It croaks if it can't connect. Otherwise it returns an object you can use thus:

	my($reporter) = DBIx::MSSQLReporter -> new(connexion => $connect);
	print join("\n", @{$reporter -> get_viewNames()}), "\n\n";

=head1 METHOD do($sql)

It croaks if it can't prepare() and execute() the given SQL.

It returns a statment handle, which you need for things like:

	my($sth) = $reporter -> do($sql);
	$sth -> dump_results();
	$sth -> finish();

dump_results() is built-in to DBI.

=head1 METHOD dropDB($dbName)

It croaks if it can't drop the given database.

	$reporter -> dropDB($dbName);

=head1 METHOD dropTable($tableName)

It croaks if it can't drop the given table.

	$reporter -> dropTable($tableName);

=head1 METHOD get_dbNames($sysDbCount)

It returns a sorted list of user database names, all in lower case.

$sysDbCount is optional. It defaults to 4, which means this method ignores the 4
system tables. See get_sysDbNames(), below.

	my($dbName) = $reporter -> get_dbNames();
	print "User databases: \n";
	print join("\n", @$dbName), "\n\n";

=head1 METHOD get_fieldNames($tableName)

It returns a list of references to the names, types, and precisions, of the fields
in the given table.

	my($fieldName, $fieldType, $fieldPrecision) = $reporter -> get_fieldNames($tableName);
	print join("\n", map{"Field: $$fieldName[$_]. Type: $$fieldType[$_]. Precision: $$fieldPrecision[$_]"} 0 .. $#{$fieldName}), "\n\n";

=head1 METHOD get_tableNames()

It returns a sorted list of user table names, all in lower case. Recall, the DSN
specified the database.

	my($tableName) = $reporter -> get_tableNames();
	print "User tables: \n";
	print join("\n", @$tableName), "\n\n";

=head1 METHOD get_viewNames()

It returns a sorted list of user view names, all in lower case. Recall, the DSN
specified the database.

	my($viewName) = $reporter -> get_viewNames();
	print "User views: \n";
	print join("\n", @$viewName), "\n\n";

=head1 METHOD get_sysDbNames($sysDbCount)

It returns a sorted list of system database names, all in lower case. On my system,
I get master, model, msDb and tempDb.

$sysDbCount is optional. It defaults to 4, which means this method returns the 4
system tables. See get_dbNames(), above.

	my($sysDbName) = $reporter -> get_sysDbNames();
	print "System databases: \n";
	print join("\n", @$sysDbName), "\n\n";

=head1 METHOD get_sysTableNames()

It returns a sorted list of system table names, all in lower case. Recall, the DSN specified
the database.

	my($sysTableName) = $reporter -> get_sysTableNames();
	print "System tables: \n";
	print join("\n", @$sysTableName), "\n\n";

=head1 METHOD get_sysViewNames()

It returns a sorted list of system view names, all in lower case. Recall, the DSN
specified the database.

	my($sysViewName) = $reporter -> get_sysViewNames();
	print "System views: \n";
	print join("\n", @$sysViewName), "\n\n";

=head1 METHOD hash2Table($select, $sep, $keyRef)

Convert a hash reference, as returned by $reporter -> select($sql), into an HTML
table. See select(), below, for details.

	my($html) = $reporter -> hash2Table($select);

$sep is optional. It separates the values of different rows in each column. It
defaults to $;.

$keyRef is optional. It is a hash reference used to specify the order of columns.
It defaults to sorting the keys of %$select.

If you wish to use $keyRef, prepare it thus:

	my(%key) =
	(
		hostName	=>
			{
				someData	=> '',
				order		=> 2,
			},
		userName	=>
			{
				someData	=> '',
				order		=> 1,
			},
	);

	my($html) = $reporter -> hash2Table($select, $;, \%key);

	The key 'order' is used to order the keys 'hostName' and 'userName', which are
	presumed to appear as keys in %$select.

	The key 'someData' is ignored.

=head1 METHOD select($sql, $sep)

It croaks if it can't prepare() and execute() the given SQL.

$sep is optional. It defaults to $;.

It returns a reference to a hash, which hold the results of the select.

The keys of the hash are the names of the fields, which can be used for column
headings.

The values of the hash are the values of the fields, which can be used for the
column data. The values in each column are, by default, separated by Perl's $;
variable.

	my($select) = $reporter -> select($sql);

Warning: select() selects the whole table. Ideally we'd use DBIx::Recordset to page
thru the table, but I had too many problems with various versions of DBIx::Recordset.

If you have binary data containing $;, you I<E<lt>mustE<gt>> set $sep to something
else. Of course, with binary data, there may be no 'safe' character (string) which
does not appear in your data.

Alternately, store your binary data in files, and put the file name or URI in the
database.

The hash reference can be passed straight to hash2Table for conveting into an HTML
table. Eg:

	my($html) = $reporter -> hash2Table($select);
	print $html;

=head1 AUTHOR

C<DBIx::MSSQLReporter> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2000.

Source available from http://savage.net.au/Perl.html.

=head1 LICENCE

Australian copyright (c) 1999-2002 Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
