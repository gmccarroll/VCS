#!/usr/local/bin/perl

# standard perl modules to assist with .PL extraction
use Config;
use File::Basename qw(&basename &dirname);
use Cwd;

my $origdir = cwd();
chdir dirname($0);
my $name = basename($0, '.PL');
   $name .= '.com' if $^O eq 'VMS';
   $name .= '.bat' if $^O eq 'MSWin32';
open EXE ,">$name" or die "Cannot create $name: $!";
print "Extracting $name (with variable substitutions)\n";
print EXE << "!GROK!THIS!";
$Config{'startperl'}
!GROK!THIS!
if ($^O eq 'VMS') {
print EXE <<'!NO!SUBS!';
#!/perl
!NO!SUBS!
}
print EXE << '!NO!SUBS!';

$| = 1;

#use FindBin;
#use lib "$FindBin::Bin/../";
use VCS;

if (scalar(@ARGV) == 0) {
    print << "EOUSAGE";
Usage:

    diff-hist file [file...]
EOUSAGE
    exit;
}


foreach my $arg (@ARGV) {
    my $file = VCS::File->new($arg);
    my @versions = $file->versions;
    my @diff_pairs;
    for (my $count = @versions - 1; $count > 0; $count--) {
        push @diff_pairs, [ $versions[$count - 1], $versions[$count] ];
    }
    map {
        my $old = $_->[0];
        my $new = $_->[1];
        print
            '*** Changes from version ',
            $old->version,
            ' to version ',
            $new->version,
            ' (',
            $new->date,
            ")\n",
            'What: ', $new->path, "\n",
            'Version: ', $new->version, "\n",
            'When: ', $new->date, "\n",
            'Who: ', $new->author, "\n",
            'Tags: ', (join "\n      ", $new->tags), "\n",
            'Why: ', (join "\n     ", $new->reason), "\n",
            $old->diff($new)
    } @diff_pairs;
}

__END__

=head1 NAME

diff-hist - view revision history of file under version control

=head1 SYNOPSIS

diff-hist file [file...]

=head1 DESCRIPTION

For each file specified, the differences (in diff -u2 format) are shown
between each successive version back to the first, in reverse
chronological order.

=head1 SEE ALSO

L<VCS>.

=cut
!NO!SUBS!
