package P;
use Dancer ':syntax';
use Util::Log;

sub manage_type {
   my $type = 'default'; # if cascade to allow for precidance

   # .ext => type
   if ( request->path =~ m/[.](.+)$/ ) {
      $type = $1;
      my $sans_ext = request->path;
      $sans_ext =~ s/[.]$type$//;
      request->path($sans_ext);
   }

   # ?type => type
   if ( exists params->{type} ) {
      my $p = request->{params};
      $type = delete $p->{type};
      delete request->{_query_params}->{type}; # remove it from here too
   }

   var type => $type;
};


sub display (@) {
   my $code = shift;
   my @data = map{ ref($_) eq 'CODE' ? &$_ : $_ } @_;
#   sub{ DUMP {DISP => @data} };
   return sub{ DUMP \@data }->(@data);
}

#---------------------------------------------------------------------------
#  ROUTES
#---------------------------------------------------------------------------

before \&manage_type;

any qr{.*} => display \&DD;


sub DD {
error 'DD';
   { PARAM => {params},
     VARS  => vars,
     SPLAT => [splat],
     URI   => request->path,
   }
};



true;
