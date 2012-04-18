package VCS;

my @IMPLEMENTATIONS;
my $CONTAINER_PAT = '(' . join('|', qw(VCS/Dir VCS/File VCS/Version)) . ')';

use vars qw($VERSION);
use VCS::Dir;
use VCS::File;
use VCS::Version;
use URI;

$VERSION = '0.16';

sub parse_url {
    # vcs://hostname/classname/...
    my ($class, $url) = @_;
    my $uri = URI->new($url);
    die "Non-vcs URL '$url' passed!\n" unless $uri->scheme eq 'vcs';
    my $path = $uri->path;
    $path =~ s#^/([^/]+)##;
    my $classname = $1;
    ($uri->authority, $classname, $path, $uri->query)
}

sub _class2file {
    my $class = shift;
    $class =~ s#::#/#g;
    $class .= '.pm';
    $class;
}

sub class_load {
    my ($class, $to_load) = @_;
    require(_class2file($to_load));
}

1;

__END__

=head1 NAME

VCS - (OBSOLETE, USE VCI INSTEAD) Version Control System access in Perl

=head1 SYNOPSIS

    use VCS;
    $file = VCS::File->new($ARGV[0]);
    print $file->url, ":\n";
    for $version ($file->versions) {
        print $version->version,
              ' was checked in by ',
              $version->author,
              "\n";
    }

=head1 DESCRIPTION

B<NOTE:> This module has been unmaintained since 2004. It is recommended that
you use the L<VCI> module instead, which is currently maintained, supports
many more VCSes, and has more features.

C<VCS> is an API for abstracting access to all version control systems
from Perl code. This is achieved in a similar fashion to the C<DBI>
suite of modules. There are "container" classes, C<VCS::Dir>,
C<VCS::File>, and C<VCS::Version>, and "implementation" classes, such
as C<VCS::Cvs::Dir>, C<VCS::Cvs::File>, and C<VCS::Cvs::Version>, which
are subclasses of their respective "container" classes.

The container classes are instantiated with URLs. There is a URL scheme
for entities under version control. The format is as follows:

    vcs://localhost/VCS::Cvs/fs/path/?query=1

The "query" part is ignored for now. The path must be an absolute path,
meaningful to the given class. The class is an implementation class,
such as C<VCS::Cvs>.

The "container" classes work as follows: when the C<new> method of a
container class is called, it will parse the given URL, using the
C<VCS-E<gt>parse_url> method. It will then call the C<new> of the
implementation's appropriate container subclass, and return the
result. For example,

    VCS::Version->new('vcs://localhost/VCS::Cvs/fs/path/file/1.2');

will return a C<VCS::Cvs::Version>.

An implementation class is recognised as follows: its name starts with
C<VCS::>, and C<require "VCS/Classname.pm"> will load the appropriate
implementation classes corresponding to the container classes.

=head1 VCS METHODS

=head2 VCS-E<gt>parse_url

This returns a four-element list:

    ($hostname, $classname, $path, $query)

For example,

    VCS->parse_url('vcs://localhost/VCS::Cvs/fs/path/file/1.2');

will return

    (
        'localhost',
        'VCS::Cvs',
        '/fs/path/file/1.2',
        ''
    )

This is mostly intended for use by the container classes, and its
interface is subject to change.

=head2 VCS-E<gt>class_load

This loads its given implementation class.

This is mostly intended for use by the container classes, and its
interface is subject to change.

=head1 VCS::* METHODS

Please refer to the documentation for L<VCS::Dir>, L<VCS::File>,
and L<VCS::Version>; as well as the implementation specific documentation
as in L<VCS::Cvs>, L<VCS::Rcs>.

=head1 AVAILABILITY

Much of this information is incorrect, the current up to date
version of VCS is held on a different CVS server now, i'm going
to make things a little more public and then update the below
information - thanks for your patience.

VCS.pm and its friends are available from CPAN.  There is a web page
at:

    http://www.astray.com/VCS/

as well as a sourceforge project page at:

    http://sourceforge.net/projects/vcs/

=head1 MAILING LIST

There is currently a mailing list about VCS. Go to the following
webpage to subscribe to it:

    http://www.astray.com/mailman/listinfo/vcs

There is a web archive of the mailing list at:

    http://www.astray.com/pipermail/vcs/

General queries should be made directly to the mailing list.

=head1 AUTHORS

Greg McCarroll <greg@mccarroll.org.uk>
Leon Brocard

=head1 KUDOS

Thanks to the following for patches,

    Richard Clamp
    Pierre Denis
    Slaven Rezic


=head1 COPYRIGHT

Copyright (c) 1998-2003 Leon Brocard & Greg McCarroll. All rights
reserved. This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<VCI>

L<VCS::Cvs>, L<VCS::Dir>, L<VCS::File>, L<VCS::Rcs>, L<VCS::Version>.
