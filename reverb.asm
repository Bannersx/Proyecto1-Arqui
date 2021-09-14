
section	.text
   global _start   ;must be declared for linker (ld)
	
_start:	; Start deberia abrir el archivo y almacenar contadores y punteros en registros
 		
        ; Preparing registers
        mov r9, circbuffer      ; start of the buffer (should not be eax)
        mov r10, 2205              ; k elements
        mov r14, 0              ; flag to indicate we reached k
        mov r15, filename
        mov r12, 0              ; offset to read chunks of data
        mov r8, converted


updatePos:

        ;Opening the file
        mov eax, 5              ; Sys_open instruction
        mov ebx, filename       ; Passing the filename
        mov ecx, 0              ; 
        mov edx, 0777           ; Permissions
        
        int 0x80                ; Syscall

        mov edi, eax            ; rax holds the fd after open operation
        mov [fd_out],eax        ; Storing the fd


        ; Lseek
        mov eax, 8              ; Lseek to update file pointer
        mov rsi, r12            ; How many bits ahead we read 
        mov edx, 0              ; Offset (Keep at 0 to begin at the start)
        syscall

read:
        add r12, 5              ; Setting off-set to read the next word
        ;Reading from the file
          
        
        mov eax, 3              ; Store the sys_read in rax
        mov ebx, edi            ; we store the fd in rbx
        mov ecx, text           ; We store the file to the buffer 
        mov edx, 4              ; Indicating the number of bits to read
        int 0x80                ; Syscall

        cmp eax, 0              ; When sys_read has nothing left to read it returns a 0 in rax
        je end

        ; Closing the file
        mov eax, 6              ; Sys_close 
        mov ebx, [fd_out]       ; Passing the fd
        int 0x80                ; System interrupt

        mov edx, text           ; String representation of X(n)
        mov r13, 4              ; Number of bits 
        call atoi               ; converting the string to a HEX number
filling:      
        ;
        ; Aqui se procesa cada elemento de 0 a k
        ; El numero se encuentra en RAX despues del atoi
        call processSample
        ;
        mov [r9], eax           ; storing the value into the buffer     ---- RAX will eventually change to whichever buffer/register holds the value after the operation
        dec r10                 ; One element was written

     ;--------- Writting to the file --------------------------------------------------------   ----------

        ; Opening or creating the file.
        mov   eax, 2
        lea   edi, output
        mov   esi, 0x441        ; O_CREAT| O_WRONLY | O_APPEND
        mov   edx, 0q666        ; octal permissions in case O_CREAT has to create it
        syscall
        mov   [fd_in], eax      ; save the file descriptor

        ;Converting the num to string
        mov eax, [r9]                   ; The number i want to convert (Using eax for 32bits)
        mov ebx, converted              ; Location where the character will be stored
        mov ecx, 16                     ; Base
        and dword [converted], 0    ; cleaning the buffer
.tag2:       
        call __itoa

        mov r8,[converted]   
        
        cmp r8, 0x47   ;Checking if its one char only
        jnge .oneChar

        cmp r8, 0x4647    ;Checking if its 2 chars
        jnge .twoChar

        cmp r8, 0x464647    ;Checking if its 3 chars 
        jnge .threeChar

        jmp tag

.oneChar:
         ; write into the file
        mov	edx, 1           ; number of bytes
        mov	ecx, converted  ; message to write
        mov	ebx, [fd_in]       ; file descriptor  ---> Segfault Here
        mov	eax, 4           ; system call number (sys_write)
        int	0x80             ; call kernel
        ; spacing
        mov eax, 4
        mov ebx, [fd_in]
        mov ecx, spc
        mov edx, len_spc
        int 0x80
        
        ; close the file
        mov eax, 6
        mov ebx, [fd_in]
        int  0x80    

     ;---------------------------------------------------------------------------------------
        cmp r10, 0              ; Checking if we reached k
        je writeNext            ; If at k index, call re-start

        add r9, 4               ; Moving the pointer to the next element of the buffer
        jmp updatePos           ; If not at k index we keep reading/inserting normally
.twoChar:
         ; write into the file
        mov	edx, 2           ; number of bytes
        mov	ecx, converted  ; message to write
        mov	ebx, [fd_in]       ; file descriptor  ---> Segfault Here
        mov	eax, 4           ; system call number (sys_write)
        int	0x80             ; call kernel
        ; spacing
        mov eax, 4
        mov ebx, [fd_in]
        mov ecx, spc
        mov edx, len_spc
        int 0x80
        
        ; close the file
        mov eax, 6
        mov ebx, [fd_in]
        int  0x80    

        mov r8, [converted]


     ;---------------------------------------------------------------------------------------
        cmp r10, 0              ; Checking if we reached k
        je writeNext            ; If at k index, call re-start

        add r9, 4               ; Moving the pointer to the next element of the buffer
        jmp updatePos           ; If not at k index we keep reading/inserting normally

.threeChar:
         ; write into the file
        mov	edx, 3           ; number of bytes
        mov	ecx, converted  ; message to write
        mov	ebx, [fd_in]       ; file descriptor  ---> Segfault Here
        mov	eax, 4           ; system call number (sys_write)
        int	0x80             ; call kernel
        ; spacing
        mov eax, 4
        mov ebx, [fd_in]
        mov ecx, spc
        mov edx, len_spc
        int 0x80
        
        ; close the file
        mov eax, 6
        mov ebx, [fd_in]
        int  0x80    

  ;---------------------------------------------------------------------------------------
        cmp r10, 0              ; Checking if we reached k
        je writeNext            ; If at k index, call re-start

        add r9, 4               ; Moving the pointer to the next element of the buffer
        jmp updatePos           ; If not at k index we keep reading/inserting normally

tag:
                    
        
        ; write into the file
        mov	edx, 4           ; number of bytes
        mov	ecx, converted  ; message to write
        mov	ebx, [fd_in]       ; file descriptor  ---> Segfault Here
        mov	eax, 4           ; system call number (sys_write)
        int	0x80             ; call kernel

        ; spacing
        mov eax, 4
        mov ebx, [fd_in]
        mov ecx, spc
        mov edx, len_spc
        int 0x80
        
        ; close the file
        mov eax, 6
        mov ebx, [fd_in]
        int  0x80    

    ;---------------------------------------------------------------------------------------
        cmp r10, 0              ; Checking if we reached k
        je writeNext            ; If at k index, call re-start

        add r9, 4               ; Moving the pointer to the next element of the buffer
        jmp updatePos           ; If not at k index we keep reading/inserting normally

writeNext:
        
        mov r9, circbuffer      ; Setting the pointer to the start of the buffer 0x40009----> 0x40009+2205
        mov r10, 2205              ; Resetting the amount of numbers to be read (k)

        mov r14, 1              ; Flag para indicar que ya lei k elementos
        jmp updatePos           ; With everything ready, go back to reading and writting

;@**************************************************************************************@
;----------------------------------- Processing ----------------------------------------  

processSample:      ; Reverb
        cmp r14, 1              ; Check if we filled the buffer already
        jnz .complete

        ; processing the first k elements 
        mov r8, 0x100  ; One
        mov r11, 0x99 ; alpha
        sub r8, r11  ; (1-alpha)
        
        ;Fixed point multiplication
        mul r8
        shrd eax, edx, 16
        adc eax, 0

        ; Handling overflow
        cmp eax, 65535
        jg .saturate

        jmp .done

.complete:
        ; processing the rest of the elements 
        mov r8, 256  ; One
        mov r14, 153 ; alpha
        sub r8, r14
        
        ; Fixed point mult
        mul r8       ; rax will hold the value or (1-alpha)*x(n)
        shr eax, 8
        adc eax, 0

        mov r8, rax  ; 
        mov rax, [r9] ; Loading y(n-k)
        
        ; Fxp mult
        mul r14    ; alpha*y(n-k)
        shr eax, 8
        adc eax, 0

        add rax, r8  ; (1-alpha)*x(n) + alpha*y(n-k)
        
        ; Handling Overflow
        cmp eax, 65535
        jg .saturate

        jmp .done

.saturate:
        mov eax, 0x7FFF
        jmp .done
.done:
        ret

;---------------------------------------------------------------------------------------
;@**************************************************************************************@
;------------------------------ Multiplication ------------------------------------------       


;---------------------------------------------------------------------------------------
;@**************************************************************************************@
;--------------------------------------- Atoi ------------------------------------------       

atoi:
        xor eax, eax ; zero a "result so far"
.top:
        cmp r13, 0 ; Checking if we reached the end of the word
        je .done

        movzx ecx, byte [edx] ; get a character
        inc edx ; ready for next one

        cmp ecx, 57  ; Checking if the character is a letter
        jg .fix

        jmp .digit      ; If its a digit we can transform it

.digit:
        cmp ecx, '0' ; valid?
        jb .done
        cmp ecx, '9'
        ja .done
        sub ecx, '0' ; "convert" character to number
        imul eax, 16 ; multiply "result so far" by the base
        add eax, ecx ; add in current digit
        dec r13      ; One character read
        jmp .top ; until done

.fix: 
        sub ecx, 55     ; Accounting for the character in between
        imul eax, 16    ; multiply "result so far" by the base
        add eax, ecx    ; add in current digit
        dec r13         ; One character read
        jmp .top        ; go back to loop 

.done:
        ret


doneReading:
        

        ; Do whatever w

;@**************************************************************************************@
;--------------------------------------- ITOA ------------------------------------------

;   Code taken from: https://gist.github.com/SplittyDev/8e728627012e57ac0deac196660014fb
;   Author: Marco Quinten (SplittyDev)
;   Modified by: Alex Marin (Bannersx)
;   Date of change: 8.9.21 (D.M.Y)

; Routine to convert a 64-bit integer to a string.
; Registers are preserved.
;
; EAX: Source integer
; EBX: Target address
; ECX: Base
;
; Internal register layout:
; start:
; EAX: Source integer
; ECX: Target address
; EDX: Base
; checknegative:
; EAX: Source integer
; EBX: Target address (original)
; ECX: Target address (active)
; divrem:
; EAX: Source integer
; ECX: Target address (active)
; EDX: Base / Result
; reverse:
; EBX: Target address (original)
; ECX: Target address (active)
; EDX: Target address (temporary)
;
__itoa:
.start:
        push rax
        push rbx
        push rcx
        push rdx
        mov rdx, rcx
        mov rcx, rbx
.checknegative:
        test rax, rax
        jns .divrem
        mov byte [rcx], 0x2D
        inc rcx
        mov rbx, rcx
        neg rax
.divrem:
        push rdx
        push rcx
        mov rcx, rdx
        xor rdx, rdx
        div rcx
        mov byte dl, [__itoacvt + rdx]
        pop rcx
        mov byte [rcx], dl
        pop rdx
        inc rcx
        cmp rax, 0x00
        jne .divrem
        mov byte [rcx], 0x00
        dec rcx
.reverse:
        cmp rbx, rcx
        jge .end
        mov byte dl, [rbx]
        mov byte al, [rcx]
        mov byte [rbx], al
        mov byte [rcx], dl
        inc rbx
        dec rcx
        jmp .reverse
.end:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
;---------------------------------------------------------------------------------------    

end:
        mov rax, 1      ; Sys_exit
        int 0x80        ; System interrupt

section .data
        ;
        ; Conversion table for __itoa.
        ; Works for bases [2 ... 36].
        ;
        __itoacvt:
                db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        
        ;alpha = 0x0099
        ;(1-alpha) = 0x0066
        spc: db " "                  ; To divide the file
        len_spc equ $-spc            ; size of the label
        filename db "MuestreoHex.txt",0     ; Name of the input file
        output: db "out.txt", 0      ; Name of the output file

section	.bss
        text resw 2          ; Buffer that holds the numeric value read from the sample file
        a resw 5
        fd_out resb 1        ; File descriptor for the file we read OUT of
        b resw 5
        fd_in resb 1         ; File descriptor for the file we wrint IN
        c resw 5
        sfg2 resw 10
        converted resw 2     ; Buffer used to write to file. Holds the ascii value of the processed value
        sfg3 resw 10    
        circbuffer resw 5000    ; Circular buffer of size k = Fs * 50ms