package Software::LicenseMoreUtils;

use strict;
use warnings;
use 5.10.1;

use Try::Tiny;
use Carp;
use Software::LicenseMoreUtils::License;


# ABSTRACT: more little useful bits of code for licensey things

use base qw/Software::LicenseUtils/;

=method new_from_short_name
 
   my $license_object = Software::LicenseUtils->new_from_short_name({
      short_name => 'GPL-1',
      holder => 'X. Ample'
   }) ;
 
Create a new L<Software::License> object from the license specified
with C<short_name>. Known short license names are C<GPL-*>, C<LGPL-*> ,
C<Artistic> and C<Artistic-*>
C<Artistic> and C<Artistic-*>. If the short name is not known, this
method will try to create a license object with C<Software::License::> and
the specified short name (e.g. C<Software::License::MIT> with
C<< short_name => 'MIT' >> or C<Software::License::Apache_2_0> with
C<< short_name => 'Apapche-2.0' >>).
 
=cut

my %more_short_names = (
    'Apache-1.1'   => 'Software::License::Apache_1_1',
    'Apache-2'     => 'Software::License::Apache_2_0',
    'Artistic'     => 'Software::License::Artistic_1_0',
    'Artistic-1'   => 'Software::License::Artistic_1_0',
    'Artistic-2'   => 'Software::License::Artistic_2_0',
    'BSD-3-clause' => 'Software::License::BSD',
    'Expat'        => 'Software::License::MIT',
    'LGPL-2  '     => 'Software::License::LGPL_2',
    'LGPL-2+'      => 'Software::License::LGPL_2',
    'LGPL-2.1+'    => 'Software::License::LGPL_2_1',
    'GPL-1+'       => 'Software::License::GPL_1',
    'GPL-2+'       => 'Software::License::GPL_2',
    'GPL-3+'       => 'Software::License::GPL_3',
    'LGPL-2+'      => 'Software::License::LGPL_2',
    'LGPL-2.1+'    => 'Software::License::LGPL_2_1',
    'LGPL-3+'      => 'Software::License::LGPL_3_0',
    'LGPL-3.0+'    => 'Software::License::LGPL_3_0',
);

sub new_from_short_name {
    my ( $class, $arg ) = @_;
    croak "no license short name specified"
          unless defined $arg->{short_name};

    my $subclass = my $short = $arg->{short_name};
    $subclass =~ s/[\-.]/_/g;

    my $lic_obj;
    try {
        $lic_obj = SUPER::new_from_short_name($arg);
    } catch {
        my $info = $more_short_names{$short} || "Software::License::$subclass";
        my $lic_file = my $lic_class = $info;
        $lic_file =~ s!::!/!g;
        try {
            require "$lic_file.pm";
        } catch {
            Carp::croak "Unknow license with short name $short ($_)";
        } ;
        delete $arg->{short_name};
        $lic_obj = $lic_class->new( { %$arg } );
    };

    return $lic_obj;
}

sub new_license_with_summary {
    my ( $class, $arg ) = @_;
    croak "no license short name specified"
        unless defined $arg->{short_name};

    my $short = $arg->{short_name};

    my $info = $more_short_names{$short} || '';
    my $or_later = $short =~ /\+$/ ? 1 : 0;
    my $lic = $class->new_from_short_name($arg);

    my $xlic = Software::LicenseMoreUtils::License->new({
        license => $lic,
        or_later => $or_later
    });
    return $xlic;
}

1;
