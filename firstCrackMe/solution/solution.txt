# The Solution

The solution for firstCrackMe is simple:

The password is the string "H4CKPLN7", which is a reference to the documentary: "Hackers" and their phrase "Hack the Planet"

The string itself is not stored anywhere in the crackMe, instead the binary does a few things:

**1**: It asks the user for the password by pushing the length of the message it wants to print and the message onto the stack and calls an internal function "output" to print the messge to the screen.

**2**: It then reads the string input by the user and checks it for a null 0x00 character or a new line character 0x0A, if either is detected, then the read function returns back to the main program. While it is reading each byte, a counter is stored to keep track of the length of the string, as each byte is copied over to a 256 byte buffer, if the length ever reaches 256, the program automaitcally exits and prints the "WRONG!" message.

**3**: If the string was read successfully, then the first check done is the length test. The string length stored in the previous function is checked, if it is **NOT 8 bytes (the length of "H4CKPLN7"), then the program automatically prints "WRONG!" and exits. 

**4**: If the string passes the length test then we start what is a reference to Missy Elliot and have it undergo 3 functions: workit, flipit, reverseit.

**5**: In workit, each byte of the password is added with a stored ASCII value. In other words we add each letter of "H4CKPLN7" with "1337HAXR", again a reference to "Hackers". 

**6**: In flipit, each bit of the now worked password is flipped using x86 assembly's "not" function. All the 0's become 1's, and all the 1's become 0's. 

**7**: In reverseit, the string is reversed, so instead of "H4CKPLN7" we now have "7NLPCK4H". 

**8**: Finally in checkit, each of the bytes is now compared to the stored worked, flipped, and reversed values of the correct passphrase. Each byte is compared to:

"0x76"
"0x59"
"0x72"
"0x67"
"0x7d"
"0x89"
"0x98"
"0x86"

if at any point any of the bytes of the password do not matched these stored values, then the program prints "WRONG!" and exits. 

**9**: If checkit succeeds, the the function "success" is called, and the program prints "Correct!" and exits. 

**10**: ???

**11**: Profit.


Its a simple puzzle that I used to show how to call functions make sure the stack pointers are always preserved, and also to show some byte manipulation in x86 assembly. 

Hope you enjoyed it!
