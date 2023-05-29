use strict;
use warnings;
use Test::More;

use Hello::Keyword;

Hello World {
    print "It's made with keyword plugin\n";
};

# is equivalent to:
#{
#    print sprintf("Hello, %s!\n", 'World');
#    do {
#        print "It's made with keyword plugin\n"
#    };
#}

pass;

done_testing;

