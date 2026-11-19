section .data

txt_usage   db "Usage : ./ioc-hunter scan <fichier>  ou  ./ioc-hunter xor <fichier>", 10, 0
txt_erreur  db "Erreur : impossible de lire le fichier", 10, 0
txt_alerte  db "[ALERTE] ", 0
txt_fleche  db "  ->  ", 0
txt_retour  db 10, 0

mot1        db "http://", 0
mot2        db "https://", 0
mot3        db "powershell -enc", 0
mot4        db "mimikatz", 0
mot5        db "Delete Shadows", 0
mot6        db "/dev/tcp/", 0
mot7        db "chmod +x", 0
mot8        db ".onion", 0

liste_mots  dq mot1, mot2, mot3, mot4, mot5, mot6, mot7, mot8, 0

section .bss

buf         resb 1000000
taille      resq 1

section .text
global _start

_start:
    cmp qword [rsp], 3
    jne usage

    mov rdi, [rsp+24]
    call lire_fichier

    mov rsi, [rsp+16]
    cmp byte [rsi], 's'
    je scan
    cmp byte [rsi], 'x'
    je decode

usage:
    mov rsi, txt_usage
    call afficher
    mov rdi, 1
    jmp quitter


scan:
    mov r12, 0

ligne:
    cmp r12, [taille]
    jae fin_scan
    mov r14, r12

fin_de_ligne:
    cmp r12, [taille]
    jae tester_mots
    cmp byte [buf+r12], 10
    je tester_mots
    inc r12
    jmp fin_de_ligne

tester_mots:
    mov r15, 0

mot_suivant:
    mov rbx, [liste_mots+r15*8]
    cmp rbx, 0
    je ligne_suivante
    call chercher
    cmp rax, 1
    jne pas_trouve
    call alerte

pas_trouve:
    inc r15
    jmp mot_suivant

ligne_suivante:
    inc r12
    jmp ligne

fin_scan:
    mov rdi, 0
    jmp quitter


chercher:
    mov rcx, r14

depart:
    mov rdx, 0

lettre:
    mov al, [rbx+rdx]
    cmp al, 0
    je trouve
    mov rsi, rcx
    add rsi, rdx
    cmp rsi, r12
    jae absent
    cmp al, [buf+rsi]
    jne depart_suivant
    inc rdx
    jmp lettre

depart_suivant:
    inc rcx
    jmp depart

trouve:
    mov rax, 1
    ret

absent:
    mov rax, 0
    ret


alerte:
    mov rsi, txt_alerte
    call afficher
    mov rsi, rbx
    call afficher
    mov rsi, txt_fleche
    call afficher
    mov rsi, buf
    add rsi, r14
    mov rdx, r12
    sub rdx, r14
    call ecrire
    mov rsi, txt_retour
    call afficher
    ret


decode:
    mov r12, 0

decode_boucle:
    cmp r12, [taille]
    jae decode_fin
    xor byte [buf+r12], 90
    inc r12
    jmp decode_boucle

decode_fin:
    mov rsi, buf
    mov rdx, [taille]
    call ecrire
    mov rdi, 0
    jmp quitter


lire_fichier:
    mov rax, 2
    mov rsi, 0
    syscall
    cmp rax, 0
    jl erreur

    mov rdi, rax
    mov rax, 0
    mov rsi, buf
    mov rdx, 1000000
    syscall
    cmp rax, 0
    jl erreur
    mov [taille], rax
    ret

erreur:
    mov rsi, txt_erreur
    call afficher
    mov rdi, 2
    jmp quitter


afficher:
    mov rdx, 0

compter:
    cmp byte [rsi+rdx], 0
    je ecrire
    inc rdx
    jmp compter

ecrire:
    mov rax, 1
    mov rdi, 1
    syscall
    ret


quitter:
    mov rax, 60
    syscall
