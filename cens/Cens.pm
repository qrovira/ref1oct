package Cens;

use strict;
use warnings;
use 5.014;

use File::Slurp;
use Digest::SHA qw/ sha256_hex /;
use Digest::MD5 qw/ md5 /;
use Crypt::Rijndael;

our $DB = './db';

sub fetch {
    my ($dni, $birth_date, $postcode) = @_;
    my $key = substr($dni, -6) . $birth_date . $postcode;
    my $pass = sha256_hex($key);
    $pass = sha256_hex($pass) foreach( 1.. 1714 ); # Bon cop de falç, cabró
    my $lookup = sha256_hex($pass);
    my $path = substr($lookup,0,2);
    my $file = substr($lookup,2,2);
    my $start = substr($lookup,4);

    if( read_file("$DB/$path/$file.db") =~ m#^$start(.*)$#m ) {
        my $encrypted = $1;
        my ($key, $iv) = ebtk( $pass );
        my $cipher = Crypt::Rijndael->new( $key, Crypt::Rijndael::MODE_CBC() );
        $cipher->set_iv($iv);
        my $decrypted = $cipher->decrypt(pack 'H*', $encrypted);
        $decrypted =~ s/#[^#]+$//;
        my (@row) = split '#', $decrypted;
        return {
            adreca1   => $row[0],
            adreca2   => $row[1],
            poblacio  => $row[2],
            districte => $row[3],
            seccio    => $row[4],
            mesa      => $row[5],
        };
    }

    return undef;
}

sub ebtk {
    my $pass = shift;
    my $tmp = md5( $pass );
    my $key = $tmp;
    $tmp = md5( $tmp . $pass );
    $key .= $tmp;
    my $iv = md5( $tmp . $pass );

    return ($key, $iv);
}

1; 

