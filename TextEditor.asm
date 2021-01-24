;@Author    	MEHRAN JAVID
;@Copyright 	Copyright (C) 2021

[org 100h]

jmp start 
;------------------------------global variables--------------------------------------------------------------
character db 'a'
row: db 0
col: db 0
boolNewline: db 0

;-----------------------------Starting of Program-----------------------------------------------------------------
start: 
call clearScreen

	push cs						; value to be displayed is in codesegment
	pop es
	mov bp, character			; address of character
	mov dl, [col]				; col
	mov dh, [row]				; row
	mov ah,2  
	int 10h

;--------------------------Main Execution starts here-----------------------------------------------------
ResetCol:

	mov dl, [col]				; col
	mov dh, [row]				; row
	mov bh, 0					; page 0, means first page
	mov bl, 0x70				; set attribute bit 1 of AL is zero
	mov cx, 1 					; message size 

		mov al,[boolNewline]		;Boolean value being used to display character on new line
		cmp al, 0
		je Start2

		mov al, 0
		mov [boolNewline], al
		mov al, [character]
		call Print

Start2:
	mov ah, 0
	int 16h 							; wait for any key....

		cmp ah, 0x48 				; if key is 'up'.
		je moveUp
		cmp ah, 0x50 				; if key is 'down'.
		je moveDown
		cmp ah, 0x4B 				; if key is 'left'.
		je moveLeft
		cmp ah, 0x4D 				; if key is 'right'.
		je moveRight

		cmp ah, 0x0E 				; if key is 'BackSpace'.
		je moveBack

		cmp al, 27 					; if key is 'esc' then exit.
		je stop

		cmp al, 0xD 				; if key is 'Enter' then Newline.
		je Newline

		cmp dl, 79
		je CheckNewline

	call Print

SkipPrint:

jmp Start2

;------------------------------------Ends Here---------------------------------------------------
stop:
 
mov ax,0x4c00
int 21h 
;------------------------------------------------------------------------------------------------

;------------------------------All Functions Are Below-------------------------------------------

moveUp: ;------------------------------Function 1------------------------------------------

			mov bh, 0
			mov ah, 03h
			INT 10h 						; gets cursor position

			cmp dh, 0
			je skipUp

			sub dh, 1					; decrements row
			mov [row], dh
			mov [col], dl

			mov ah,2  
			int 10h						; sets new cursor position

		skipUp:
	jmp ResetCol

moveDown:;------------------------------Function 2------------------------------------------

			mov bh, 0
			mov ah, 03h
			INT 10h 						; gets cursor position

			cmp dh, 24
			jge skipDown

			add dh, 1					; increments row
			mov [row], dh
			mov [col], dl

			mov ah,2  
			int 10h						; sets new cursor position

		skipDown:
	jmp ResetCol

moveLeft:;------------------------------Function 3------------------------------------------

			mov bh, 0
			mov ah, 03h
			INT 10h 						; gets cursor position

			cmp dl, 0
			je skipLeft

			sub dl, 1					; decrements col
			mov [col], dl
			mov dh, [row]

			mov ah,2  
			int 10h						; sets new cursor position

		skipLeft:
	jmp ResetCol

moveRight:;------------------------------Function 4------------------------------------------

			mov bh, 0
			mov ah, 03h
			INT 10h 						; gets cursor position

			cmp dl, 79
			jge skipRight

			add dl, 1					; increments col
			mov [col], dl
			mov dh, [row]

			mov ah,2  
			int 10h						; sets new cursor position

		skipRight:
	jmp ResetCol

Newline:;------------------------------Function 5------------------------------------------

			mov bh, 0
			mov ah, 03h
			INT 10h 						; gets cursor position

			add dh, 1					; increments row
			mov [row], dh
			mov dl, 0
			mov [col], dl

			mov ah,2  
			int 10h						; sets new cursor position

	jmp ResetCol

Print:;------------------------------Function 6------------------------------------------
		
		mov [character], al
		mov al, 17;						; set attribute
		mov ah, 13h
		int 10h
		inc dl
	ret

CheckNewline:;------------------------------Function 7------------------------------------------
		
		cmp dh, 24
		jge ResetCol

		mov bh, 1
		mov [boolNewline], bh 
		mov [character], al
		 
	jmp Newline

moveBack:;------------------------------Function 8------------------------------------------
		
			mov bh, 0
			mov ah, 03h
			INT 10h 						; gets cursor position

			cmp dl, 0
			je skipBack

			sub dl, 1					; decrements col

			mov al, ' '
			mov [character], al 
			mov bh, 0					; page 0, means first page
			mov bl, 0x70				; set attribute bit 1 of AL is zero
			mov cx, 1 

			call Print

			sub dl, 1					; decrements col

			mov [col], dl
			mov dh, [row]

			mov ah,2  
			int 10h						; sets new cursor position

		skipBack:

	jmp ResetCol

clearScreen:;------------------------------Function 9------------------------------------------

		pusha
		 push 0xb800
		 pop es
		 mov ah, 0x70
		 mov al, ' '
		 mov si, 2000
		 mov di, 0

		 loopClearScreen:
				STOSW
				sub si, 1
				cmp si, 0
		jne loopClearScreen
		
		popa
	ret