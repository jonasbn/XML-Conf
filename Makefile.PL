use ExtUtils::MakeMaker;

# $Id: Makefile.PL,v 1.5 2003/07/21 14:32:43 jonasbn Exp $

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	=> 'XML::Conf',
    'VERSION_FROM' => 'lib/XML/Conf.pm', # finds $VERSION
    'PREREQ_PM' => {
		'XML::Simple'   => 1.04,
		'Tie::Hash'     => 0,
		'Tie::Tools'    => 0,
		'Test::More'    => 0,
		'Test::Harness' => 0,
		'Data::Dumper'  => 0,
		'Carp'          => 0,
	},
);
