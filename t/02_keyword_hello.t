use strict;
use warnings;
use Test::More;

use Hello::Keyword;

keyword_hello Hoge {
    print "Hello, Hoge!\n";
};

pass;

done_testing;

