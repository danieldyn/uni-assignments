; struct declarations
struc date
    day: resb 1
    month: resb 1
    year: resw 1
endstruc

struc event
    name: resb 31
    valid: resb 1
    ev_date: resb date_size
endstruc

global check_events

section .text

; function signature: 
; void check_events(struct event *events, int len);

check_events:
    ; create stack frame and save registers
    push ebp
    mov ebp, esp
    pusha

    mov esi, [ebp + 8]      ; events pointer
    mov ecx, [ebp + 12]     ; number of events

iterate_events:
    ; verify year (2 bytes)
    mov ax, word [esi + ev_date + year]
    cmp ax, 1990
    jb invalid_element
    cmp ax, 2030
    ja invalid_element

    ; verify month (1 byte)
    mov al, byte [esi + ev_date + month]
    cmp al, 1
    jb invalid_element
    cmp al, 12
    ja invalid_element

    ; verify day (1 byte)
    mov dl, byte [esi + ev_date + day]
    cmp dl, 1
    jb invalid_element
    cmp dl, 31
    ja invalid_element

    ; check for February
    cmp al, 2
    jne not_february
    cmp dl, 28
    ja invalid_element
    jmp valid_element

not_february:
    ; check for April, June, September or November
    cmp al, 4
    je check_30
    cmp al, 6
    je check_30
    cmp al, 9
    je check_30
    cmp al, 11
    je check_30

    ; remaining months have 31 days
    cmp dl, 31
    ja invalid_element
    jmp valid_element

check_30:
    cmp dl, 30
    ja invalid_element

valid_element:
    mov byte [esi + valid], 1
    jmp next_element

invalid_element:
    mov byte [esi + valid], 0

next_element:
    ; move to the next element
    add esi, event_size
    ; update counter
    dec ecx
    cmp ecx, 0
    jg iterate_events

    ; restore registers and return
    popa
    leave
    ret
