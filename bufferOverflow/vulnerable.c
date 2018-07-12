//Brief demo on a buffer overflow for a compiled program that has no canaries.
//ASLR still turned on, but making our own back door in a system where we 
//can't sudo su root, but we can sudo SOME executables.
//
//
//
//To compile (32-bit to make it simple for now, and we disable the canary):
//gcc -m32 vulnerable.c -fno-stack-protector -o vulnerable
//
//This program runs as ./vulnerable <port number>
//
//When run it will open a listener on <port number> and wait for a connection
//
//
//
//
//After receiving information it will be copied into a buffer. The
//vulnerability lies in the copy. The buffer is only 100 bytes and instead of
//using strncpy we use strcpy. If a message greater than 100 bytes is passed 
//as an argument, strcpy will continue to write into memory and smash past the
//return address. If leveraged correctly we can then go anywhere in memory.
//
//Assuming we can not write any executable shell code into the stack, we 
//are writing a function that is not called (seen below) that calls to execute
//a shell. This instead of pointing our return adddress onto the stack, we 
//instead will return to this function and have it execute giving us a shell.
//
//If ./vulnerable is run with sudo privileges then we will be spawning a shell
//with root privileges upon successful exploitation. 
//
//The scenario here is that we are on a machine that allows us to sudo some 
//executions, but not others and we have access to the GCC compiler. This will 
//allow us to either remotely or locally exploit the machine and get a shell.
//
//
//(Yes, we could've just spawned a shell but what's the fun in that?)
//
//
//It's a basic buffer overflow without an executable stack, and bypassing ASLR.
//This demo is just to show some return oriented programming.
//


#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>


void not_called() {
    //this is our vulnerable function we are going to return to in our exploit. 
    printf("Enjoy your shell!\n");
    system("/bin/sh");
    // system("/bin/bash");
}

void vulnerable_function(char* string) 
{
    //this is the vulnerable function we are going to exploit. We will write
    //more than 100 characters into string and overflow the buffer. This 
    //happens because strcpy does not keep track of how many bytes it copies, 
    //and continues to copy until NULL is reached.
    //
    //Here the 256 byte buffer is copied into the smaller 100 byte buffer
    char smallbuffer[100];
    strcpy(smallbuffer, string);
}


int main(int argc, char** argv) 
{
    //create the socket file descriptors and portnumber
     int sockfd, newsockfd, portno, clilen;
    //buffer we are going to copy our message into
     char buffer[256];
     struct sockaddr_in serv_addr, cli_addr;
     int n;
    //some error catching for the user input if no port provided
     if (argc < 2) {
         printf("ERROR, no port provided\n");
         exit(1);
     }
     //open socket
     sockfd = socket(AF_INET, SOCK_STREAM, 0);
     if (sockfd < 0)
     { 
        printf("Failed opening socket");
     }
     //zero out serv_addr
     bzero((char *) &serv_addr, sizeof(serv_addr));
     //port number put into portno
     portno = atoi(argv[1]);
     serv_addr.sin_family = AF_INET;
     serv_addr.sin_addr.s_addr = INADDR_ANY;
     serv_addr.sin_port = htons(portno);

     //bind socket
     if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) 
     {
              printf("Failed to bind");
     }
    //listen on socket
     listen(sockfd,5);
     clilen = sizeof(cli_addr);
     newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
     
     if (newsockfd < 0)
	{ 
          printf("ERROR on accept");
	}
     //zero out the buffer we read into
     bzero(buffer,256);
     //this read only reads 255 bytes into the buffer
     n = read(newsockfd,buffer,255);
     //if n is negative then we encounter erroor
     if (n < 0)
	{
         printf("ERROR reading from socket");
     	}
     //if read is successful, n is number of bytes read 
     //print the message and copy it into smaller buffer using vulnerable_function
     if (n>0)
     {
     	printf("Here is the message: %s\n",buffer);
     	vulnerable_function(buffer);
     }

    //send a message to sender saying we received message 
     n = write(newsockfd,"I got your message\n",18);
     if (n < 0) printf("ERROR writing to socket");


    return 0;
}
