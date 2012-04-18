#!perl
use strict;
use Test::More;

BEGIN {
  my $res = system('cvs --version');
  if ($res == -1) {
    plan skip_all => 'All test have been skipped as the cvs binary is not on your path';
  } else {
    plan tests => 19;
  }
}

use Cwd;
use File::Copy qw(cp);
my $td = "/tmp/vcstestdir.$$";

my $distribution = cwd();
my $repository = "$td/repository";
my $sandbox = "$td/sandbox";
my $base_url = "vcs://localhost/VCS::Cvs$sandbox/td";


BEGIN { use_ok('VCS') }
BEGIN { use_ok('VCS::File') }
BEGIN { use_ok('VCS::Dir') }

$ENV{CVSROOT} = $repository;

if (!(-d '/tmp'))                 { mkdir ('/tmp');               }
if (!(-d $td))                    { mkdir ($td);                  }
if (!(-d $sandbox))               { mkdir($sandbox);              }
if (!(-d $repository))            { mkdir($repository);           }
if (!(-d $repository.'/td/'))     { mkdir($repository.'/td');     }
if (!(-d $repository.'/td/dir/')) { mkdir($repository.'/td/dir'); }

system <<EOF;
cd $repository
cvs init
EOF

cp($distribution.'/t/cvs_testfiles/td/dir/file,v_for_testing',$repository.'/td/dir/file,v');

system <<EOF;
cd $sandbox
cvs -Q co td
cd td/dir
cvs -Q tag mytag1 file
cvs -Q tag mytag2 file
cd ../..
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

my $olddate = '2001/11/13 04:10:29';
my $newdate = '2001-11-13 04:10:29 +0000';
my $testdate;
$testdate = $olddate;
ok($testdate eq '2001/11/13 04:10:29' || $testdate eq '2001-11-13 04:10:29 +0000','date test test');
$testdate = $newdate;
ok($testdate eq '2001/11/13 04:10:29' || $testdate eq '2001-11-13 04:10:29 +0000','date test test');
$testdate = $new->date();
ok($testdate eq '2001/11/13 04:10:29' || $testdate eq '2001-11-13 04:10:29 +0000','date');


is($new->author(),'user','author');

my $d = VCS::Dir->new("$base_url/dir");
ok (defined($d),'Dir');


my $th = $d->tags();
#warn("\n",Dumper($th),"\n");
ok (exists $th->{'mytag1'});
ok (exists $th->{'mytag1'}->{$sandbox.'/td/dir/file'});
is($th->{'mytag1'}->{$sandbox.'/td/dir/file'},'1.2');

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
