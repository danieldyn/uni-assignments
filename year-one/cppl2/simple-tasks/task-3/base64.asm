section .data
    alphabet db 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P', \
               'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f', \
               'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v', \
               'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'

global base64

section .text

; function signature: 
; void base64(char *a, int n, char *target, int *ptr_len);

base64:
    ; create new stack frame and save registers
    push ebp
    mov ebp, esp
    pusha

    mov esi, [ebp + 8]       ; source array
    mov ebx, [ebp + 12]      ; input length
    mov edi, [ebp + 16]      ; destination array
    mov edx, [ebp + 20]      ; pointer to destination length

    ; initialisations
    mov dword [edx], 0
    mov ecx, ebx

iterate_text:
    ; save dest length on the stack
    push edx

    ; merge three bytes into 24 bits (stored in eax)
    xor eax, eax
    mov ah, byte [esi]       ; first byte
    shl eax, 8
    mov ah, byte [esi + 1]   ; second byte
    mov al, byte [esi + 2]   ; third byte

    ; extract and encode 6-bit groups (left to right)

    ; first 6 bits
    mov edx, eax
    shr edx, 18
    and edx, 63
    mov dl, byte [alphabet + edx]
    ; add to destination and update pointer
    mov byte [edi], dl
    inc edi

    ; second 6 bits
    mov edx, eax
    shr edx, 12
    and edx, 63
    mov dl, byte [alphabet + edx]
    ; add to destination and update pointer
    mov byte [edi], dl
    inc edi

    ; third 6 bits
    mov edx, eax
    shr edx, 6
    and edx, 63
    mov dl, byte [alphabet + edx]
    ; add to destination and update pointer
    mov byte [edi], dl
    inc edi

    ; final 6 bits
    mov edx, eax
    and edx, 63
    mov dl, byte [alphabet + edx]
    ; add to destination and update pointer
    mov byte [edi], dl
    inc edi

    ; restore dest length pointer and update the length
    pop edx
    add dword [edx], 4

    ; move to the next three bytes
    add esi, 3
    ; update counter
    sub ecx, 3
    cmp ecx, 0
    jne iterate_text

    ; restore registers and return
    popa
    leave
    ret
