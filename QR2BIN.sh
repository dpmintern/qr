#!/bin/bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

function error() {
    echo "Error: $*"
    exit 1
}

function probe() {
    which "$1" || error "$1 not present in path"
}

probe zbarimg
probe xxd
probe qrencode

test -d out && rm -rf "out"
#rm common.out.*.hex

find "in" -type f | while IFS= read -r line; do
    loute="${line%.*}"
    loute="${loute/in/out}.bin"
    outfldr=$(dirname "$loute")
    game="${outfldr//\//.}"
    mkdir -p "$outfldr"
    echo -e "${Yellow}${line} ${Color_Off}-> ${Green}${loute}${Color_Off}"
    zbarimg -1 -Sqrcode.binary "$line" --raw >"$loute" || error "on $line"
    test -z ${OUT_QR+x} && \
        qrencode -r "$loute" --strict-version -v6 -o "$loute".png #-tansiutf8
    #xxd -p "$loute" | tr -d '\n' > "$loute.hex"
    #xxd "$loute"
    #echo -e "\n\n"
    #comm -12 "$loute.hex"
    #if [ -e "common.${game}.hex" ]; then
    #    comm -12 "common.${game}.hex" "$loute.hex" > "common.${game}.hex"
    #else
    #    cp "$loute.hex" "common.${game}.hex"
    #fi
done
