use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'Interface to MS SQL Server and MS Data Engine',
    ) : (),
	clean			=>
	{
		FILES		=> 'blib/* Makefile MANIFEST DBIx-MSSQLReporter-*'
	},
	dist			=>
	{
		COMPRESS	=> 'gzip',
		SUFFIX		=> 'gz'
	},
	DISTNAME		=> 'DBIx-MSSQLReporter',
	NAME			=> 'DBIx::MSSQLReporter',
	PL_FILES		=> {},
	PREREQ_PM		=>
	{
		Carp		=> 0,
		DBD::ADO	=> 2.91,
		DBI			=> 1.42,
		Test::More	=> 0,
		Test::Pod	=> 0,
		Win32::OLE	=> 0.16,
	},
	VERSION_FROM	=> 'lib/DBIx/MSSQLReporter.pm'
);
