target remote $CHOSEN_IP:$GDBPORT
# following is supposed to be a breakpoint for after the qr is scanned?
#b 0x13477c
continue
#find /b 0x100000, 0x95ef000, $(QRBinContentsInGDB)
# we expect 2 memory locations
x/120xb 0x88f17c5
x/120xb 0x89e93cc

# let's say we expect more than one
#while

#end