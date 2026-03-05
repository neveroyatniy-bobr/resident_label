.model tiny
locals @@
.code
org 100h

start proc
    jmp init
start endp

new_int08 proc
    call update_label
    call print_label

    db 0eah ; дальний джамп
    old_int08_off dw 0
    old_int08_seg dw 0
new_int08 endp

update_label proc
    push di
    push dx
    push bx

    mov dx, offset di_val
    call update_register

    mov di, ax
    mov dx, offset ax_val
    call update_register

    mov di, bx
    mov dx, offset bx_val
    call update_register

    mov di, cx
    mov dx, offset cx_val
    call update_register

    mov bx, sp
    add bx, 2
    mov di, [bx]
    mov dx, offset dx_val
    call update_register

    mov di, si
    mov dx, offset si_val
    call update_register

    mov di, bp
    mov dx, offset bp_val
    call update_register

    mov di, sp
    mov dx, offset sp_val
    call update_register

    mov di, cs
    mov dx, offset cs_val
    call update_register

    mov di, ds
    mov dx, offset ds_val
    call update_register

    mov di, ss
    mov dx, offset ss_val
    call update_register

    mov di, es
    mov dx, offset es_val
    call update_register

    ;mov dx, offset ip_val
    ;call update_register
    ;хз как ip вывести

    pop bx
    pop dx
    pop di

    ret
update_label endp

;di - значение, dx - адрес переменной
update_register proc
    push bx
    push cx
    push bp
    push ax

    mov bp, dx
    add bp, 7

    mov cl, 0
    jmp @@loop_symbol_cond
    @@loop_symbol:
        mov bx, di
        shl bx, cl
        shr bx, 12

        mov al, cs:[offset digits + bx]
        mov cs:[bp], al

        inc bp
        add cl, 4

    @@loop_symbol_cond:
        cmp cl, 12
        jle @@loop_symbol

    pop ax
    pop bp
    pop cx
    pop bx

    ret
update_register endp

print_label proc
    push ax
    push cx
    push es
    push di
    push si

    mov si, offset slabel

    mov ax, 0B800h
    mov es, ax
    mov di, 2*(80+64)

    jmp @@loop_for_rows_cond
    @@loop_for_rows:

        mov cx, 0
        jmp @@loop_for_columns_cond
        @@loop_for_columns:
            mov al, cs:[si]
            mov ah, 67h
            mov es:[di], ax

            add di, 2
            inc si
            inc cx

        @@loop_for_columns_cond:
            cmp cx, 14
            jl @@loop_for_columns

        add di, 2*(80-14)

    @@loop_for_rows_cond:
        cmp si, offset elabel
        jle @@loop_for_rows
    
    pop si
    pop di
    pop es
    pop cx
    pop ax

    ret
print_label endp

save_screen proc
    push ax
    push cx
    push es
    push di
    push si

    mov ax, 0B800h
    mov es, ax
    mov si, 2*(80+64)

    mov di, offset screen_buff

    jmp @@loop_for_rows_cond
    @@loop_for_rows:

        mov cx, 0
        jmp @@loop_for_columns_cond
        @@loop_for_columns:
            mov ax, es:[si]
            mov cs:[di], ax

            add di, 2
            add si, 2
            inc cx

        @@loop_for_columns_cond:
            cmp cx, 14
            jl @@loop_for_columns

        add si, 2*(80-14)

    @@loop_for_rows_cond:
        cmp di, offset end_scr_buf
        jle @@loop_for_rows
    
    pop si
    pop di
    pop es
    pop cx
    pop ax

    ret
save_screen endp

load_screen proc
    push ax
    push cx
    push es
    push di
    push si

    mov si, offset screen_buff

    mov ax, 0B800h
    mov es, ax
    mov di, 2*(80+64)

    jmp @@loop_for_rows_cond
    @@loop_for_rows:

        mov cx, 0
        jmp @@loop_for_columns_cond
        @@loop_for_columns:
            mov ax, cs:[si]
            mov es:[di], ax

            add di, 2
            add si, 2
            inc cx

        @@loop_for_columns_cond:
            cmp cx, 14
            jl @@loop_for_columns

        add di, 2*(80-14)

    @@loop_for_rows_cond:
        cmp si, offset end_scr_buf
        jle @@loop_for_rows
    
    pop si
    pop di
    pop es
    pop cx
    pop ax

    ret
load_screen endp

digits: db "0123456789ABCDEF"

; на запись [r**+8]
;ширина 15
;количество столбцов
slabel: db "+------------+"
ax_val: db "| AX = 0000h |"
bx_val: db "| BX = 0000h |"
cx_val: db "| CX = 0000h |"
dx_val: db "| DX = 0000h |"
di_val: db "| DI = 0000h |"
si_val: db "| SI = 0000h |"
bp_val: db "| BP = 0000h |"
sp_val: db "| SP = 0000h |"
cs_val: db "| CS = 0000h |"
ds_val: db "| DS = 0000h |"
ss_val: db "| SS = 0000h |"
es_val: db "| ES = 0000h |"
ip_val: db "| IP = 0000h |"
elabel: db "+------------+"

screen_buff: db 28*14 dup(0)
end_scr_buf: db 28 dup(0)        

end_tsr:

init proc
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
init endp

end start