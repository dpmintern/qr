#!/bin/bash

function error() {
    echo "Error $*"
    exit 1
}

function probe() {
    which "$1" || error "$1 not present in path"
}

probe zbarimg
probe xxd
probe qrencode

test -d out && rm -rf "out"

find "in" -type f | while IFS= read -r line; do
    loute="${line/in/out}.bin"
    mkdir -p "$(dirname "$loute")"
    echo "$line"
    zbarimg -1 -Sqrcode.binary "$line" --raw >"$loute" || error "on $line"
    test -z ${OUT_QR+x} && \
        qrencode -r "$loute" --strict-version -v6 -tansiutf8 #-o "$loute".png
    xxd "$loute"
    echo -e "\n\n"
done
