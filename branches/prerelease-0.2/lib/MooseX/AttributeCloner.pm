#############
# Created By: setitesuk@gmail.com
# Created On: 2009-11-03
# Last Updated: 2009-11-09

package MooseX::AttributeCloner;
use Moose::Role;
use Carp qw{carp cluck croak confess};
use English qw{-no_match_vars};
use Readonly;

use JSON;

our $VERSION = 0.2;

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
    confess $EVAL_ERROR;
  };
  $self->_hash_of_attribute_values($arg_refs);
  return $package->new($arg_refs);
}

=head2 attributes_as_json

returns all the built attributes that are not objects as a JSON string

  my $sAttributesAsJSON = $class->attributes_as_json();

=head2 attributes_as_escaped_json

as attributes_as_json, except it is an escaped JSON string, so that this could be used on a command line

  my $sAttributesAsEscapedJSON = $class->attributes_as_escaped_json();

This uses JSON to generate the string, removing any objects before stringifying, and then parses it through a regex to generate a string with escaped characters
Note, because objects are removed, arrays will remain the correct length, but have null in them
=cut

sub attributes_as_escaped_json {
  my ($self) = @_;
  my $json = $self->attributes_as_json();
  $json =~ s{([^A-Za-z0-9_-])}{\\$1}gmxs;
  return $json;
}

sub attributes_as_json {
  my ($self) = @_;

  my $attributes = $self->_hash_of_attribute_values();
  # remove any objects from the hash
  $self->_traverse_hash($attributes);
  my $json = to_json($attributes);
  return $json;
}

###############
# private methods


# a hash_ref of attribute values from $self, where built
# either acts on a provided hash_ref, or will return a new one
sub _hash_of_attribute_values {
  my ($self, $arg_refs) = @_;
  $arg_refs ||= {};

  my @attributes = $self->meta->get_all_attributes();
  foreach my $attr (@attributes) {
    my $reader   = $attr->{reader};
    my $init_arg = $attr->{init_arg};

    next if (!$reader); # if there is no reader method, then we can't read the attribute value, so skip

    # if lazy_build, then will only propagate data if it is built, saving any expensive build routines
    # obviously, this has the effect that you may need to do it twice, or force a build before the cloning of data
    if ($attr->{predicate}) {
      my $pred = $attr->{predicate};
      next if !$self->$pred();
    }
    if (!exists$arg_refs->{$init_arg} && defined $self->$reader()) {
      $arg_refs->{$init_arg} = $self->$reader();
    }
  }

  return $arg_refs;
}

# remove any objects from a hash
sub _traverse_hash {
  my ($self, $hash) = @_;
  my @keys_to_delete;
  foreach my $key (keys %{$hash}) {
    next if (!ref $hash->{$key});
    if (ref$hash->{$key} eq q{HASH}) {
      $self->_traverse_hash($hash->{$key});
      next;
    }
    if (ref$hash->{$key} eq q{ARRAY}) {
      $hash->{$key} = $self->_traverse_array($hash->{$key});
      next;
    }
    push @keys_to_delete, $key;
  }
  foreach my $key (@keys_to_delete) {
    delete $hash->{$key};
  }
  return $hash;
}

# remove any objects from an array
sub _traverse_array {
  my ($self, $array) = @_;
  my @wanted_items;
  foreach my $item (@{$array}) {
    if (!ref $item) {
      push @wanted_items, $item;
      next;
    }
    if (ref$item eq q{HASH}) {
      $self->_traverse_hash($item);
      push @wanted_items, $item;
      next;
    }
    if (ref$item eq q{ARRAY}) {
      $item = $self->_traverse_array($item);
      push @wanted_items, $item;
      next;
    }
    push @wanted_items, undef;
  }
  return \@wanted_items;
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

=item JSON

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
