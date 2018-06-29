;Name: Cervando A. Banuelos
;Class: CS 3140
;Assignment 4
;Commands used to assemble:
; nasm -f elf32 start.asm
; nasm -f elf32 lib4.asm
; gcc -g -o main -m32 main.c lib4.o start.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles
; 
;Assembled in a 32 bit Ubuntu Machine


bits 32 

section .bss
buf      RESB  1 ;reserve one byte for buffer
textBuf  RESB  1
maxReadSize RESD  1
counter  RESW  1 ;


global l_strlen
global l_strcmp
global l_gets
global l_write
global l_open
global l_close
global l_exit
global l_puts


section .text  ;start code

l_strlen: 
; takes a NULL terminated string and returns an integer value of the length
   ;push the base pointer and st the stack pointer to it
   push ebp
   mov ebp, esp
   push esi
   push edi
   push ebx


   ;make sure stuff is zero
   mov ecx, 0
   xor eax, eax
   mov ebx, 0
   mov ebx, [ebp +8]

;check to see if last (null) byte, if it is then exit
strlen_loop:                  
   cmp byte[ebx+eax],0x0
   je end_strlen_loop

len_adder_loop: ; if not null byte, increase counter eax and read next byte
   inc eax
   jmp strlen_loop

end_strlen_loop: ; restore ebp and exit!
   pop ebx
   pop edi
   pop esi
   mov esp, ebp
   pop ebp
   ret


l_strcmp:
; takes two strings that are either terminated by NULL or new line (0x0A)
; compares them character by character. If characters are at any point not the
; same, function returns 1 for different. If NULL or new line are reached 
; before this, function returns 0 for same strings.
   ;push everything!
   push ebp
   push esi
   push edi
   push ebx

   ;get pointers to strings
   mov eax, [esp + 20]
   mov ebx, [esp + 24]

compare_loop:
   ;empty register
   xor ecx,ecx

   ;move first byte from each string into register 
   mov ch,[eax]
   mov cl,[ebx]

   ;compare! if not equal, then we are donezo!
   cmp ch,cl
   jne different_chars

   ;if either is the null or new line then they are the same string
   cmp cl, 0xA
   je same_string

   cmp ch,0x0
   je same_string

   ; if same char, and have not reached null, then read next byte and compare again
   inc eax
   inc ebx
   jmp compare_loop

different_chars: ;different! return 1
   mov eax,1
   jmp end_compare_loop

same_string: ; samesies! return 0
   mov eax, 0
   jmp end_compare_loop

end_compare_loop:
   ; pop it like it's hot!
   pop ebx
   pop edi
   pop esi
   pop ebp
   ret
      

l_gets:
; function takes integer file descriptor (fd) and reads a max number of
; bytes (len) into a buffer (buf) until either the max len or a new line is
; reached. Return number of bytes read on success. 
;       4       8     12       16
;int l_gets(int fd, char *buf, int len)
   ; pushin err'thang 
   push ebp
   mov ebp,esp
   push esi
   push edi
   push ebx

   ; set counter
   xor ebx,ebx
   mov [counter],ebx

l_gets_read:
   ;read one byte and store it into buffer
   mov edx, 1
   mov ecx, buf
   mov ebx, [ebp+8]
   mov eax, 3
   int 0x80

   ;if we read nothing, we done
   cmp eax, 1
   jne l_gets_done

   ;move counter into ebx
   xor ebx, ebx
   mov ebx, [counter]

   ;check to see if max number of bytes have been read
   cmp ebx, [ebp+16]
   jae l_gets_done 

   ;check to see if newline byte
   xor ecx, ecx
   mov ecx, [buf]
   cmp cl, 0x0A
   je l_gets_done_newline

   ;if not max size or newline then move to the char * buf
   mov eax, [ebp+12]
   mov [eax + ebx],cl
   inc ebx
   mov [counter], ebx
   jmp l_gets_read

l_gets_done_newline:
   ; move the new line into the buffer, increase counter and then exit cause you're outta there!
   mov eax, [ebp+12]
   mov [eax + ebx],cl
   mov ebx,[counter]
   inc ebx
   mov [counter],ebx

l_gets_done:
   ; eax is the return value (num of bytes read)
   mov eax, [counter]
   pop ebx
   pop edi
   pop esi
   pop ebp
   ret


l_puts:
; takes string from a buffer and outputs the string one byte at a time via 
; system call to standard out. This does not mean each byte has its own line.
; Example:
; char prompt[] = "Enter a string: ";
; l_puts(prompt);
;
;STDOUT: Enter a string: 
;     4     8  
;void l_puts(const char *buf)
   ;push and set up!
   push ebp
   mov ebp, esp
   push esi
   push edi
   push ebx
   xor ecx,ecx
   mov [counter],ecx

l_putsRead:
   ; read one byte, is it null? yes, you done!
   mov ecx,[counter]
   mov ebx, [ebp+8]
   mov edx, [ebx+ecx]
   cmp byte[ebx+ecx],0x0
   je l_putsDone

   ; if not not, move it to buffer and increase counter
   mov [textBuf],edx
   inc ecx
   mov [counter],ecx

   ; write that byte to stdout and do it all again!
   mov edx, 1
   mov ecx, textBuf
   mov ebx, 1
   mov eax, 4
   int 0x80
   jmp l_putsRead

l_putsDone:
   ; I like it when you call me big POP-a! -Notorious EBP
   pop ebx
   pop edi
   pop esi
   mov esp,ebp
   pop ebp
   ret


l_write:
; Take a string in a buffer (buf) and output a discrete number of bytes (len)
; to a file indicated by file descriptor (fd). Return number of bytes written
; on success, return -1 on failure.
;     4     8     12          16
;int l_write(int fd, const char *buf, int len);
   ; Pushing along!
   push ebp
   mov ebp, esp
   push esi
   push edi
   push ebx

   ; WRITE EVERYTHING
   mov edx, [ebp + 16]  ; number of bytes
   mov ecx, [ebp + 12]  ; mesage to write
   mov ebx, [ebp + 8]   ; file descriptor
   mov eax, 4        ; write system call number
   int 0x80       ; system call

   ; DID WE GET AN ERROR? THEN WE GET NEGATIVE ONE (CAPS LOCK IS CRUISE CONTROL FOR COOL)
   cmp eax, 0
   jge l_writeExit
   xor eax,eax
   not eax


l_writeExit:
   ; POPPING EVERYTING
   pop ebx
   pop edi
   pop esi
   pop ebp
   ret

l_open:
; open a file to write or read into (depending on flags and mode)
; return a -1 if failed to open, otherwise return the integer file descriptor
;     4                 8           12    16 
;int l_open(const char *name, int flags, int mode);
   ; i think we push?
   push ebp
   mov ebp,esp
   push esi
   push edi
   push ebx

   ;open the file!
   mov eax, 5          ;open
   mov ebx, [ebp + 8]   ;path
   mov ecx, [ebp + 12] ;flags
   mov edx, [ebp + 16] ;mode
   int 0x80

   ;did it fail? return negative one!
   cmp eax, 0x0
   jge l_openExit
   xor eax,eax
   not eax

l_openExit:
   ;popcorn!
   pop ebx
   pop edi
   pop esi
   pop ebp
   ret

l_close:
; close the file indiccated by file descriptor, return -1 on failure
;         4     8
; int l_close(int fd);
   ;Why can't we pull instead of push for once?
   push ebp
   mov ebp,esp
   push esi
   push edi
   push ebx
   
   ; close the file!
   mov eax, 6          ;close
   mov ebx, [ebp + 8]   ;fd
   int 0x80

   ;is it error? then -1 to return code! it's super effective!
   cmp eax, 0x0
   jge l_closeExit
   xor eax,eax
   not eax

l_closeExit:
   ;Mary Poppins
   pop ebx
   pop edi
   pop esi
   pop ebp
   ret

l_exit:
; call exit with whatever code the user specifies (0, etc.)
;    4         8
; int l_exit(int rc)
   ;Move the return code into ebx, and then exit!
   push ebp
   mov ebp, esp
   mov eax, 1
   mov ebx, [ebp+8]
   int 0x80

