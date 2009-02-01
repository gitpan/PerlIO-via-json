use strict;
use warnings;

use Test::More tests => 13;
use PerlIO::via::json;

chdir 't' if -d 't';

my $xmlfile = 'test-write.xml';

my $json = q({"test":{"array":{"@perl":"awesome","@hidden":"secret","item":[{"@index":"0"},{"@index":"1"},{"@index":"2"}]},"private":{"@some":"value"},"empty":{"@a":"b","inner":{"@c":"d"}},"data":{"$t":"some test text","@attr1":"test"},"censored":{"@foo":"secret"}},"@encoding":"UTF-8","@version":"1.0"});

# open normally
{
    # write json
    ok(open(my $out, '>', $xmlfile), "open > $xmlfile");
    ok((print$out $json), "print > $xmlfile");
    ok(close($out), "close > $xmlfile");

    # read it back
    ok(open(my $in, $xmlfile), "open < $xmlfile");
    local $/;
    is(readline($in), $json, "JSON unconverted");
    ok(close($in), "close < $xmlfile");

    # just leave $xmlfile there
}

# open via json
{
    # write json
    ok(open(my $out, '>:via(json)', $xmlfile), "open >:via(json) $xmlfile");
    ok((print $out $json), "print >:via(json) $xmlfile");
    ok(close($out), "close <:via(json) $xmlfile");

    # read it back
    ok(open(my $in, $xmlfile), "open < $xmlfile");
    local $/;
    # (I leave it up to XML::XML2JSON to fully test conversion)
    like(readline($in), qr{xml version}, "JSON converted");
    ok(close($in), "close < $xmlfile");
}

ok(unlink($xmlfile), "remove $xmlfile");
