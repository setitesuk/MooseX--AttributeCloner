use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More 'no_plan';#tests => ;
use Test::Exception;
use lib qw{t/lib};
use JSON;

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
  my $arg_refs = { attr8 => q{test8} };
  lives_ok { $cloned_object = $object_to_clone->new_with_cloned_attributes(q{TestNewAttributeCloner},$arg_refs); } q{new_with_cloned_attributes ran ok};
  ok(!$cloned_object->has_attr1(), q{no attr1 value, so nothing passed through and not set});
  is($cloned_object->attr8(), q{test8}, q{attr8 value passed through ok from the arg_refs provided});


  my $hash_ref = { key1 => q{val1}, key2 => q{val2}, key_obj => $cloned_object};
  my $array_ref = [1,2,3,$hash_ref,$object_to_clone];
  my $ref_test = TestAttributeCloner->new({
    attr1 => q{test1},
    attr2 => q{0},
    object_attr => $object_to_clone,
    hash_attr => $hash_ref,
    array_attr => $array_ref,
  });
  my $cloned_ref_test = $ref_test->new_with_cloned_attributes(q{TestNewAttributeCloner});
  is($cloned_ref_test->attr1(), q{test1}, q{attr1 is correct});
  is($cloned_ref_test->object_attr(), $object_to_clone, q{object_attr is correct});
  is($cloned_ref_test->hash_attr(), $hash_ref, q{hash_attr is correct});
  is($cloned_ref_test->array_attr(), $array_ref, q{array_ref is correct});
  my $hash_key_object = $cloned_ref_test->hash_attr()->{key_obj};
  is($cloned_ref_test->hash_attr()->{key_obj}, $cloned_object, q{hash maintained});
  isa_ok($hash_key_object, q{TestNewAttributeCloner}, q{$cloned_ref_test->hash_attr()->{key_obj}});
  ok(ref$hash_key_object, q{$cloned_ref_test->hash_attr() is a ref});
  is($cloned_ref_test->array_attr()->[3],$hash_ref, q{array maintained});

  

  my $json_string = q[{"hash_attr":{"key2":"val2","key1":"val1"},"attr2":"0","attr1":"test1","array_attr":[1,2,3,{"key2":"val2","key1":"val1"},null]}];
  my $json_test_hash = from_json($json_string);

  is_deeply(from_json($ref_test->attributes_as_json()), $json_test_hash, q{json string is ok});

  my $escaped_json_string = $ref_test->attributes_as_escaped_json();
  $escaped_json_string =~ s{\\}{}gxms; # remove escape characters
  
  is_deeply(from_json($escaped_json_string), $json_test_hash, q{escaped json string ok});
  is($ref_test->attributes_as_command_options(), q{--hash_attr key2=val2 --hash_attr key1=val1 --attr2 0 --attr1 test1 --array_attr 1 --array_attr 2 --array_attr 3}, q{default attributes_as_command_options ok});
  is($ref_test->attributes_as_command_options({equal => 1, quotes => 1, single_dash => 1}), q{-hash_attr "key2=val2" -hash_attr "key1=val1" -attr2="0" -attr1="test1" -array_attr="1" -array_attr="2" -array_attr="3"}, q{attributes_as_command_options with options on ok});
}
1;