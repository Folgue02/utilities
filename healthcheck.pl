#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);

use File::Spec;
use Term::ANSIColor;

sub binary_on_path {
	my $bin_name = shift;

	my @path_dirs = split(/:/, $ENV{PATH});

	for my $path (@path_dirs) {
		my $full_path = File::Spec->catfile($path, $bin_name);
		if (-e $full_path && -x $full_path) {
			return 1;
		} 
	}

	return 0;
}


# Execute
my $first_arg = $ARGV[0];

if (defined $first_arg && $first_arg eq "--help") {
	say 'Performs a healthcheck of the environment and warns you if there';
	say 'were any problems that might intervene in the execution of the utilities.';
	exit 0;
}


if (binary_on_path('nu')) {
	say color('green') . 'NuShell is installed in the system.' . color('reset');
} else {
	say color('red') . 'NuShell is not installed in the system.' . color('reset');
}