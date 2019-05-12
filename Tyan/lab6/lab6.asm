CODE        SEGMENT

PARAM_BLOCK     db  14 dup(0)
FILE_PATH       db  70 dup(0)
KEEP_SS         dw  ?
KEEP_SP         dw  ?
POSITION        dw  0

ASSUME CS:CODE, DS:DATA, SS:AStack

AStack        SEGMENT        STACK
  DW           256           DUP(?)
AStack        ENDS

Write_msg        PROC        near
        push    ax
        mov     ah,09h
        int     21h
        pop     ax
        ret
Write_msg        ENDP

DATA        SEGMENT
ERROR_7         db  'Memory control block is destroyed.', 0dh, 0ah, '$'
ERROR_8         db  'Memory is not enought for function to be performed.', 0dh, 0ah, '$'
ERROR_9         db  'Wrong adress of memory block.', 0dh, 0ah, '$'
ERROR_1         db  'Wrong number of function.', 0dh, 0ah, '$'
ERROR_2         db  'File was not found.', 0dh, 0ah, '$'
ERROR_5         db  'Disk error.', 0dh, 0ah, '$'
ERROR_8_4Bh     db  'Memory is not enought.', 0dh, 0ah, '$'
ERROR_10        db  'Wrong environment string.', 0dh, 0ah, '$'
ERROR_11        db  'Wrong format.', 0dh, 0ah, '$'
FINISH_MSG      db  0dh, 0ah,'Program finished with code #  ',0dh, 0ah, '$'
FINISH_WITH_0   db  'Finished normaly.', 0dh, 0ah, '$'
FINISH_WITH_1   db  'Finished with Ctrl-Break', 0dh, 0ah, '$'
FINISH_WITH_2   db  'Finished with device error.', 0dh, 0ah, '$'
FINISH_WITH_3   db  'Finished with 31h function.', 0dh, 0ah, '$'
DATA         ENDS

Main        PROC
        mov     ax,DATA
        mov     ds,ax
        mov     ax,ALL_MEMORY
        mov     bx,es
        sub     ax,bx
        mov     cx,0004h
        shl     ax,cl
        mov     bx,ax
        mov     ax,4A00h
        int     21h
        jnc     is_perfomed_4Ah
        cmp     ax,07h
        je      error_num_7
        cmp     ax,08h
        je      error_num_8
        cmp     ax,09h
        je      error_num_9
    error_num_7:
        lea     dx,ERROR_7
        call    Write_msg
        jmp     it_is_over
    error_num_8:
        lea     dx,ERROR_8
        call    Write_msg
        jmp     it_is_over
    error_num_9:
        lea     dx,ERROR_9
        call    Write_msg
        jmp     it_is_over
    is_perfomed_4Ah:
        mov     byte ptr [PARAM_BLOCK],00h
        mov     es,es:[2Ch]
        mov     si,00h
    is_zero:
        mov     ax,es:[si]
        inc     si
        cmp     ax,0000h
        jne     is_zero
        add     si,03h
        mov     di,00h
    write_path:
        mov     cl,es:[si]
        cmp     cl,00h
        je      next
        cmp     cl,'\'
        jne     not_yet
        mov     POSITION,di
    not_yet:
        mov     byte ptr [FILE_PATH+DI],cl
        inc     si
        inc     di
        jmp     write_path
    next:
        mov     bx,POSITION
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'l'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'a'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'b'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'2'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'.'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'c'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'o'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'m'
        inc     bx
        mov     byte ptr [FILE_PATH+BX],'$'
        push    ds
        push    es
        mov     KEEP_SP, sp
        mov     KEEP_SS, ss
        mov     sp,0FEh
        mov     ax,CODE
        mov     ds,ax
        mov     es,ax
        lea     bx,PARAM_BLOCK
        lea     dx,FILE_PATH
        mov     ax,4B00h
        int     21h
        mov     ss,cs:KEEP_SS
        mov     sp,cs:KEEP_SP
        pop     es
        pop     ds
        jnc     is_performed_4Bh
        cmp     ax,01h
        je      error_num_1
        cmp     ax,02h
        je      error_num_2
        cmp     ax,05h
        je      error_num_5
        cmp     ax,08h
        je      error_num_8_4Bh
        cmp     ax,0Ah
        je      error_num_10
        cmp     ax,0Bh
        je      error_num_11
    error_num_1:
        lea     dx,ERROR_1
        call    Write_msg
        jmp     it_is_over
    error_num_2:
        lea     dx,ERROR_2
        call    Write_msg
        jmp     it_is_over
    error_num_5:
        lea     dx,ERROR_5
        call    Write_msg
        jmp     it_is_over
    error_num_8_4Bh:
        lea     dx,ERROR_8_4Bh
        call    Write_msg
        jmp     it_is_over
    error_num_10:
        lea     dx,ERROR_10
        call    Write_msg
        jmp     it_is_over
    error_num_11:
        lea     dx,ERROR_11
        call    Write_msg
        jmp     it_is_over
    is_performed_4Bh:
        mov     ax,4D00h
        int     21h
        mov     bx,ax
        add     bh,30h
        lea     di,FINISH_MSG
        mov     [di+29],bl
        lea     dx,FINISH_MSG
        call    Write_msg
        cmp     ah,00h
        je      finish_0
        cmp     ah,01h
        je      finish_1
        cmp     ah,02h
        je      finish_2
        cmp     ah,03h
        je      finish_3
    finish_0:
        lea     dx,FINISH_WITH_0
        call    Write_msg
        jmp     it_is_over
    finish_1:
        lea     dx,FINISH_WITH_1
        call    Write_msg
        jmp     it_is_over
    finish_2:
        lea     dx,FINISH_WITH_2
        call    Write_msg
        jmp     it_is_over
    finish_3:
        lea     dx,FINISH_WITH_3
        call    Write_msg
    it_is_over:
        mov     ah,4Ch
        int     21h
MAIN ENDP
CODE ENDS

ALL_MEMORY        SEGMENT
ALL_MEMORY        ENDS

END Main
