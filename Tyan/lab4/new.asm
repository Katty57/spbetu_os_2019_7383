CODE        SEGMENT

ASSUME CS:CODE, DS:DATA, ES:DATA, SS:ASTACK

ASTACK        SEGMENT        STACK
  DW            64           DUP (?)
ASTACK        ENDS

DATA        SEGMENT
LOAD            db  'Resident was loaded.', 0dh, 0ah, '$'
ALREADY         db  'Resident has already been loaded.', 0dh, 0ah, '$'
UNLOADED        db  'Resident was unloaded.', 0dh, 0ah, '$'
DATA        ENDS

Write_msg        PROC        near
        push    ax
        mov     ah, 09h
        int     21h
        pop     ax
        ret
Write_msg        ENDP

setCurs        PROC
        push    ax
        push    bx
        push    cx
        mov     ah,02h
        mov     bh,00h
        int     10h
        pop     cx
        pop     bx
        pop     ax
        ret
setCurs        ENDP

getCurs        PROC
        push    ax
        push    bx
        push    cx
        mov     ah,03h
        mov     bh,00h
        int     10h
        pop     cx
        pop     bx
        pop     ax
        ret
getCurs        ENDP

COUT        PROC
        push    es
        push    bp
        mov     ax,SEG COUNT
        mov     es,ax
        mov     ax,offset COUNT
        mov     bp,ax
        mov     ah,13h
        mov     al,00h
        mov     cx,19h
        mov     bh,0h
        mov     bl,Dh
        int     10h
        pop     bp
        pop     es
        ret
COUT        ENDP

ROUT        PROC        FAR
        jmp ROUT_BEGIN

IDFN      db  '0000'
KEEP_IP         dw  0
KEEP_CS         dw  0
KEEP_PSP        dw  0
flag            db  0
KEEP_SS         dw  0
KEEP_AX         dw  0
KEEP_SP         dw  0
COUNT           db  'Count of interrupt: 0000 $'
INTER_STACK     dw  64 dup (?)
END_STACK       dw  0

    ROUT_begin:
        mov     KEEP_AX, ax
        mov     KEEP_SS, ss
        mov     KEEP_SP, sp
        mov     ax, cs
        mov     ss, ax
        mov     sp, offset END_STACK
        mov     ax, KEEP_AX
        push    dx
        push    ds
        push    es
        cmp     flag, 1
        je      ROUT_back
        call    getCurs
        push    dx
        mov     dh,16h
        mov     dl,27h
        call    setCurs
        ROUT_count:
        push    si
        push    cx
        push    ds
        mov     ax,SEG COUNT
        mov     ds,ax
        mov     si,offset COUNT
        add     si, 17h
    cycle:
        mov     ah,[si]
        inc     ah
        mov     [si],ah
        cmp     ah,3Ah
        jne     end_count
        mov     ah,30h
        mov     [si],ah
        dec     si
        loop    cycle
    end_count:
        pop     ds
        pop     cx
        pop     si
        call    COUT
        pop     dx
        call    setCurs
        jmp     end_ROUT
    ROUT_back:
        CLI
        mov     dx,KEEP_IP
        mov     ax,KEEP_CS
        mov     ds,ax
        mov     ah,25h
        mov     al,1Ch
        int     21h
        mov     es, KEEP_PSP
        mov     es, es:[2Ch]
        mov     ah, 49h
        int     21h
        mov     es, KEEP_PSP
        mov     ah, 49h
        int     21h
        STI
    end_ROUT:
        pop     es
        pop     ds
        pop     dx
        mov     ss, KEEP_SS
        mov     sp, KEEP_SP
        mov     ax, KEEP_AX
        iret
ROUT        ENDP

DEFINE_INTER        PROC
        push    dx
        push    ds
        mov     ah,35h
        mov     al,1Ch
        int     21h
        mov     KEEP_IP,bx
        mov     KEEP_CS,es
        mov     dx,offset ROUT
        mov     ax,seg ROUT
        mov     ds,ax
        mov     ah,25h
        mov     al,1Ch
        int     21h
        pop     ds
        mov     dx,offset LOAD
        call    Write_msg
        pop     dx
        ret
DEFINE_INTER        ENDP

MAIN        PROC        Far
        mov     ax,DATA
        mov     ds,ax
        mov     KEEP_PSP,es
        mov     ah,35h
        mov     al,1Ch
        int     21h
        mov     si, offset IDFN
        sub     si, offset ROUT
        mov     ax,'00'
        cmp     ax,es:[bx+si]
        jne     nt_ldd
        cmp     ax,es:[bx+si+2]
        je      ldd
    nt_ldd:
        call    DEFINE_INTER
        mov     dx,offset LAST_BYTE
        mov     cl,4H
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
        mov     al, es:[82h]
        cmp     al,'/'
        jne     nt_nld
        mov     al, es:[83h]
        cmp     al,'u'
        jne     nt_nld
        mov     al, es:[84h]
        cmp     al,'n'
        jne     nt_nld
        pop     ax
        pop     es
        mov     byte ptr es:[bx+si+10],1
        mov     dx,offset UNLOADED
        call    Write_msg
        jmp     it_is_over
    nt_nld:
        pop     ax
        pop     es
        mov     dx,offset ALREADY
        call    Write_msg
    it_is_over:
        xor     al,al
        mov     ah,4Ch
        int     21h
    LAST_BYTE:
MAIN ENDP
CODE ENDS

END MAIN
