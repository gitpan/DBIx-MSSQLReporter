use Module::Build;

Module::Build -> new
(
	module_name		=> 'DBIx::MSSQLReporter',
	license			=> 'artistic',
	dist_author		=> 'Ron Savage <ron@savage.net.au>',
	build_requires	=>
	{
		Test::More	=> 0,
		Test::Pod	=> 0,
	},
	requires		=>
	{
		Carp		=> 0,
		DBD::ADO	=> 2.91,
		DBI			=> 1.42,
		Win32::OLE	=> 0.16,
	},
) -> create_build_script();