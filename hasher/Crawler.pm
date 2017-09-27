package Crawler;

use Mojo::Base -base;

use File::Slurp;
use Digest::SHA qw/ sha256_hex /;

has 'base_url';
has 'connections' => 10;
has 'delay';
has 'failed'      => 0;
has 'hashes'      => sub { {} };
has 'ok'          => 0;
has 'profile'     => 'web';
has 'queue'       => sub { [] };
has 'running'     => 0;
has 'running'     => 0;
has 'timeout'     => 20;

has 'ua' => sub {
    my $self = shift;

    Mojo::UserAgent->new
        ->request_timeout($self->timeout)
        ->connect_timeout($self->timeout)
        ->inactivity_timeout(5);
};

has checksum => sub {
    my $self = shift;

    sha256_hex( $self->manifest ); 
};

has manifest => sub {
    my $self = shift;
    my $hashes = $self->hashes;

    join "\n",
        map "$hashes->{$_}:$_",
        sort { $a cmp $b }
        keys %$hashes;
};



sub crawl {
    my $self = shift;

    Mojo::IOLoop::Delay->new()->steps(
        sub {
            my $delay = shift;
            $self->delay( $delay );
            $self->_enqueue;
            $self->_consume;
        }
    );
}

sub _enqueue {
    my $self = shift;
    my @files = $self->profile eq 'db' ?
        ( map { sprintf "%02x/%02x.db", ($_ / 0x100, $_ & 0xff) } 0..0xffff ) :
        read_file( "profiles/".$self->profile );

    foreach my $url ( read_file( "profiles/".$self->profile ) ) {
        chomp $url;

        push @{ $self->queue }, $url;
    }
}

sub _consume {
    my $self = shift;

    while( $self->running < $self->connections && @{ $self->queue } ) {
        my $url = shift @{ $self->queue };
        my $done = $self->delay->begin;

        my $full = $self->base_url . "/" . $url;

        $self->ua->get($full => sub { $self->_process($url, @_); $done->(); });

        $self->running( $self->running + 1 );
    }
}

sub _process {
	my ($self, $url, $ua, $tx) = @_;
    my $res = $tx->result;

    $self->running( $self->running - 1 );

    if( $res->is_success ) {
        my $hash = sha256_hex( $res->body );
        $self->hashes->{$url} = $hash;
        $self->ok( $self->ok + 1 );
    } else {
        $self->hashes->{$url} = "FAILED";
        $self->failed( $self->failed + 1 );
    }

    $self->_consume;
}


1; 

