use ExtUtils::MakeMaker;

# $Id: Makefile.PL,v 1.6 2003/12/10 23:03:09 jonasbn Exp $

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	=> 'XML::Conf',
    'VERSION_FROM' => 'lib/XML/Conf.pm', # finds $VERSION
    'PREREQ_PM' => {
		'XML::Simple'   => 1.04,
		'Tie::Hash'     => 0,
		'Tie::Tools'    => 1.05,
		'Tie::DeepTied' => 0,
		'Test::More'    => 0,
		'Test::Harness' => 0,
		'Data::Dumper'  => 0,
		'Carp'          => 0,
	},
);
