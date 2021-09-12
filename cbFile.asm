section	.text
   global _start   ;must be declared for linker (ld)
	
_start:	; Start deberia abrir el archivo y almacenar contadores y punteros en registros
 		
        ; Preparing registers
        mov r9, circbuffer      ; start of the buffer (should not be eax)
        mov r10, 3              ; k elements
        mov r11, 0              ; flag


        ;Opening the file
        mov eax, 5              ; Sys_open instruction
        mov ebx, filename       ; Passing the filename
        mov rcx, 0              ; 
        mov rdx, 0777           ; Permissions
        
        int 0x80                ; Syscall

        mov rdi, rax            ; rax holds the fd after open operation
        mov r12, 0              ; offset to read chunks of data

updatePos:
        
        mov rax, 8              ; Lseek to update file pointer
        mov rsi, r12            ; How many bits ahead 
        mov rdx, 0              ; Offset (Keep at 0 to begin at the start)
        syscall

        add r12, 5              ; Setting off-set to read the next word

read:

        ;Reading from the file
          
        
        mov rax, 3              ; Store the sys_read in rax
        mov rbx, rdi            ; we store the fd in rbx
        mov ecx, text           ; We store the file to the buffer 
        mov edx, 4              ; Indicating the number of bits to read
        int 0x80                ; Syscall
        
        mov edx, text           ; String representation of X(n)
        mov r13, 4              ; Number of bits 
        call atoi               ; converting the string to a HEX number
filling:      
        ;
        ; Aqui se procesa cada elemento de 0 a k
        ; El numero se encuentra en RAX despues del atoi
        ;
        ;
        mov [r9], rax           ; storing the value into the buffer
        add r9, 8               ; Moving the pointer to the next element of the buffer
        dec r10                 ; One element was written

        cmp r10, 0              ; Checking if we reached k
        je writeNext            ; If at k index, call re-start

        jmp updatePos           ; If not at k index we keep reading/inserting normally

writeNext:
        
        mov r9, circbuffer      ; Setting the pointer to the start of the buffer
        mov r10, 2              ; Resetting the amount of numbers to be read (k)
        cmp r11, 1              ; Checking if we finished reading the file
        je end

        add r11, 1              ; 
        jmp updatePos           ; With everything ready, go back to reading and writting
        

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
        dec r13
        jmp .top ; until done

.fix: 
        sub ecx, 55     ; Accounting for the character in between
        imul eax, 16    ; multiplu "result so far" by the base
        add eax, ecx    ; add in current digit
        dec r13
        jmp .top        ; go back to loop 

.done:
        ret
        

end:
        mov r9, 1
        int 0x80

section .data
            filename db "test.txt",0

section	.bss
        text resw 2
        circbuffer resw 4 ;k
        