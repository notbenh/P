#!/usr/bin/env perl
use Plack::Handler::FCGI;

my $app = do('/home/benh/git/P2/P/app.psgi');
my $server = Plack::Handler::FCGI->new(nproc  => 5, detach => 1);
$server->run($app);
