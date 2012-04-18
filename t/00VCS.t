#!perl
use strict;
use Test::More tests => 9;
use Cwd;
#use Data::Dumper;
my $td = "/tmp/vcstestdir.$$";

BEGIN { use_ok( 'VCS' ) }

require Data::Dumper;
my @segments = VCS->parse_url('vcs://localhost/VCS::Cvs/file/path/?query=1');

my $dd=<<'EOF';
$VAR1 = [
          'localhost',
          'VCS::Cvs',
          '/file/path/',
          'query=1'
        ];
EOF
is(Data::Dumper::Dumper(\@segments),$dd,'Parse URL');



my $all_files = {   't/cvs_testfiles/td/dir/file,v_for_testing' => 0,
                    't/rcs_testfiles/dir/RCS/file,v_for_testing' => 0,
                    't/rcs_testfiles/dir/file'         => 0,
                    't/00VCS.t'                        => 0,
                    't/01Rcs.t'                        => 0,
                    't/01Cvs.t'                        => 0,
                  };
my $h = {}; bless $h,'VCS::Dir';
my @found_files;
my $expected_files = 6;
$expected_files++ if (-f 't/00VCS.t~');
$expected_files++ if (-f 't/01Rcs.t~');
$expected_files++ if (-f 't/01Cvs.t~');



@found_files=$h->recursive_read_dir('t');
for (@found_files) {
  if (exists($all_files->{$_})) {
    $all_files->{$_}++;
  } else {
    #warn "$_ found in test directory";
  }
}
foreach $_ (keys(%$all_files)) {
  is($all_files->{$_},1,"recursive_read_dir with no trailing slash ok for '$_'");
}
is(scalar(@found_files),$expected_files,'recursive_read_dir');





