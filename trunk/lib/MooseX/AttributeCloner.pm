#############
# Created By: setitesuk@gmail.com
# Created On: 2009-11-03

package MooseX::AttributeCloner;
use Moose::Role;
use Carp;
use English qw{-no_match_vars};
use Readonly;
Readonly::Scalar our $VERSION => do { my ($r) = q$LastChangedRevision: 5210 $ =~ /(\d+)/mxs; $r; };

=head1 NAME

MooseX::AttributeCloner

=head1 VERSION

$LastChangedRevision$

=head1 SYNOPSIS

  package My::Class;
  use Moose;
  with qw{MooseX::AttributeCloner};

  my $NewClassObject = $self->new_with_cloned_attributes(q{New::Class}, {});
  1;

=head1 DESCRIPTION

The purpose of this Role is to take all the attributes which have values in the current class,
and populate them directly into a new class object. The purpose of which is that if you have data
inputted on the command line that needs to propagate through to later class objects, you shouldn't
need to do the following

  my $oNewClass = New::Class->new({
    attr1 => $self->attr1,
    attr2 => $self->attr2,
    ...
  });

Which is going to get, quite frankly, tedious in the extreme. Particularly when you have more 2 class
objects in your chain.

=head1 SUBROUTINES/METHODS

=head2 new_with_cloned_attributes

This takes a package name as the first argument, plus an optional additional $arg_refs hash. It will
return a class object of the package populated with any matching attribute data from the current object,
plus anything in the $arg_refs hash.

=cut

sub new_with_cloned_attributes {
  my ($self, $package, $arg_refs) = @_;

  $arg_refs ||= {};

  eval {
    my $package_file_name = $package;
    $package_file_name =~ s{::}{/}gxms;
    if ($package_file_name !~ /[.]pm\z/xms) {
      $package_file_name .= q{.pm};
    }
    require $package_file_name;
  } or do {
    croak $EVAL_ERROR;
  };
  
  my $class_object = $package->new($arg_refs);
  return $class_object;
}

1;
__END__

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Moose::Role

=item Carp

=item English -no_match_vars

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

This is more than likely to have bugs in it. Please contact me with any you find (or submit to RT)
and any patches.

=head1 AUTHOR

setitesuk

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk@gmail.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
