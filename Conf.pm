package XML::Conf;

use XML::Simple;
use strict;
use vars qw($VERSION);

$VERSION = 0.01;

sub new {
    my ($class, $filename, %opts) = @_;
    my $xml;
    my $fn;
    if (ref($filename) eq 'SCALAR') {
        $xml = $$filename;
    } elsif ($filename =~ /^\s*\<.*\>\s*$/s) {
        $xml = $filename;
    } else {
        $filename = "./$filename" if ($filename !~ /^[\/\.]/ && -e "./$filename");
        open(I, $filename) || die "Could not open $filename: $!";
        $xml = join("", <I>);
        close(I);
        $fn = $filename;
    }
    my $hash = XML::Simple::XMLin($xml);
    my $case = $opts{'case'};
    my $sub = !$case ? sub {$_;} : eval "sub { $case(\$_); }";
    my $self = {'data' => $hash, 'case' => $sub, 'fn' => $fn};
    my $sig = $opts{'sig'};
    if ($sig) {
        $SIG{$sig} = sub { $self->ReadConfig; };
    }
}

sub val {
    my $self = shift;
    my $data = $self->{'data'};
    my $case = $self->{'case'};
    foreach (@_) {
        my $this = &$case($_);
        $data = $data->{$this};
    }
    $data;
}


sub setval {
    my $self = shift;
    my $data = \{$self->{'data'}};
    my $case = $self->{'case'};
    while (@_ > 1) {
        my $node = shift;
        $node = &$case($node);
        $data = \{${$data}->{$node}};
    }
    $$data = shift;
}

sub newval {
    my $self = shift;
    $self->setval(@_);
}

sub delval {
    my $self = shift;
    my $data = $self->{'data'};
    my $case = $self->{'case'};
    while (@_ > 1) {
        my $node = shift;
        $node = &$case($node);
        $data = $data->{$node};
    }
    my $node = shift;
    $node = &$case($node);
    delete $data->{$node};
}

sub ReadConfig {
    my $self = shift;
    my $fn = $self->{'fn'};
    return undef unless ($fn);
    my $new = &new(__PACKAGE__, $fn, 'case' => $self->{'case'});
    %$self = %$new;
    1;
}

sub Sections {
    my $self = shift;
    $self->Parameters(@_);
}

sub Parameters {
    my $self = shift;
    my $val = $self->val(@_);
    my $case = $self->{'case'};
    map {&$case($_);} keys %$val;
}

sub RewriteConfig {
    my $self = shift;
    my $fn = $self->{'fn'};
    die "No filename" unless ($fn);
    $self->WriteConfig($fn);
}

sub WriteConfig {
    my ($self, $name) = @_;
    my $xml = XMLout($self->{'data'}, xmldecl => 1);
    open(O, ">$name") || die "Can't rewrite $name: $!";
    print O $xml;
    close(O);
}
