# Buffer Overflow and Returning to a Function

This is a brief demo of a buffer overflow on a compiled program that has no canaries (that's to come in a different project!). For this binary, ASLE is not turned off, and we are assuming that this program has an uncalled function that does in fact do a system call on /bin/sh, and that there is a function we can exploit in the program. (More details in the comments of vulnerable.c)

In this situation we assume that we either built the program ourselves and have sudo privileges to run it (if that were the case we would've just spawned a shell ourselves but that's no fun), or we were given this program by our IT department to do our work, but it turns out that they wrote a vulnerability that we exploited to elevate our privileges (which is more plausible).

The program is just designed to open a socket, listen for a message, read it into a buffer, print it, copy it to a smaller buffer, and close the connection. The problem lies on the fact that in the aptly named "vulnearble_function", the message is copied into a buffer that is smaller ### AND is copied with the function "strcpy":

'''C
void vulnerable_function(char* string) {
    //this is the vulnerable function we are going to exploit. We will write
    //more than 100 characters into string and overflow the buffer. This 
    //happens because strcpy does not keep track of how many bytes it copies, 
    //and continues to copy until NULL is reached.
    //
    //Here the 256 byte buffer is copied into the smaller 100 byte buffer
    char smallbuffer[100];
    strcpy(smallbuffer, string);
}
'''

The program is compiled with:

### gcc -m32 vulnerable.c -fno-stack-protector -o vulnerable

which 