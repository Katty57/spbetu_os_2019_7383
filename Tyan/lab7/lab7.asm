AStack        SEGMENT         STACK
  DW           256            DUP(?)
AStack        ENDS

DATA		SEGMENT
ERROR_7         db  'Memory control block is destroyed.', 0dh, 0ah, '$'
ERROR_8         db  'Memory is not enought for function to be performed.', 0dh, 0ah, '$'
ERROR_9         db  'Wrong adress of memory block.', 0dh, 0ah, '$'
ERROR_1         db  'Function is not exist.', 0dh, 0ah, '$'
ERROR_2         db  'File was not found.', 0dh, 0ah, '$'
ERROR_3         db  'Path was not found.', 0dh, 0ah, '$'
ERROR_4         db  'There are too many opened files.', 0dh, 0ah, '$'
ERROR_5         db  'No acsess.', 0dh, 0ah, '$'
ERROR_8_4B03h   db  'Memory is not enought.', 0dh, 0ah, '$'
ERROR_10        db  'Wrong environment.', 0dh, 0ah, '$'
ERROR_2_4Eh     db  'File was not found. Error with 4Eh.', 0dh, 0ah, '$'
ERROR_3_4Eh     db  'Path was not found. Error with 4Eh.', 0dh, 0ah, '$'
MEM_ERR         db  'Error: too many big files.', 0dh, 0ah, '$'
ADDR_CALL       dd  0
DTA_BUF         db  43 dup (0), '$'
KEEP_PSP        dw  0
PARAM_BLOCK     dw  0
OVL_PATH        db  256    dup (0), '$'
FIRST_FILE      db  'ovl1.OVL',0
SECOND_FILE     db  'OVL2.OVL',0
DATA 		ENDS

CODE        SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:AStack

Write_msg        PROC        near
        push    ax
        mov     ah,09h
        int     21h
        pop     ax
        ret
Write_msg        ENDP

OVL_SIZE        PROC
        push    es
	    push    bx
	    push    si
	    push    ds
	    push    dx
	    mov     dx,seg DTA_BUF
	    mov     ds,dx
	    mov     dx,offset DTA_BUF
	    mov     ax,1A00h
	    int     21h
	    mov     cx,00h
	    mov     dx,seg OVL_PATH
	    mov     ds,dx
	    mov     dx,offset OVL_PATH
	    mov     ax,4E00h
	    int     21h
	    pop     dx
	    pop     ds
	    jnc     define_size
	    cmp     ax,2h
	    je      error_num_2_4Eh
	    cmp     ax,3h
	    je      error_num_3_4Eh
    error_num_2_4Eh:
	    lea     dx,ERROR_2_4Eh
	    call    Write_msg
	    jmp     func_end
    error_num_3_4Eh:
	    lea     dx,ERROR_3_4Eh
	    call    Write_msg
	    jmp     func_end
    define_size:
	    push    es
	    push    bx
	    push    si
	    mov     si,offset DTA_BUF
	    add     si,1Ch
	    mov     bx,[si]
	    cmp     bx,000Fh
	    jg      got_mem_err
	    sub     si,2
	    mov     bx,[si]
	    push    cx
	    mov     cl,4h
	    shr     bx,cl
	    mov     ax,[si+2]
	    mov     cl,0Ch
	    sal     ax,cl
	    pop     cx
	    add     bx,ax
	    add     bx,2
	    mov     ax,4800h
	    int     21h
	    mov     PARAM_BLOCK,ax
	    pop     si
	    pop     bx
        pop     es
	    jmp     func_end
    got_mem_err:
	    lea     dx,MEM_ERR
	    call    Write_msg
    func_end:
	    pop     si
	    pop     bx
	    pop     es
	    ret
OVL_SIZE        ENDP

DEFINE_PATH        PROC
	    push    ax
	    push    bx
	    push    cx
	    push    dx
	    push    si
	    push    di
	    push    es
	    mov     es,KEEP_PSP
	    mov     ax,es:[2Ch]
	    mov     es,ax
	    mov     bx,0h
	    mov     cx,2h
    envir_path:
	    inc     cx
	    mov     al,es:[bx]
	    inc     bx
	    cmp     al,00h
	    jz 	    envir_path_preend
	    loop    envir_path
    envir_path_preend:
	    cmp     byte ptr es:[bx],00h
	    jnz     envir_path
	    add     bx,3
	    lea     si,OVL_PATH
        path:
	    mov     al,es:[bx]
	    mov     [si],al
	    inc     si
	    inc     bx
	    cmp     al,00h
	    jz 	    end_path
	    jmp     path
    end_path:
	    sub     si,9
	    mov     di,bp
    replace_loop_path_locate:
	    mov     ah,[di]
	    mov     [si],ah
	    cmp     ah,0h
	    jz 	    end_rep_path
	    inc     di
	    inc     si
	    jmp     replace_loop_path_locate
    end_rep_path:
	    pop     es
	    pop     di
	    pop     si
	    pop     dx
	    pop     cx
	    pop     bx
	    pop     ax
	    ret
DEFINE_PATH        ENDP

CALL_OVL        PROC
	    push    ax
	    push    bx
	    push    cx
	    push    dx
	    push    bp
	    mov     bx,seg PARAM_BLOCK
	    mov     es,bx
	    mov     bx,offset PARAM_BLOCK
	    mov     dx,seg OVL_PATH
	    mov     ds,dx
	    mov     dx,offset OVL_PATH
	    push    ss
	    push    sp
	    mov     ax,4B03h
	    int     21h
	    jnc     is_performed_4B03h
	    cmp     ax,01h
	    je      error_num_1
	    cmp     ax,02h
	    je      error_num_2
	    cmp     ax,03h
	    je      error_num_3
	    cmp     ax,04h
	    je      error_num_4
	    cmp     ax,05h
	    je      error_num_5
	    cmp     ax,08h
	    je      error_num_8_4B03h
	    cmp     ax,0Ah
	    je      error_num_10
	    jmp     call_ovl_end
    error_num_1:
	    lea     dx,ERROR_1
	    call    Write_msg
	    jmp     call_ovl_end
    error_num_2:
	    lea     dx,ERROR_2
	    call    Write_msg
	    jmp     call_ovl_end
    error_num_3:
	    lea     dx,ERROR_3
	    call    Write_msg
	    jmp     call_ovl_end
    error_num_4:
	    lea     dx,ERROR_4
	    call    Write_msg
	    jmp     call_ovl_end
    error_num_5:
	    lea     dx,ERROR_5
	    call    Write_msg
	    jmp     call_ovl_end
    error_num_8_4B03h:
	    lea     dx,ERROR_8_4B03h
	    call    Write_msg
	    jmp     call_ovl_end
    error_num_10:
	    lea     dx,ERROR_10
	    call    Write_msg
	    jmp     call_ovl_end
    is_performed_4B03h:
	    mov     ax,seg DATA
	    mov     ds,ax
	    mov     ax,PARAM_BLOCK
	    mov     word ptr ADDR_CALL+2,ax
	    call ADDR_CALL
	    mov     ax,PARAM_BLOCK
	    mov     es,ax
	    mov     ax,4900h
	    int     21h
	    mov     ax,seg DATA
	    mov     ds,ax
    call_ovl_end:
	    pop     sp
	    pop     ss
	    mov     es,KEEP_PSP
	    pop     bp
	    pop     dx
	    pop     cx
	    pop     bx
	    pop     ax
	    ret
CALL_OVL        ENDP

Main        PROC
	    mov     ax,seg DATA
	    mov     ds,ax
	    mov     KEEP_PSP,es
	    mov     ax,ALL_MEMORY
	    mov     bx,es
	    sub     ax,bx
	    mov     cx,0004h
	    shr     ax,cl
	    mov     bx,ax
	    mov     ax,4A00h
	    int     21h
	    jnc     is_performed_4Ah
	    cmp     ax,07h
	    je      error_num_7
	    cmp     ax,08h
	    je      error_num_8
	    cmp     ax,09h
	    je      error_num9
    error_num_7:
	    lea     dx,ERROR_7
	    call    Write_msg
	    jmp     it_is_over
    error_num_8:
	    lea     dx,ERROR_8
	    call    Write_msg
	    jmp     it_is_over
    error_num9:
	    lea     dx,ERROR_9
	    call    Write_msg
	    jmp     it_is_over
    is_performed_4Ah:
	    lea     bp,FIRST_FILE
	    call    DEFINE_PATH
	    call    OVL_SIZE
	    call    CALL_OVL
	    lea     bp,SECOND_FILE
	    call    DEFINE_PATH
	    call    OVL_SIZE
	    call    CALL_OVL
    it_is_over:
	    mov     ah,4Ch
	    int     21h
Main 	ENDP
CODE ENDS

ALL_MEMORY	SEGMENT
ALL_MEMORY  ENDS

END MAIN
