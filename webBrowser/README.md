#Web Browser/Downloader in Assembly

This project is two separate projects done while at school at the Naval Postgraduate School. In these projects, lib4.asm is used to create new library functions in C, which are then used in a test harness also included here main.c . This demonstrates usage and manipulation of the stack, and the ability to return to a larger program. The progragm main.c is used to compare two NULL terminated strings and see if they are of the same length or not. It can also open a file and echo its contents onto standard out. 

This lib4.asm was then further utilized in assn5.asm to construct a program that when provided with a full URL, will construct an HTTP GET message and pull the data to a local file. This cna be used wit URLS of arbitrary size, and paths of arbitrary complexity, and the downloaded data will be put in either a file named after the file requested in the URL, or a generic index.html file on the user's computer.
