#!/usr/bin/perl
use Errno;
use POSIX;
use Data::Dumper;
use strict;
use warnings;
use File::Spec;
use IO::Handle;

use constant OUTPUT_FILE_NAME => 'nohup.out';

my $ignore_stdin  = -t STDIN;
my $redirecting_stdout = -t STDOUT;

my $is_stdout_open = 0;
unless ( $redirecting_stdout ) {
    $is_stdout_open = defined fileno(STDERR);
}

my $redirecting_stderr = -t STDOUT;

if ( $ignore_stdin ) {
    if (! open(STDIN, '> /dev/null') ) {
        print $!;
        exit(1);
    }
}

my $output_fd = STDOUT;
if ( $redirecting_stdout || ( $redirecting_stderr && !$is_stdout_open ) ) {

    for ( OUTPUT_FILE_NAME, File::Spec->catfile($ENV{HOME}, OUTPUT_FILE_NAME) ) {

        if ( $output_fd = open(OUTPUT_FILE_NAME, '>>', OUTPUT_FILE_NAME) ) {
            chmod 0600, $output_fd;
            last;
        }
    }

    if (! $output_fd ) {
        print $!;
        exit 1;
    }
}

my $saved_stderr_fd = STDERR;
if ( $redirecting_stderr ) {

    $seved_stderr_fd = dup(STDERR);
    if ( $output_fd = open(STDERR, '>> &STDOUT') ) {
    }
}

$SIG{'HUP'} = 'IGNORE' ;

exec(@ARGV);
