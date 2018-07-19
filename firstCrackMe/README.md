# My First CrackMe: Written in 32-bit x86 Assembly

## A reverse engineering challnge that can be done using IDA, radare2, or just good ol' fashioned gdb! 

### The challenge: 
The compiled binary will take in a password, and based on that string it will then determine if the password you entered determine if it is the right password **(Correct!)** or if you entered the wrong password **(WRONG!)**!

It's up to you to figure out what the password is based on the operation of the program and by reverse engineering the way the password is checked. 

### Repository contents:

**crackme_SOURCE.asm** contains the assembly code used to generate the binary, if you want to compile it yourself you can use it and the attached makefile to comile it. You could also look at it if you wanted to be sneaky and peek how the password is checked, but I would recommend to do that only if you are really stuck, or have solved it and wanted to verify. 

**crackme_SOURCE.o** is the object file for the crackMe, there if you wanted to do any kind of sleuthing on it

**makefile** contains the building instructions

**firstCrackMe** is the compiled binary that has been tested on Ubuntu, Debian, and Kali. 

### SOLUTION!

If you are interested, there is a short writeup of the solution in the solution directory, so you can try yourself! 

There is also a solution hint [here](https://bit.ly/1e1EYJv)


## HAPPY HUNTING! 
### If you find the solution send me an email or a tweet!
### cervandob@aggienetwork.com
### @nuclearfarmboy
