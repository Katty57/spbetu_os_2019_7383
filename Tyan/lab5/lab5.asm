CODE        SEGMENT

ASSUME CS:CODE, DS:DATA, ES:DATA, SS:AStack

AStack        SEGMENT        STACK
  DW            64           DUP (?)
AStack        ENDS

Write_msg        PROC        near
        push    ax
        mov     ah, 09h
        int     21h
        pop     ax
        ret
Write_msg        ENDP

DATA SEGMENT
LOAD            db  'Resident was loaded.', 0dh, 0ah, '$'
ALREADY         db  'Resident has already been loaded.', 0dh, 0ah, '$'
UNLOADED        db  'Resident was unloaded.', 0dh, 0ah, '$'
DATA ENDS

ROUT        PROC        FAR
        jmp     ROUT_begin

IDFN        db  '0000'
KEEP_IP     dw  0
KEEP_CS     dw  0
KEEP_PSP    dw  0
KEEP_SS     dw  0
KEEP_AX     dw  0
KEEP_SP     dw  0
REQ_KEY     db  1Dh
INTER_STACK dw  64 dup (?)
END_STACK   dw  0

    ROUT_begin:
        mov     KEEP_AX,ax
        mov     KEEP_SS,ss
        mov     KEEP_SP,sp
        mov     ax,cs
        mov     ss,ax
        mov     sp,offset END_STACK
        mov     ax,KEEP_AX
        push    ax
        push    dx
        push    ds
        push    es
        in      al,60H
        cmp     al,REQ_KEY
        je      do_req
        pushf
        call    dword ptr cs:KEEP_IP
        jmp     end_ROUT
    do_req:
        push    ax
        in      al,61h
        mov     ah, al
        or      al,80h
        out     61h,al
        xchg    ah,al
        out     61h,al
        mov     al,20h
        out     20h,al
        pop     ax
    add_to_buff:
        mov     cl,'@'
        mov     ah,05h
        mov     ch,00h
        int     16h
        or      al, al
        jz      end_ROUT
        mov     ax,es:[1Ah]
        mov     es:[1Ch],ax
        jmp     add_to_buff
    end_ROUT:
        pop     es
        pop     ds
        pop     dx
        pop     ax
        mov     ss,KEEP_SS
        mov     sp,KEEP_SP
        mov     al,20h
        out     20h,al
        mov     ax,KEEP_AX
        iret
    LAST_BYTE:
ROUT        ENDP

DEFINE_INTER        PROC
        push    ax
        push    dx
        push    ds
        mov     ah,35h
        mov     al,09h
        int     21h
        mov     KEEP_IP,bx
        mov     KEEP_CS,es
        mov     dx,offset ROUT
        mov     ax,seg ROUT
        mov     ds,ax
        mov     ah,25h
        mov     al,09h
        int     21h
        pop     ds
        mov     dx,offset LOAD
        call    Write_msg
        pop     dx
        pop     ax
        ret
DEFINE_INTER        ENDP

DEL_INTER        PROC
        push    ax
        push    ds
        CLI
        mov     ah,35h
        mov     al,09h
        int     21h
        mov     si,offset KEEP_IP
        sub     si,offset ROUT
        mov     dx,es:[bx+si]
        mov     ax,es:[bx+si+2]
        mov     ds,ax
        mov     ah,25h
        mov     al,09h
        int     21h
        pop     ds
        mov     ax,es:[bx+si-2]
        mov     es,ax
        mov     ax,es:[2Ch]
        push    es
        mov     es,ax
        mov     ah,49h
        int     21h
        pop     es
        mov     ah,49h
        int     21h
        STI
        pop     ax
        ret
DEL_INTER        ENDP

MAIN        PROC        Far
        mov     ax,DATA
        mov     ds,ax
        mov     KEEP_PSP,es
        mov     ah,35h
        mov     al,09h
        int     21h
        mov     si,offset IDFN
        sub     si,offset ROUT
        mov     ax,'00'
        cmp     ax,es:[bx+si]
        jne     nt_ldd
        cmp     ax,es:[bx+si+2]
        je      ldd
    nt_ldd:
        call    DEFINE_INTER
        mov     dx,offset LAST_BYTE
        mov     cl,4
        shr     dx,cl
        inc     dx
        add     dx,CODE
        sub     dx,KEEP_PSP
        xor     al,al
        mov     ah,31h
        int     21h
    ldd:
        push    es
        push    ax
        mov     ax,KEEP_PSP
        mov     es,ax
        mov     al,es:[82h]
        cmp     al,'/'
        jne     nt_nld
        mov     al,es:[83h]
        cmp     al,'u'
        jne     nt_nld
        mov     al,es:[84h]
        cmp     al,'n'
        je      nld
    nt_nld:
        pop     ax
        pop     es
        mov     dx,offset ALREADY
        call    Write_msg
        jmp     it_is_over
    nld:
        pop     ax
        pop     es
        call    DEL_INTER
        mov     dx,offset UNLOADED
        call    Write_msg
    it_is_over:
        xor     al,al
        mov     ah,4Ch
        int     21H
MAIN ENDP
CODE ENDS

END MAIN
