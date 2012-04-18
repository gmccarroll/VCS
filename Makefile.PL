use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $exe_type = '';
my $EXE_FILES = [qw(examples/diff-hist)];
if ($^O eq 'VMS') {
   $EXE_FILES = [qw([.examples]diff-hist.com)];
   $exe_type = '.com';
}
if ($^O eq 'os2' || $^O eq 'MSWin32') {
   $EXE_FILES = [qw(examples/diff-hist.bat)];
   $exe_type = '.bat';
}
my $PL_FILES = {('examples/diff-hist.PL' => "examples/diff-hist$exe_type")};

WriteMakefile(
    'NAME'	    => 'VCS',
    'ABSTRACT_FROM' => 'VCS.pm', # finds =head1 NAME line for PPD
    'VERSION_FROM'  => 'VCS.pm', # finds $VERSION
    'PREREQ_PM'     => { 'URI' => 0 },
    'PL_FILES'      => $PL_FILES,
    'EXE_FILES'     => $EXE_FILES,
    'dist'          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
