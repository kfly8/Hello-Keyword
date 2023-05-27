use strict;
use Test::More;

use Hello::Keyword;

is(Hello::Keyword::hello(), 'Hello, world!');

done_testing;

