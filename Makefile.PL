use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (rpsavage@ozemail.com.au)',
		'ABSTRACT' => 'Interface to MS SQL Server and MS Data Engine',
    ) : (),
'clean'				=>
	{
	'FILES'			=> 'blib/* Makefile MANIFEST DBIx-MSSQLReporter-*'
	},
'dist'				=>
	{
	'COMPRESS'		=> 'gzip',
	'SUFFIX'		=> 'gz'
	},
'DISTNAME'			=> 'DBIx-MSSQLReporter',
'NAME'				=> 'DBIx::MSSQLReporter',
'PM'				=>
	{
	'MSSQLReporter.pm'	=> '$(INST_LIBDIR)/MSSQLReporter.pm',
	},
'PREREQ_PM'			=>
	{
		DBI			=> '1.13',
	},
'VERSION_FROM'		=> 'MSSQLReporter.pm'
);
