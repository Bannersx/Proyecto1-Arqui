section	.text
   global _start         ;must be declared for using gcc
	
_start:                  ;tell linker entry point
       
   ; Opening or creating the file.

   mov word [info], 49

   mov   rax, 2
   lea   rdi, file_name
   mov   rsi, 0x441        ; O_CREAT| O_WRONLY | O_APPEND
   mov   edx, 0q666        ; octal permissions in case O_CREAT has to create it
   syscall
   mov   r15, rax      ; save the file descriptor
	
   mov  [fd_in], eax

   ; writing to the file 
   mov eax, 4
   mov ebx, [fd_in]
   mov ecx, msg
   mov edx, len
   int 0x80
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
	

   mov	eax,1             ;system call number (sys_exit)
   int	0x80              ;call kernel
section	.data
msg: db "hello!"
len equ $-msg
spc: db " "
len_spc equ $-spc
file_name: db 'myfile.txt',0

section .bss
fd_out resb 1
fd_in  resb 1
info resb  26
