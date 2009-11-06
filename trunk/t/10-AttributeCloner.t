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
  lives_ok { $object_to_clone = TestAttributeCloner->new({
    attr1 => q{test1},
    attr2 => q{test2},
    attr3 => q{test3},
    attr4 => q{test4},
    attr5 => q{test5},
    attr6 => q{test6},
    attr7 => q{test7},
  }); } q{$object_to_clone created ok};
  isa_ok($object_to_clone, q{TestAttributeCloner}, q{$object_to_clone});
  my $cloned_object;
  lives_ok { $cloned_object = $object_to_clone->new_with_cloned_attributes(q{TestNewAttributeCloner}); } q{new_with_cloned_attributes ran ok};
  isa_ok($cloned_object, q{TestNewAttributeCloner}, q{$cloned_object});
  is($cloned_object->attr1(), q{test1},q{attr1 value passed through ok});
}
{
  my $object_to_clone;
  lives_ok { $object_to_clone = TestAttributeCloner->new({
    attr2 => q{test2},
    attr6 => q{test6},
    attr7 => q{test7},
  }); } q{$object_to_clone created ok};
  my $cloned_object;
  lives_ok { $cloned_object = $object_to_clone->new_with_cloned_attributes(q{TestNewAttributeCloner},{attr8 => q{test8}}); } q{new_with_cloned_attributes ran ok};
  is($cloned_object->attr1(), undef, q{attr1 value passed through ok - now undef});
  is($cloned_object->attr8(), q{test8}, q{attr8 value passed through ok from the arg_refs provided});

}
1;