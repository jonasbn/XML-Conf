package XML::Conf;

use XML::Simple;
use strict;
use vars qw($VERSION @ISA);
use Tie::DeepTied;
use Tie::Hash;

$VERSION = 0.02;

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
    my $hash = XML::Simple::XMLin($xml) || return undef;
    my $case = $opts{'case'};
    $hash = &trans($hash, eval "sub { $case(\$_);} ") if ($case);
    my $self = {'data' => $hash, 'case' => $case, 'fn' => $fn};
    my $sig = $opts{'sig'};
    if ($sig) {
        $SIG{$sig} = sub { $self->ReadConfig; };
    }
    bless $self, $class;
}

sub trans {
    my ($tree, $case) = @_;
    return $tree unless (UNIVERSAL::isa($tree, 'HASH'));
    my %hash;
    foreach (keys %$tree) {
        $hash{&$case($_)} = &trans($tree->{$_}, $case);
    }
    \%hash;
}

sub val {
    my $self = shift;
    my $data = $self->{'data'};

    foreach (@_) {
        $data = $data->{$_};
    }
    wantarray ? split("\n", $data) : $data;
}


sub setval {
    my $self = shift;
    my $data = \$self->{'data'};
    while (@_ > 1) {
        $data = \($$data->{shift()});
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
    while (@_ > 1) {
        $data = $data->{shift()};
    }
    delete $data->{shift()};
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

sub TIEHASH {
    my $class = shift;
    $class->new(@_);
}

sub FETCH {
    my ($self, $key) = @_;
    my $val = $self->val($key);
    if (UNIVERSAL::isa($val, 'HASH') && !tied(%$val)) {
        my %h = %$val;
        tie %$val, 'Tie::StdHash', $self, $key;
        %$val = %h;
        tie %$val, 'Tie::DeepTied', $self, $key;
    }
    $val;
}

sub STORE {
    my ($self, $key, $val) = @_;
    $self->setval($key, $val);
}

sub DELETE {
    my ($self, $key) = @_;
    $self->delval($key);
}

sub CLEAR {
    my $self = shift;
    $self->{'data'} = {};
}

sub EXISTS {
    my ($self, $key) = @_;
    exists $self->{'data'}->{$key};
}

sub FIRSTKEY {
    my $self = shift;
    keys %{$self->{'data'}};
    each %{$self->{'data'}};
}

sub NEXTKEY {
    my $self = shift;
    each %{$self->{'data'}};
}

1;

__END__
