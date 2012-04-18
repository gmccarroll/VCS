#!perl
use strict;
use Test::More;
BEGIN {
  unless (-e 't/rcs_testfiles/dir/RCS/file,v_for_testing') {
    plan skip_all => 'All tests have been skipped as file,v_for_testing does not exist (not checked out by cvs?)';
  }
  my $res = system('co -V');
  if ($res == -1) {
    plan skip_all => 'All test have been skipped as the co binary (part of RCS)is not on your path';
  } else {
    plan tests => 14;
  }
}


use File::Copy qw(cp);
use Cwd;
my $td = "/tmp/vcstestdir.$$";

my $distribution = cwd();
my $base_url = "vcs://localhost/VCS::Rcs$td";

BEGIN { use_ok('VCS') }
BEGIN { use_ok('VCS::File') }
BEGIN { use_ok('VCS::Dir') }

if (!(-d '/tmp'))            { mkdir('/tmp');         }
if (!(-d $td))               { mkdir($td);            }
if (!(-d $td.'/dir'))        { mkdir($td.'/dir');     }
if (!(-d $td.'/dir/RCS'))    { mkdir($td.'/dir/RCS'); }

cp('t/rcs_testfiles/dir/file',$td.'/dir');
cp('t/rcs_testfiles/dir/RCS/file,v_for_testing',$td.'/dir/RCS/file,v');

system <<EOF;
cd $td/dir
rcs -q -nmytag1: file
rcs -q -nmytag2: file
EOF

my $f = VCS::File->new("$base_url/dir/file");
ok(defined $f,'VCS::File->new');

my $h = $f->tags();
is($h->{mytag1},'1.2','file tags 1');
is($h->{mytag2},'1.2','file tags 2');

my @versions = $f->versions;
ok(scalar(@versions),'versions');
my ($old, $new) = @versions;
is($old->version(),'1.1','old version');
is($new->version(),'1.2','new version');
is($new->date(),'2001/11/13 04:10:29','date');
is($new->author(),'user','author');

my $d = VCS::Dir->new("$base_url/dir");
ok (defined($d),'Dir');

my @c = $d->content;
is(scalar(@c),1,'content');
is($c[0]->url(),"$base_url/dir/file",'cotent url');

if ($^O eq 'MSWin32') {
  print STDERR "\nHmm, you appear to be using a Windows operating system and I don't have a\n",
                 "handy Win32 Perl system to test something like del /S against, and I'm\n",
                 "probably not brave enough to put it in even if I had such a system, so I'm\n",
                 " afraid you will have to clean up '$td' on your own. To get rid of this message\n",
                 "in future tests of VCS.pm please install a proper operating system\n",
                 "                                                                  - Greg\n";
} else {
system <<EOF;
[ -d $td ] && rm -rf $td
EOF
}

