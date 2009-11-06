use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More 'no_plan';#tests => ;
use Test::Exception;
use lib qw{t/lib};

BEGIN {
  use_ok(q{TestAttributeCloner});
}

{
  my $object_to_clone;
  lives_ok { $object_to_clone = TestAttributeCloner->new(); } q{$object_to_clone created ok};
  isa_ok($object_to_clone, q{TestAttributeCloner}, q{$object_to_clone});
  my $cloned_object;
  lives_ok { $cloned_object = $object_to_clone->new_with_cloned_attributes(q{TestNewAttributeCloner}); } q{new_with_cloned_attributes ran ok};
  isa_ok($cloned_object, q{TestNewAttributeCloner}, q{$cloned_object});
}
1;