TESTPC    SEGMENT
        ASSUME    CS:TESTPC,    DS:TESTPC,    ES:NOTHING,    SS:NOTHING
        ORG        100H
START:    JMP        BEGIN

AVAIL_MEM       db      'Number of available memory:       B',0dh,0ah,'$'
WID_MEM         db      'Quantity of widened memory:       KB',0dh,0ah,'$'
BLOCK_CHAIN     db      'MCBs chain:',0dh,0ah,'$'
MCB_TYPE        db      'Type:     $'
MCB_OWN         db      'Owner:          $'
MCB_ADD         db      'Address:        $'
MCB_SIZE        db      'Size:            $'
MCB_TAIL        db      'Tail:               ',0dh,0ah,'$'

Write_msg    PROC    near
        mov    ah,09h
        int    21h
        ret
Write_msg    ENDP

TETR_TO_HEX        PROC    near
        and     al,0fh
        cmp     al,09
        jbe     NEXT
        add     al,07
    NEXT:
        add     al,30h
        ret
TETR_TO_HEX        ENDP

BYTE_TO_HEX        PROC near
        push    cx
        mov     ah,al
        call    TETR_TO_HEX
        xchg    al,ah
        mov     cl,4
        shr     al,cl
        call    TETR_TO_HEX
        pop     cx
        ret
BYTE_TO_HEX        ENDP

WRD_TO_HEX        PROC    near
        push    bx
        mov     bh,ah
        call    BYTE_TO_HEX
        mov     [di],ah
        dec     di
        mov     [di],al
        dec     di
        mov     al,bh
        call    BYTE_TO_HEX
        mov     [di],ah
        dec     di
        mov     [di],al
        pop     bx
        ret
WRD_TO_HEX        ENDP

WRD_TO_DEC        PROC    near
        push    cx
        push    dx
        push    ax
        mov     cx,10
    loop_wrd:
        div     cx
        or      dl,30h
        mov     [si],dl
        dec     si
        xor     dx,dx
        cmp     ax,10
        jae     loop_wrd
        cmp     ax,00h
        jbe     wrd_end
        or      al,30h
        mov     [si],al
    wrd_end:
        pop     ax
        pop     dx
        pop     cx
        ret
WRD_TO_DEC        ENDP

DEFINE_AVAIL_MEM    PROC    near
        push    ax
        push    bx
        push    si
        push    dx
	    push    cx
        mov     ah, 4Ah
        mov     bx, 0ffffh
        int     21h
        mov     ax, bx
        mov     cx, 16
        mul     cx
        mov     si, offset AVAIL_MEM
	    add     si, 33
        call    WRD_TO_DEC
        lea     dx, AVAIL_MEM
        call    Write_msg
        pop     dx
	    pop 	cx
        pop     si
        pop     bx
        pop     ax
        ret
DEFINE_AVAIL_MEM    ENDP

DEFINE_WID_MEM    PROC    near
        push    ax
        push    bx
        push    si
        push    dx
        mov     al, 30h
        out     70h, al
        in      al, 71h
        mov     bl, al
        mov     al, 31h
        out     70h, al
        in      al, 71h
	    xor     dx,dx
        mov     ah, al
        mov     al, bl
        mov     si, offset WID_MEM
	    add     si,33
        call    WRD_TO_DEC
        mov     dx, offset WID_MEM
        call    write_msg
        pop     dx
        pop     si
        pop     bx
        pop     ax
        ret
DEFINE_WID_MEM    ENDP

DEFINE_TAIL    PROC    near
        push    si
        push    cx
        push    bx
        push    ax
        mov     bx,0008h
        mov     cx,4
    cycle_tail:
        mov     ax,es:[bx]
        mov     [si],ax
        add     bx,2h
        add     si,2h
        loop    cycle_tail
        pop     ax
        pop     bx
        pop     cx
        pop     si
        ret
DEFINE_TAIL    ENDP

DEFINE_BLOCK_CHAIN    PROC  near
        push    ax
        push    bx
        push    cx
        push    dx
        lea     dx, BLOCK_CHAIN
        call    Write_msg
        mov     ah,52h
        int     21h
        mov     es,es:[bx-2]
        mov     bx,1
    cycle:
        xor     ax,ax
        xor     cx,cx
        xor     di,di
        xor     si,si
        mov     al,es:[0000h]
        call    BYTE_TO_HEX
        lea     di,MCB_TYPE+5
        mov     [di],ax
        cmp     ax,4135h
        je      last
    MCB_info:
        mov     ax,es
        lea     di, MCB_ADD+11
        call    WRD_TO_HEX
        lea     di,MCB_OWN+11
        mov     ax,es:[0001h]
        call    WRD_TO_HEX
        mov     ax,es:[0003h]
        mov     cx,10h
        mul     cx
        lea     si,MCB_SIZE+11
        call    WRD_TO_DEC
        lea     dx,MCB_ADD
        call    Write_msg
        lea     dx,MCB_OWN
        call    Write_msg
        lea     dx,MCB_SIZE
        call    Write_msg
        lea     si,MCB_TAIL+5
        call    DEFINE_TAIL
        lea     dx,MCB_TAIL
        call    Write_msg
        cmp     bx,0
        jz      done
        xor     ax, ax
        mov     ax, es
        add     ax, es:[0003h]
        inc     ax
        mov     es, ax
        jmp     cycle
    done:
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
    last:
        mov     bx,0
        jmp     MCB_info
DEFINE_BLOCK_CHAIN        ENDP

BEGIN:
        call    DEFINE_AVAIL_MEM
        call    DEFINE_WID_MEM
        call    DEFINE_BLOCK_CHAIN
        xor     al,al
        mov     ah,3Ch
        int     21h
    ret
TESTPC    ENDS
        END     START
