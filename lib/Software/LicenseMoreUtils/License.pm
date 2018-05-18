package Software::LicenseMoreUtils::License;

use strict;
use warnings;
use 5.10.1;

use Path::Tiny;
use YAML::Tiny;
use List::Util qw/first/;
use Carp;
use Text::Template;

our $AUTOLOAD;

my %path_to_distro = (
    '/etc/debian_version' => 'debian',
);

my $distro_file = first { -e $_ } keys %path_to_distro;
my $distro = $path_to_distro{$distro_file} || 'unknown';


(my $module_file = __PACKAGE__.'.pm' ) =~ s!::!/!g;
my $yml_file = path($INC{$module_file})->parent->child("$distro-summaries.yml") ;

my $summaries = {} ;
if ($yml_file->is_file) {
    $summaries = YAML::Tiny->read($yml_file)->[0];
}

sub new {
    my ($class, $args) = @_;
    my $self = {
        license => $args->{license},
        or_later => $args->{or_later},
    };

    bless $self, $class;
}

sub summary {
    my $self = shift;

    my $later_text = $self->{or_later} ? ", or (at\nyour option) any later version" : '';

    (my $section_name = ref( $self->{license} )) =~ s/.*:://;
    my $summary = $summaries->{$section_name} // '';

    my $template = Text::Template->new(
        TYPE => 'STRING',
        DELIMITERS => [ qw({{ }}) ],
        SOURCE => $summary
    );

    return $template->fill_in(
        HASH => { or_later_clause => $later_text },
    );
}

sub debian_text {
    my $self = shift;
    carp "debian_text is deprecated, please use summary_or_text";
    return $self->summary || $self->fulltext;
}

sub summary_or_text {
    my $self = shift;
    return $self->summary || $self->fulltext;
}

sub AUTOLOAD {
    my $self = shift;
    my $lic = $self->{license};
    my ($sub) = ($AUTOLOAD =~ /(\w+)$/);
    return $lic->$sub(@_) if ($lic and $sub ne 'DESTROY');
}

1;

