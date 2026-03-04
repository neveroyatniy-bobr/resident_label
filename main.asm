.model tiny
.code
org 100h

start:
    jmp init

new_int08:

    db 0eah ; дальний джамп
    old_int08_off dw 0
    old_int08_seg dw 0

end_tsr:

init:
    mov ax, 3508h
    int 21h
    mov word ptr cs:[old_int08_off], bx
    mov word ptr cs:[old_int08_seg], es

    push cs
    pop ds
    mov dx, offset new_int08
    mov ax, 2508h
    int 21h 

    mov dx, 1000h
    shr dx, 4
    mov ax, 3100h
    int 21h

end start