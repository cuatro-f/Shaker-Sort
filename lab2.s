bits 64

section .data
rows equ 5
cols equ 4

row1 dw 6, -3, 3432, 52
row2 dw 3, 4324, 312, 0
row3 dw -432, -13, -12, -31125
row4 dw 32, 2424, 54, 4325
row5 dw 453, 53, 25353, 534
matrix dq row1, row2, row3, row4, row5
tops times rows dw 0
tmp dw 0 
tmp_address dq 0 

temp_buffer times rows*cols dw 0     ; buffer for initial data
original_rows dq row1, row2, row3, row4, row5 ; initial rows addresses

section .text
global _start

_start:
    ; save initial data in temp_buffer
    mov r8, original_rows       ; pointer to original_rows
    mov rdi, temp_buffer        ; pointer to temp_buffer
    mov rcx, rows
    cld ; flag DF = 0

save_loop:
    push rcx                    ; save counter
    mov rsi, [r8]
  ; mov rax, [r8]               ; address of string (row1, row2...)
    add r8, 8                   ; next elem in original_rows
    ; mov rsi, rax                ; data source for rep
    mov rcx, cols               ; counter for rep
    rep movsw                   ; copy rcx * wordsize into temp_buffer (rdi)
                                ; from row address (rsi)
    pop rcx                     ; restore counter
    loop save_loop

    mov ecx, rows
    lea rsi, [matrix]

outer_loop:
    push rcx
    mov rdi, [rsi]
    add rsi, 8
    mov ax, 0x8000
    mov rcx, cols

find_max:
    mov dx, [rdi]
    add rdi, 2
    cmp dx, ax
    jle skip_update
    mov ax, dx

skip_update:
    loop find_max
    pop rcx
    mov rbx, rows
    sub rbx, rcx
    shl rbx, 1
    mov [tops + rbx], ax
    loop outer_loop

shaker_sort:
    mov ecx, rows
    cmp ecx, 1
    je sorted
    dec ecx
    mov r13, 0

first_loop:
    mov esi, r13d 
    mov ebx, 0 

forward:
    mov ax, [tops + esi * 2]
    mov dx, [tops + (esi + 1) * 2]
    cmp ax, dx
    jle no_swap 
    mov [tmp], ax
    mov [tops + esi * 2], dx
    mov dx, [tmp]
    mov [tops + (esi + 1) * 2], dx
    mov r14, [matrix + esi * 8]
    mov r15, [matrix + (esi + 1) * 8]
    mov [tmp_address], r14
    mov [matrix + esi * 8], r15
    mov r15, [tmp_address]
    mov [matrix + (esi + 1) * 8], r15
    inc ebx 

no_swap:
    inc esi 
    cmp esi, ecx 
    jl forward 
    dec ecx 
    cmp ebx, 0
    je sorted 
    mov esi, ecx 
    mov ebx, 0 

backward:
    mov ax, [tops + esi * 2]
    mov dx, [tops + (esi - 1) * 2]
    cmp dx, ax
    jle no_swap_back 
    mov [tmp], ax
    mov [tops + esi * 2], dx
    mov dx, [tmp]
    mov [tops + (esi - 1) * 2], dx
    mov r14, [matrix + esi * 8]
    mov r15, [matrix + (esi - 1) * 8]
    mov [tmp_address], r14
    mov [matrix + esi * 8], r15
    mov r15, [tmp_address]
    mov [matrix + (esi - 1) * 8], r15

no_swap_back:
    dec esi 
    cmp esi, r13d
    jg backward
    inc r13d
    jmp first_loop

sorted:
    ; restore data using temp_buffer
    mov rcx, rows
    xor rbx, rbx ; = mov rbx, 0 but xor faster

restore_loop:
    mov rax, [matrix + rbx*8]   ; row address after sort
    xor r8, r8 ; index for search in original_rows 

search_k:
    cmp r8, rows ; less than array size
    jge error ; if not - error
    mov r9, [original_rows + r8*8]
    cmp r9, rax ; comparing addresses
    je found_k ; if equal - jump
    inc r8
    jmp search_k

found_k:
    ; copy data from buffer
    mov rax, r8 ; address
    imul rax, cols*2
    lea rsi, [temp_buffer + rax] ; address in buffer
    mov rdi, [original_rows + rbx*8] ; address to paste copied 
    mov rcx, cols ; counter for rep
    rep movsw 

    inc rbx
    cmp rbx, rows
    jl restore_loop

    ; succesful ending 
    mov rax, 60
    mov rdi, 0
    syscall

error:
    mov rax, 60
    mov rdi, 1
    syscall
