package P;
use Dancer ':syntax';

# ABSTRACT: test app

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

true;
