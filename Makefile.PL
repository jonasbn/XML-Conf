use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'XML::Conf',
    'VERSION_FROM' => 'Conf.pm', # finds $VERSION
    'PREREQ_PM' => {'XML::Simple' => 1.04},
);
