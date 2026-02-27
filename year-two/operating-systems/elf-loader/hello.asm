; Assembly code to test basic memory mapping and execution

global _start

section .data
    msg db "Locked and Loaded!", 10

section .text

_start:
    ; write syscall explicit form: write(1, msg, 14)
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg]
    mov rdx, 14
    syscall

    ; exit syscall
    mov rax, 60
    xor rdi, rdi
    syscall
