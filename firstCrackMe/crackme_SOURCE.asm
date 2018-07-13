bits 32
section .text
global main

main:
    mov eax, 16
    push msg1
    push eax
    call output
    
    call read

    call comparelen

    call workit
    call flipit
    call reverseit



    call exit

exit:
    mov eax, 5
    push msg4
    push eax
    call output
    mov eax, 0x01
    int 0x80

reverseit:
    push ebp
    mov ebp, esp

    xor ecx, ecx
    mov ecx, [lenstr]
    dec ecx
    xor edx, edx

reverseitloop:
    mov al, byte[buffer + edx]
    mov ah, byte[buffer + ecx]
    mov byte[buffer + edx], ah
    mov byte[buffer + ecx], al
    dec ecx
    inc edx
    cmp edx, 3
    jg reverseitdone

reverseitdone:
    mov esp, ebp
    pop ebp
    ret

workit:
    push ebp
    mov ebp, esp

    xor ecx, ecx
    add byte[buffer+ecx], 0x31
    inc ecx
    add byte[buffer+ecx], 0x33
    inc ecx
    add byte[buffer+ecx], 0x33
    inc ecx
    add byte[buffer+ecx], 0x37
    inc ecx
    add byte[buffer+ecx], 0x48
    inc ecx
    add byte[buffer+ecx], 0x41
    inc ecx
    add byte[buffer+ecx], 0x58
    inc ecx
    add byte[buffer+ecx], 0x52

    mov esp, ebp
    pop ebp
    ret

flipit:
    push ebp
    mov ebp, esp
    xor ecx,ecx
flipitinternal:
    mov al, byte[buffer+ecx]
    not al
    mov byte[buffer+ecx],al
    inc ecx
    cmp ecx,8
    jl flipitinternal

    mov esp,ebp
    pop ebp
    ret    

wrong:
    mov eax, 7
    push msg2
    push eax
    call output
    call exit

comparelen:
    push ebp
    mov ebp, esp
    cmp dword[lenstr],8
    jne wrong
    mov esp, ebp
    pop ebp
    ret


read:
    push ebp
    mov ebp,esp
    xor ecx, ecx
    mov dword[lenstr], ecx

readsubroutine:
    
    mov edx, 1
    mov ecx, charbuf
    mov ebx, 0
    mov eax, 3
    int 0x80

    cmp eax,0
    je readingdone
    cmp byte[charbuf],0x0A
    je readingdone
    cmp byte[charbuf], 0x0
    je readingdone
    mov ecx, dword[lenstr]

    inc dword[lenstr]
    mov bl, byte[charbuf]
    mov edx, buffer
    mov [edx+ecx],bl
    jmp readsubroutine

readingdone:
    mov esp, ebp
    pop ebp
    ret

output:
    push ebp
    mov ebp, esp

    add esp, 8
    mov edx, [esp]
    add esp, 4
    mov ecx, [esp]
    mov ebx, 1
    mov eax, 4
    int 0x80 

    
    mov esp, ebp
    pop ebp
    ret

section .data
msg1 db "Input Passcode:",0x0A,0
msg2 db "WRONG!",0x0A,0
msg3 db "Correct!\n",0
msg4 db "EXIT",0x0A,0

section .bss
buffer:  resb 256
lenstr:  resd 1
charbuf: resb 1