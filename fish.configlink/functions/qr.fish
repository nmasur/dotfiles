function qr
    qrencode $argv[1] -o /tmp/qr.png | open /tmp/qr.png
end
