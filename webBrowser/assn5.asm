; CS 3140 - Assignment 5
; Command line for assembly : 
; nasm -f elf32 -g assn5.asm
; nasm -f elf32 lib4.asm
; gcc -g -o assn5 -m32 assn5.o dns.o lib4.o

; ********* AUTHOR'S NOTES:
; This program was done as an assignment for CS 3140 at the Naval Postgraduate
; School. It utilizes 32-bit NASM x86 assembly to connect to a website of the
; user's calling, and download the HTML of that website. It does so by 
; parsing the URL as follows:
; *****************************************************************************
; we need to parse the URL into 3 main sections, example:
; (discard this)    (hostName)      (pathName)         (fileName)
; http://           www.nps.edu     /CS3140/Eagle/      foo.txt
;                                  ^----------------------------^
;                                  This will be called the fullPath
; *****************************************************************************
; From the parsed URL of the form http://www.<variable website>.<domain>/<path>/<file>.<ext>
; this rudimentary browser generates the HTTP GET request, and saves the HTML
; to a local file named after the <file>.<ext> requested. If the the URL does
; not include a file, the default of "index.html" will be used instead. 
; The GET request is of the form:
;
; GET / HTTP/1.0\r\n
; Host: www.<website>.<domain>/<path>/<file>.<ext>\r\n
; Connection: close\r\n
; \r\n
;
; Static components of the GET message are declared at the bottom in the .data
; section. These will be used as building blocks to build the GET message. 
;
; This program utilizes libc libraries that were created in assembly from 
; a previous assignment. They are included in lib4.asm and must be compiled
; and linked for this assignment. Their functionality is described in the lib4.asm
; file. This program will also utilize dns.o which converts a URL to an IP address.
; 
;
; As part of this assignment, the sockets have to be created, and data has to
; be transmitted and received through them.  

bits 32         
section .text   


global main     

;from dns.o
extern resolv  

;from lib4.o
extern l_strlen
extern l_puts
extern l_write
extern l_close

;struct for the socket
struc sockaddr_in
    .sin_family:    resw 1
    .sin_port:      resw 1
    .sin_addr:      resd 1
    .sin_pad:       resb 8
endstruc

;START MAIN
main:

    mov     eax, [esp + 8]      ; else, ebp holds address to argv
    mov     esi, [eax + 4]      ; address of argv[1] in edi

    push    esi                 ; push pointer to argv[1]
    call    l_strlen            ; call l_strlen
    pop     ebx

; *********** The address to argv[1] will be stored in esi throughout the program

    mov     [length], eax       ; l_strlen's return value 
    xor     ecx, ecx            ; set count to 0        

copyLoop: 
;copy url in its entirety
    cmp      ecx, dword [length]    ; check if count is at length
    je      findHostLoopStart       ; find hostname when done copying

    mov     al, byte [esi + ecx]        ; al has the char 
    mov     byte [longURL + ecx], al    ; char being moved to longURL 

    inc     ecx             ; increment counter 
    jmp     copyLoop        ; continue with chars 

; *****************************************************************************
; *****************************************************************************
; we need to parse the URL into 3 main sections, example:
; (discard this)    (hostName)      (pathName)         (fileName)
; http://           www.nps.edu     /CS3140/Eagle/      foo.txt
;                                  ^----------------------------^
;                                  This will be called the fullPath
; *****************************************************************************
; *****************************************************************************
findHostLoopStart:
; get host name by copying it into a buffer until we find either the end of the file or a "/"
    xor     ecx, ecx        ; counter back to zero
    add     ecx, 7          ; need to skip the http://

findHostLoop:
cmp     ecx, dword [length]         ; check if count is at length
    je      fileCreateOpenA         ; somewhere when done copying

    mov     al, byte [esi + ecx]        ; al has the char  
    cmp     byte al, 0x2F               ; check for /
    je      slash                           ; jump if found 
    mov     byte [hostName + ecx - 7], al   ; char being moved to hostName 

    inc     ecx                 ; increment counter 
    jmp     findHostLoop        ; continue with chars 

slash:
;check to see if the last character is a "/", if the last char is "/", then we are done parsing URL
    mov     ebx, [length]           ; length in ebx 
    dec     ebx                     ; check if at end of argv[1]
    cmp     ebx, ecx
    je      fileCreateOpenA 

hostNameLength:
; if there is something after the slash after the host name, we must extract it
; ecx currently points at the space after the slash in the hostName buffer so we must save it
; since we did a resb we know the buffer is full of nulls so we dont need to add a null when we call
; l_strlen

    ; save the counter
    mov     dword [count], ecx

    ; get length of host and save it
    push    hostName
    call    l_strlen
    pop     ebx

    mov     dword [hostNameLen], eax

    ;bring back the counter
    mov     ecx, dword [count]

    ;clear out a register to use for the counter to copy the full path
    xor     edx,edx


fullPathLoop:
    cmp     ecx, dword [length] ; are we at the end?
    je      filenameshort   

    mov     al, byte [esi + ecx]           ; if not, copy the next byte of the whole URL into al  
    mov     byte [fullPath + edx], al      ; move it to fullPath

    inc     ecx                              ; increment counter
    inc     edx 
    jmp     fullPathLoop                     ; continue copying


filenameshort:
; after we copy the full path, we must find the file

    ;we are going to need the fullPath length later so find it and save it
    push    fullPath 
    call    l_strlen
    pop     ebx

    mov dword [fullPathLen], eax 

    dec     edx                             ; get to last char
    mov     al, byte [fullPath + edx]       ; al has the char  
    cmp     byte al, 0x2F                   ; check for /
    je      fileCreateOpenB                 ; jump if found

; if the last character is a slash, then we dont have a fileName, we only have a pathName
; if we don't have a slash then we have to find the file name


    xor     ebx, ebx

; ebx is empty, ecx points at the end of the full path in the URL, 
; edx is a counter at the end of fullPath pointing at the last char before NULL

reverseFileLoop:
;work backwards until we find a / since that will be the file name
    mov     al, byte [fullPath + edx]
    mov     byte [reverseFile + ebx], al
    dec     edx
    inc     ebx
    cmp     byte al, 0x2F
    je      forwardFileLoopCheck
    jmp     reverseFileLoop



forwardFileLoopCheck:
    ; cmp     byte [periodCheck], 1
    ; jne     messageTypeB

    push    reverseFile
    call    l_strlen
    pop     ebx


    ;mov     [fileNameLen], eax
    dec     eax
    dec     eax
    xor     edx, edx


forward_loop:
    mov     bl, byte [reverseFile + eax]
    mov     byte [fileName + edx], bl
    dec     eax
    inc     edx
    cmp     eax, 0
    jl      fileCreateOpenC
    jmp     forward_loop





; ********************** FILE TYPE C: hostname, pathname, file name
fileCreateOpenC:
    mov     eax, 0x05   ;open syscall
    mov     ebx, fileName    ; name of file
    mov     ecx, 0102o  ;O_creat and O_rdwr
    mov     edx, 0666o  ; rw-rw-rw-
    int     0x80

    mov dword [outputfd], eax   ;fd of output file

getMsgCstart:
    xor     ecx, ecx    ; counter for the GETMessage
    xor     edx, edx ;counter for components

getMsgCpart1:
; copy getmsg1 into GETMessage
    cmp     edx, 4  ; 4 bytes in "GET "
    je      getMsgCpart2start

    mov     bl, byte [getmsg1 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgCpart1

getMsgCpart2start:
    mov     eax, dword [fullPathLen]
    xor     edx, edx
getMsgCpart2:
    ;copy fullPath into the get message
    cmp     edx, eax
    je      getMsgCpart3start

    mov     bl, byte [fullPath + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgCpart2

getMsgCpart3start:
    xor     edx, edx
getMsgCpart3Loop:
    ;copy getmsg2 into GETMessage
    cmp     edx, 17
    je      getMsgCpart4start

    mov     bl, byte [getmsg2 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgCpart3Loop

getMsgCpart4start:
    xor     edx, edx
getMsgCpart4Loop:
    ; copy host name into GETMessage
    cmp     edx, dword [hostNameLen]
    je      getMsgCpart5start

    mov     bl, byte [hostName + edx]
    mov     byte [GETMessage + ecx], bl
    inc     edx
    inc     ecx
    jmp     getMsgCpart4Loop

getMsgCpart5start:
    xor     edx, edx
getMsgCpart5Loop:
    ;copy getmsg3 into GETMessage
    cmp     edx, 24
    je      connectAll

    mov     bl, byte [getmsg3 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgCpart5Loop


; ********************** FILE TYPE B: hostname, pathname, NO file name


fileCreateOpenB:
    mov     eax, 0x05           ; open syscall
    mov     ebx, indexHtml       ; name of file
    mov     ecx, 0102o          ; O_creat and O_rdwr
    mov     edx, 0666o          ; rw-rw-rw-
    int     0x80

    mov dword [outputfd], eax   ; fd of output file


getMsgBstart:
    xor     ecx, ecx    ; counter for the GETMessage
    xor     edx, edx    ;counter for components

getMsgBpart1:
; copy getmsg1 into GETMessage
    cmp     edx, 4  ; 4 bytes in "GET "
    je      getMsgBpart2start

    mov     bl, byte [getmsg1 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgBpart1

getMsgBpart2start:
    mov     eax, dword [fullPathLen]
    xor     edx, edx
getMsgBpart2:
    ;copy fullPath into the get message
    cmp     edx, eax
    je      getMsgBpart3start

    mov     bl, byte [fullPath + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgBpart2

getMsgBpart3start:
    xor     edx, edx
getMsgBpart3Loop:
    ;copy getmsg2 into GETMessage
    cmp     edx, 17
    je      getMsgBpart4start

    mov     bl, byte [getmsg2 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgBpart3Loop

getMsgBpart4start:
    xor     edx, edx
getMsgBpart4Loop:
    ; copy host name into GETMessage
    cmp     edx, dword [hostNameLen]
    je      getMsgBpart5start

    mov     bl, byte [hostName + edx]
    mov     byte [GETMessage + ecx], bl
    inc     edx
    inc     ecx
    jmp     getMsgBpart4Loop

getMsgBpart5start:
    xor     edx, edx
getMsgBpart5Loop:
    ;copy getmsg3 into GETMessage
    cmp     edx, 24
    je      connectAll

    mov     bl, byte [getmsg3 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgBpart5Loop


; ********************** FILE TYPE A: hostname, NO pathname, NO file name


fileCreateOpenA:
    mov     eax, 0x05           ; open syscall
    mov     ebx, indexHtml       ; name of file
    mov     ecx, 0102o          ; O_creat and O_rdwr
    mov     edx, 0666o          ; rw-rw-rw-
    int     0x80

    mov dword [outputfd], eax   ; fd of output file


getMsgAstart:
    xor     ecx, ecx    ; counter for the GETMessage
    xor     edx, edx ;counter for components

getMsgApart1:
; copy getmsg1 into GETMessage
    cmp     edx, 4  ; 4 bytes in "GET "
    je      getMsgApart2start

    mov     bl, byte [getmsg1 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgApart1

getMsgApart2start:
    ; mov     eax, 1  ;only need to write "/"
    xor     edx, edx
getMsgApart2:
    ;copy empty path "/" into the get message

    mov     bl, byte [emptyPath + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx

getMsgApart3Loop:
    ;copy getmsg2 into GETMessage
    cmp     edx, 17
    je      getMsgApart4start

    mov     bl, byte [getmsg2 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgApart3Loop

getMsgApart4start:
    mov     dword[count], ecx

    ; get length of host and save it
    push    hostName
    call    l_strlen
    pop     ebx

    mov     dword [hostNameLen], eax
    mov     ecx, dword [count]
    xor     edx, edx
getMsgApart4Loop:
    ; copy host name into GETMessage
    cmp     edx, dword [hostNameLen]
    je      getMsgApart5start

    mov     bl, byte [hostName + edx]
    mov     byte [GETMessage + ecx], bl
    inc     edx
    inc     ecx
    jmp     getMsgApart4Loop

getMsgApart5start:
    xor     edx, edx
getMsgApart5Loop:
    ;copy getmsg3 into GETMessage
    cmp     edx, 24
    je      connectAll

    mov     bl, byte [getmsg3 + edx]
    mov     byte [GETMessage + ecx], bl

    inc     ecx
    inc     edx
    jmp     getMsgApart5Loop


;TODO: Not Cry




connectAll:

    ; create socket
    push    dword 0
    push    dword 1     ; SOCK_STREAM
    push    dword 2     ; AF_INET
    mov     ecx, esp    ; pointer to args
    mov     ebx, 1      ; sys_socket
    mov     eax, 102   ; sys_socketcall
    int     0x80        ; sockfd is now stored in eax
    pop     ebx
    pop     ebx
    pop     ebx

    mov dword [sockfd], eax     ; save sockfd into sockfd

    ; resolve host name to IP 
    push    hostName
    call    resolv
    pop     ebx

    ;move into struct
    mov     [server + sockaddr_in.sin_addr],eax

    ;connect syscall
    push    16          ;fixed length of the sockaddrstruct
    push    server
    push    dword [sockfd]
    mov     ecx, esp
    mov     ebx, 3
    mov     eax, 0x66
    int     0x80
    pop     ebx
    pop     ebx
    pop     ebx

    ;****************************

    push    GETMessage
    call    l_strlen
    pop     ebx
    mov dword [getMessageLen], eax


    ;****************************

    ; send get request
    push    dword 0
    push    dword [getMessageLen]
    push    GETMessage  ; GET IT!
    push    dword [sockfd]
    mov     ecx, esp
    mov     ebx, 9
    mov     eax, 102
    int     0x80
    pop     ebx
    pop     ebx
    pop     ebx
    pop     ebx

    mov     eax, 1 ; <------THIS THING BREAKS IF IT'S > 1 AND ITS BREAKING MY WILL TO LIVE
    mov     dword [recievebuffLen], eax


recieveLoop:
    ;recieve syscall
    push    dword 0
    push    dword [recievebuffLen]
    push    recievebuf
    push    dword [sockfd]
    mov     ecx, esp
    mov     ebx, 10
    mov     eax, 0x66
    int     0x80
    pop     ebx
    pop     ebx
    pop     ebx
    pop     ebx

    mov dword [bytesRead], eax


    push    dword[recievebuffLen]
    push    recievebuf
    push    dword [outputfd]
    call    l_write
    pop     ebx
    pop     ebx
    pop     ebx



    mov     eax, dword [bytesRead]
    cmp     eax, 0 ; if same, we are done since we read nothing
    jle      done
    jmp     recieveLoop

done:
; close the file 
    push    dword [outputfd]         ; fd for opened file 
    call    l_close                  ; close it
    pop     ebx                      ; clean up the stack 

    ;exit syscall
    mov     eax, 0x01               ; 1 is sys call for exit
    int     0x80                    ; execute exit sys call

section .data   ; section declaration
                ;14               2      17                2      17                4
get_msgTest db "GET / HTTP/1.1",13,10,"Host: www.nps.edu",13,10,"Connection: close",13,10,13,10,0 ;60 chars

; GET / HTTP/1.0\r\n
; Host: www.nps.edu\r\n
; Connection: close\r\n
; \r\n

get_msgTest2 db "GET / HTTP/1.0\r\n\r\n" ;24 chars
get_msgNoFile db "GET / HTTP/1.1",13,10,"Host: "
getmsg1 db "GET "
getmsg2 db " HTTP/1.1",13,10,"Host: "
getmsg3 db 13,10,"Connection: close",13,10,13,10,0
indexHtml db "index.html",0
emptyPath db "/"
host_name_test db "www.nps.edu",0x0

server: istruc sockaddr_in
        at sockaddr_in.sin_family, dw 2
        at sockaddr_in.sin_port, dw 0x5000
        at sockaddr_in.sin_addr, dd 0x00000000
        iend


section .bss    ; section declaration

count:              resd 1 ; counter
longURL:            resb 1024 ; full url length 
hostName:           resb 512    ; host name makestr
hostNameLen:        resd 1 ; length of host name
fullPath:           resb 512 ; path to file
fullPathLen:        resd 1 
reverseFile:        resb 100 ; file name for output 
fileName:           resb 100
length:             resd 1    ; length of argv[1] - full url length 
temp:               resb 1
fileNameLen:        resd 1
periodCheck:        resb 1
sockfd:             resd 1
recievebuf:         resb 1024
recievebuffLen:     resd 1
bytesRead:          resd 1
getMessageLen:      resd 1
GETMessage:         resb 512
outputfd:           resd 1 
