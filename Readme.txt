NAME
    DBIx::MSSQLReporter - An module to connect Perl to MS SQL Server and MS
    Data Engine

SYNOPSIS
    This is complete, runnable program.

    Since you only use this module after installing MS SQL Server or MS Data
    Engine, you should not even have to worry about the DSN.

            #!perl -w
            use strict;
            use DBIx::MSSQLReporter;
        
            my($connect) = "dbi:ODBC(RaiseError=>1, PrintError=>1, Taint=>1):DSN=LocalServer";
            my($reporter) = DBIx::MSSQLReporter -> new(connexion => $connect);

            print "User tables: \n";
            print join("\n", @{$reporter -> get_tableNames()}), "\n\n";

DESCRIPTION
    `DBIx::MSSQLReporter' encapsulates the connection between Perl and MS SQL
    Server.

    `DBIx::MSSQLReporter' was written so that I could teach myself about MS
    SQL Server and MSDE, and as part of my Perl tutorial series.

    It should be clear from the name that this module is
    database-engine-specific. If you plan on writing code which is
    independent of any particular database, look elsewhere.

    See the URI, below, for my demos sql7Demo[23].pl, which both use this
    module.

    sql7Demo2.pl is a command-line program. sql7Demo3.pl is a CGI script.

    Lastly, note that this module has a chequered future: I may well
    re-write it to fit under the umbrella of DBIx::Easy, or someone else
    working independently may have already released such a module.

INSTALLATION
    You install `DBIx::MSSQLReporter', as you would install any perl module,
    by running these commands:

            perl Makefile.PL
            make
            make test
            make install

CONSTRUCTOR new
    The constructor takes 1 parameter and 1 value for that parameter.

    It croaks if it can't connect. Otherwise it returns an object you can
    use thus:

            my($reporter) = DBIx::MSSQLReporter -> new(connexion => $connect);
            print join("\n", @{$reporter -> get_viewNames()}), "\n\n";

METHOD do($sql)
    It croaks if it can't prepare() and execute() the given SQL.

    It returns a statment handle, which you need for things like:

            my($sth) = $reporter -> do($sql);
            $sth -> dump_results();
            $sth -> finish();

    dump_results() is built-in to DBI.

METHOD dropDB($dbName)
    It croaks if it can't drop the given database.

            $reporter -> dropDB($dbName);

METHOD dropTable($tableName)
    It croaks if it can't drop the given table.

            $reporter -> dropTable($tableName);

METHOD get_dbNames($sysDbCount)
    It returns a sorted list of user database names, all in lower case.

    $sysDbCount is optional. It defaults to 4, which means this method
    ignores the 4 system tables. See get_sysDbNames(), below.

            my($dbName) = $reporter -> get_dbNames();
            print "User databases: \n";
            print join("\n", @$dbName), "\n\n";

METHOD get_fieldNames($tableName)
    It returns a list of references to the names, types, and precisions, of
    the fields in the given table.

            my($fieldName, $fieldType, $fieldPrecision) = $reporter -> get_fieldNames($tableName);
            print join("\n", map{"Field: $$fieldName[$_]. Type: $$fieldType[$_]. Precision: $$fieldPrecision[$_]"} 0 .. $#{$fieldName}), "\n\n";

METHOD get_tableNames()
    It returns a sorted list of user table names, all in lower case. Recall,
    the DSN specified the database.

            my($tableName) = $reporter -> get_tableNames();
            print "User tables: \n";
            print join("\n", @$tableName), "\n\n";

METHOD get_viewNames()
    It returns a sorted list of user view names, all in lower case. Recall,
    the DSN specified the database.

            my($viewName) = $reporter -> get_viewNames();
            print "User views: \n";
            print join("\n", @$viewName), "\n\n";

METHOD get_sysDbNames($sysDbCount)
    It returns a sorted list of system database names, all in lower case. On
    my system, I get master, model, msDb and tempDb.

    $sysDbCount is optional. It defaults to 4, which means this method
    returns the 4 system tables. See get_dbNames(), above.

            my($sysDbName) = $reporter -> get_sysDbNames();
            print "System databases: \n";
            print join("\n", @$sysDbName), "\n\n";

METHOD get_sysTableNames()
    It returns a sorted list of system table names, all in lower case.
    Recall, the DSN specified the database.

            my($sysTableName) = $reporter -> get_sysTableNames();
            print "System tables: \n";
            print join("\n", @$sysTableName), "\n\n";

METHOD get_sysViewNames()
    It returns a sorted list of system view names, all in lower case.
    Recall, the DSN specified the database.

            my($sysViewName) = $reporter -> get_sysViewNames();
            print "System views: \n";
            print join("\n", @$sysViewName), "\n\n";

METHOD hash2Table($select, $sep, $keyRef)
    Convert a hash reference, as returned by $reporter -> select($sql), into
    an HTML table. See select(), below, for details.

            my($html) = $reporter -> hash2Table($select);

    $sep is optional. It separates the values of different rows in each
    column. It defaults to $;.

    $keyRef is optional. It is a hash reference used to specify the order of
    columns. It defaults to sorting the keys of %$select.

    If you wish to use $keyRef, prepare it thus:

            my(%key) =
            (
                    hostName        =>
                            {
                                    someData        => '',
                                    order           => 2,
                            },
                    userName        =>
                            {
                                    someData        => '',
                                    order           => 1,
                            },
            );

            my($html) = $reporter -> hash2Table($select, $;, \%key);

            The key 'order' is used to order the keys 'hostName' and 'userName', which are
            presumed to appear as keys in %$select.

            The key 'someData' is ignored.
        
METHOD select($sql, $sep)
    It croaks if it can't prepare() and execute() the given SQL.

    $sep is optional. It defaults to $;.

    It returns a reference to a hash, which hold the results of the select.

    The keys of the hash are the names of the fields, which can be used for
    column headings.

    The values of the hash are the values of the fields, which can be used
    for the column data. The values in each column are, by default,
    separated by Perl's $; variable.

            my($select) = $reporter -> select($sql);

    Warning: select() selects the whole table. Ideally we'd use
    DBIx::Recordset to page thru the table, but I had too many problems with
    various versions of DBIx::Recordset.

    If you have binary data containing $;, you *<must>* set $sep to
    something else. Of course, with binary data, there may be no 'safe'
    character (string) which does not appear in your data.

    Alternately, store your binary data in files, and put the file name or
    URI in the database.

    The hash reference can be passed straight to hash2Table for conveting
    into an HTML table. Eg:

            my($html) = $reporter -> hash2Table($select);
            print $html;

AUTHOR
    `DBIx::MSSQLReporter' was written by Ron Savage *<ron@savage.net.au>* in
    2000.

    Copyright &copy; 2000 Ron Savage.

    Source available from http://savage.net.au/Perl.html.

LICENCE
    This program is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

