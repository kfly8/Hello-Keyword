use v5.36;
use Test::More;

use Hello::Keyword;

keyword_hello Hoge {
    say "Hello, Hoge!";
};

pass;

done_testing;

