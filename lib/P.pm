package P;
use Dancer ':syntax';
use Util::Log;


sub manage_layout {
   if( my $layout = delete params->{layout} ) { # no point in keeping it in the params stream, will only complicate things
      my $template = Dancer::Template::Abstract->new->view( join '/', 'layouts', $layout );
      var layout => ( -r $template) ? $layout : 'main';
   } else {
      var layout => 'main';
   }
};

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

   if ( $type =~ m/(?:json|xml|yaml)/ ) {
      set serializer => $type
   }

   var type => lc($type);
};


sub display (@) {
   if ( defined vars->{type} ) {
      if ( vars->{type} eq 'data' ) {
         return template data => {data => D @_};
      }

      my $template = join '/', grep{defined} vars->{template_dir}, vars->{type};
      # switch to 'default' if we can't find that template
      unless ( -r Dancer::Template::Abstract->new->view($template)) {
         $template = join '/', grep{defined} vars->{template_dir}, 'default';
      }

      return scalar(@_) ? template $template => {data => @_} : template $template;
   }
   else {
      return [@_]; # seralize
   }
}

#---------------------------------------------------------------------------
#  ROUTES
#---------------------------------------------------------------------------

before \&manage_layout;
before \&manage_type;

any qr{.*} => \&DD ;

sub DD {
DUMP {IN => \@_};
   display( 
   { PARAM => {params},
     VARS  => vars,
     SPLAT => [splat],
     URI   => request->path,
   });
};



true;
