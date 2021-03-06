# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use strict;
use warnings;
use Test::More;
use t::lib::Utils qw/save_std restore_std next_fd/;
use t::lib::Cases qw/run_test/;
use t::lib::TieLC;

use Config;
my $no_fork = $^O ne 'MSWin32' && ! $Config{d_fork};

plan skip_all => "capture needs Perl 5.8 for tied STDOUT"
  if $] < 5.008;

plan 'no_plan';

my $builder = Test::More->builder;
binmode($builder->failure_output, ':utf8') if $] >= 5.008;
binmode($builder->todo_output, ':utf8') if $] >= 5.008;

save_std(qw/stdout/);
tie *STDOUT, 't::lib::TieLC', ">&=STDOUT";
my $orig_tie = tied *STDOUT;
ok( $orig_tie, "STDOUT is tied" ); 

my $fd = next_fd;

run_test($_, 'unicode') for qw(
  capture
  capture_scalar
  capture_merged
);

if ( ! $no_fork ) {
  run_test($_, 'unicode') for qw(
    tee
    tee_scalar
    tee_merged
  );
}

is( next_fd, $fd, "no file descriptors leaked" );
is( tied *STDOUT, $orig_tie, "STDOUT is still tied" );
restore_std(qw/stdout/);

exit 0;
