#!/usr/local/bin/fish

function tickers --description "Stock and money tickers"
    abbr -a tk 'tickrs -s'
    abbr -a vt 'tickrs -s vt'
    abbr -a vti 'tickrs -s vti'
    abbr -a vxus 'tickrs -s vxus'
    abbr -a btc 'rates btc usd'
    abbr -a ada 'rates ada usd'
    abbr -a eth 'rates eth usd'
end
