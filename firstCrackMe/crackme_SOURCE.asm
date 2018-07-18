bits 32
section .text
global _start

_start:
    mov eax, 16
    push msg1
    push eax
    call output
    
    call read

    call comparelen

    call workit
    call flipit
    call reverseit

    call checkit
    call success

exit:
    mov eax, 5
    push msg4
    push eax
    call output
    mov eax, 0x01
    int 0x80
    ret

checkit:
    push ebp
    mov ebp, esp

    xor ecx, ecx
    cmp byte[input+ecx], 0x76
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x59
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x72
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x67
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x7d
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x89
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x98
    jne wrong
    inc ecx
    cmp byte[input+ecx], 0x86
    jne wrong

    mov esp, ebp
    pop ebp
    ret

reverseit:
    push ebp
    mov ebp, esp

    xor ecx, ecx
    mov ecx, [lenstr]
    dec ecx
    xor edx, edx

reverseitloop:
    mov al, byte[input + edx]
    mov ah, byte[input + ecx]
    mov byte[input + edx], ah
    mov byte[input + ecx], al
    dec ecx
    inc edx
    cmp edx, 3
    jg reverseitdone
    jmp reverseitloop

reverseitdone:
    mov esp, ebp
    pop ebp
    ret

workit:
    push ebp
    mov ebp, esp

    xor ecx, ecx
    add byte[input+ecx], 0x31
    inc ecx
    add byte[input+ecx], 0x33
    inc ecx
    add byte[input+ecx], 0x33
    inc ecx
    add byte[input+ecx], 0x37
    inc ecx
    add byte[input+ecx], 0x48
    inc ecx
    add byte[input+ecx], 0x41
    inc ecx
    add byte[input+ecx], 0x58
    inc ecx
    add byte[input+ecx], 0x52

    mov esp, ebp
    pop ebp
    ret

flipit:
    push ebp
    mov ebp, esp
    xor ecx,ecx
flipitinternal:
    mov al, byte[input+ecx]
    not al
    mov byte[input+ecx],al
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

success:
    mov eax, 9
    push msg3
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
    cmp ecx, 255
    jge wrong
    inc dword[lenstr]
    mov bl, byte[charbuf]
    mov edx, input
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
msg3 db "Correct!",0x0A,0
msg4 db "EXIT",0x0A,0



section .bss
lenstr:  resd 1
charbuf: resb 1
input:  resb 256
