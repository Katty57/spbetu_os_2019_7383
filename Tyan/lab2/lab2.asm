TESTPC	SEGMENT
		ASSUME	CS:TESTPC,	DS:TESTPC,	ES:NOTHING,	SS:NOTHING
		ORG		100H
START:	JMP		BEGIN

INASSEC_MEM         db      'Segment adress of inasseced memory:    ',0dh,0ah,'$'
ENVIR_MEM           db      'Address of environment:       ',0dh,0ah,'$'
TAIL                db      'Tail: ',0dh,0ah,'$'
EMPTY               db      'Tail is empty.',0dh,0ah,'$'
CONTENT             db      'Content of environment: $'
PATH                db        'Way to module: ' , '$'
ENT                 db        13,10,'$'
ENDL                db        0dh,0ah,'$'

Write_msg        PROC    near
mov        ah,09h
int        21h
ret
Write_msg        ENDP

SLASHN        PROC    near
lea        dx,ENDL
call    Write_msg
ret
SLASHN        ENDP

TETR_TO_HEX        PROC    near
and        al,0fh
cmp        al,09
jbe        NEXT
add        al,07
NEXT:    add        al,30h
ret
TETR_TO_HEX        ENDP

BYTE_TO_HEX        PROC near
push    cx
mov        al,ah
call    TETR_TO_HEX
xchg    al,ah
mov        cl,4
shr        al,cl
call    TETR_TO_HEX
pop        cx
ret
BYTE_TO_HEX        ENDP

WRD_TO_HEX        PROC    near
push    bx
mov        bh,ah
call    BYTE_TO_HEX
mov        [di],ah
dec        di
mov        [di],al
dec        di
mov        al,bh
xor        ah,ah
call    BYTE_TO_HEX
mov        [di],ah
dec        di
mov        [di],al
pop        bx
ret
WRD_TO_HEX        ENDP

BEGIN:

push di
push ax
push dx
push es
push bx

call    SLASHN

lea di,INASSEC_MEM
add di,39
mov ax,es:[2]
call WRD_TO_HEX
lea dx,INASSEC_MEM
call Write_msg
call    SLASHN

sub ax,ax
lea di,ENVIR_MEM
add di,27
mov ax,es:[2ch]
call WRD_TO_HEX
lea dx,ENVIR_MEM
call Write_msg
call    SLASHN

push cx
push si
xor ax, ax
xor cx, cx
mov cl, es:[80h]
cmp cl, 00h
je is_empty
mov dx,offset TAIL;was ax
call Write_msg
mov si, 81h
mov ah, 02h
cycle: mov dl, es:[si]
int 21h
inc si
loop cycle
tail_is_read:
call SLASHN
jmp next_step
is_empty:mov al, 00h
mov [di],al
mov dx, offset EMPTY
call Write_msg

next_step:
call    SLASHN
mov dx, offset CONTENT
call Write_msg
mov        bx,1
mov        es,es:[2ch]
mov        si,0
remem:
call    SLASHN
mov        ax,si
mem:
cmp     byte ptr es:[si], 0
je         end_of_el
inc        si
jmp     mem
end_of_el:
push    es:[si]
mov        byte ptr es:[si], '$'
push    ds
mov        cx,es
mov        ds,cx
mov        dx,ax
call    Write_msg
pop        ds
pop        es:[si]
cmp        bx,0
jz         the_end
inc        si
cmp     byte ptr es:[si], 01h
jne     remem
call    SLASHN
lea        dx,PATH
call    Write_msg
mov        bx,0
add     si,2
jmp     remem
the_end:
call    SLASHN
pop        cx
pop        bx
pop        ax
pop        es
pop        dx
pop        si
pop        di

xor        al,al
mov     ah, 01h
int        21h
mov     ah, 04Ch
int     21h

TESTPC    ENDS
END     START
