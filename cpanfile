requires 'perl', '5.008001';

on configure => sub {
    requires 'Devel::PPPort', '3.68';
    requires 'Module::Build::XSUtil', '0.19';
    requires 'XS::Parse::Keyword::Builder', '0.33';
    requires 'XS::Parse::Sublike::Builder', '0.17';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
};

