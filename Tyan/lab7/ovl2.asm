OVL SEGMENT

	ASSUME CS:OVL, DS:NOTHING, SS:NOTHING, ES:NOTHING

Main        PROC        FAR
push    ds
push    ax
push    di
push    dx
push    bx
mov     ds,ax
lea     dx,cs:MSG
call    Write_msg
lea     bx,cs:ADDRESS
add     bx,41
mov     di,bx
mov     ax,cs
call    WRD_TO_HEX
lea     dx,cs:ADDRESS
call    Write_msg
pop     bx
pop     dx
pop     di
pop     ax
pop     ds
retf
Main        ENDP

MSG         db  10, 13, 'Second overlay was called.', 10, 13, '$'
ADDRESS     db  'Segment address of the second overlay:     ', 10, 13, '$'

Write_msg        PROC         near
        push    ax
        mov     ah,09h
        int     21h
        pop     ax
        ret
Write_msg        ENDP

TETR_TO_HEX        PROC        near
        and     AL,0Fh
        cmp     AL,09
        jbe     NEXT
        add     AL,07
    NEXT:
        add     AL,30h
        ret
TETR_TO_HEX        ENDP

BYTE_TO_HEX        PROC        near
;Байт в AL переводится в два шестнадцатеричных символа в AX
        push    CX
        mov     AH,AL
        call    TETR_TO_HEX
        xchg    AL,AH
        mov     CL,4
        shr     AL,CL
        call    TETR_TO_HEX ; в AL - старший байт
        pop     CX ;в AH - младший
        ret
BYTE_TO_HEX        ENDP

WRD_TO_HEX        PROC        near
;перевод в шестнадцатеричную систему счисления числа в AX
; в AX - номер, в DI - ссылка на последний символ
        push    BX
        mov     BH,AH
        call    BYTE_TO_HEX
        mov     [DI],AH
        dec     DI
        mov     [DI],AL
        dec     DI
        mov     AL,BH
        call    BYTE_TO_HEX
        mov     [DI],AH
        dec     DI
        mov     [DI],AL
        pop     BX
        ret
WRD_TO_HEX ENDP

OVL ENDS
END MAIN
