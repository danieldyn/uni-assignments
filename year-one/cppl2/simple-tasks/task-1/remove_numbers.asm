global remove_numbers

section .text

; function signature: 
; void remove_numbers(int *a, int n, int *target, int *ptr_len);

remove_numbers:
	; create new stack frame and save registers
	push    ebp
	mov     ebp, esp
	pusha

	mov     esi, [ebp + 8]		; source array
	mov     ebx, [ebp + 12]		; n
	mov     edi, [ebp + 16] 	; dest array
	mov     edx, [ebp + 20] 	; pointer to dest length
   
	; initialisations
	mov dword [edx], 0
	xor ecx, ecx

iterate_array:
	; extract the current number
	mov eax, [esi]
	; test LSB for parity - zero flag activated means even number
	test eax, 1
	jnz next_number
	
	; test if x & (x - 1) == 0 to find powers of 2
	; the number 0 is an edge case for this method
	cmp eax, 0
	je next_number

	; safe to test now
	push ebx

	mov ebx, eax
	sub ebx, 1
	test ebx, eax
	
	pop ebx
	jz next_number

	; here the number is an acceptable one
	; place it in the dest array and move the dest pointer
	mov [edi], eax
	add edi, 4
	; update counter
	inc dword [edx]

next_number:
	; move the source pointer
	add esi, 4
	; update counter
	inc ecx
	cmp ecx, ebx
	jl iterate_array

    ; pop saved registers and leave function

	popa
	leave
	ret
