#lang racket
(require racket/match)
(require "queue-final.rkt")

(provide (all-defined-out))

(define ITEMS 5)


; TODO (0p)
; Aveți libertatea să vă structurați programul cum doriți
; (dar cu restricțiile de mai jos), astfel încât
; funcția serve să funcționeze conform specificației.
; 
; Restricții (impuse de checker):
; - va exista în continuare funcția (empty-counter index)
; - veți reprezenta cozile folosind noul TDA queue

; Acum ca exista si case closed si open, avem mai multe combinatii de diferentiat:
; - fast si closed
; - fast si open
; - slow si closed
; - slow si open
; Decat sa processez 4 liste cu suprapuneri inevitabile, adaug un camp boolean open?
(define-struct counter (index open? tt et queue) #:transparent)

; Cod preluat din etapa3.rkt
(define (update f counters index)
  (cond
    ((null? counters) '())
    ((= index (counter-index (car counters)))
     (cons (f (car counters)) (cdr counters)))
    (else
     (cons (car counters) (update f (cdr counters) index)))))

(define ((tt+ minutes) C)
  (struct-copy counter C [tt (+ (counter-tt C) minutes)]))

(define ((et+ minutes) C)
  (struct-copy counter C [et (+ (counter-et C) minutes)]))

(define (et-tt+ minutes) (compose (tt+ minutes) (et+ minutes)))

(define ((add-to-counter name items) C)
  (if (queue-empty? (counter-queue C))
      (struct-copy counter C
                   [et (+ items (counter-et C))]
                   [tt (+ items (counter-tt C))]
                   [queue (enqueue (cons name items) (counter-queue C))])
      (struct-copy counter C
                   [tt (+ items (counter-tt C))]
                   [queue (enqueue (cons name items) (counter-queue C))])))

(define ((min-field field) counters)

  (define (min-field-helper counters index acc)
    (cond
      ((null? counters) (cons index acc))
      ((<= acc (field (car counters))) (min-field-helper (cdr counters) index acc))
      (else (min-field-helper (cdr counters) (counter-index (car counters)) (field (car counters))))))

  (min-field-helper (cdr counters) (counter-index (car counters)) (field (car counters))))
      

(define min-tt (min-field counter-tt))
(define min-et (min-field counter-et))

(define (remove-first-from-counter C)
  ((λ (c) 
     (if (queue-empty? (counter-queue c))
         (struct-copy counter c [et 0])
         (struct-copy counter c [et (cdr (top (counter-queue c)))])))
   (struct-copy counter C
                [tt (- (counter-tt C) (counter-et C))]
                [queue (dequeue (counter-queue C))])))

(define ((pass-time-through-counter minutes) C)
  (if (< minutes (counter-et C))
      (struct-copy counter C
                   [et (- (counter-et C) minutes)]
                   [tt (- (counter-tt C) minutes)])
      (struct-copy counter C
                   [et 0]
                   [tt (- (counter-tt C) (counter-et C))])))

; Functii noi care iau in calcul campul adaugat in structura counter
(define (empty-counter index)
  (make-counter index #t 0 0 empty-queue))

(define (set-as-open C)
  (struct-copy counter C [open? #t]))

(define (set-as-closed C)
  (struct-copy counter C [open? #f]))

(define (set-tt-to-et C) ; se comporta ca si cum toate persoanele de la casa, mai putin prima, au fost redistribuite
  (struct-copy counter C [tt (counter-et C)]))

(define (remove-rest C) ; gestioneaza redistribuirea clientilor de la o casa pentru a o inchide
  (if (queue-empty? (counter-queue C))
      C
      (let* ([queue (counter-queue C)]
             [head (top queue)])
        (let loop ([rest (dequeue queue)])
          (if (queue-empty? rest)
              (struct-copy counter C [queue (enqueue head empty-queue)])
              (loop (dequeue rest)))))))

  (define close-counter
    (compose set-as-closed set-tt-to-et remove-rest)) ; combina tot ce trebuie pentru a determina noua stare a cozii la inchidere
  
  ; TODO 7 (70p)
  ; Implementați funcția care simulează fluxul clienților pe la case.
  ; ATENȚIE: Față de etapa 3, apar modificări în:
  ; - formatul listei de cereri (requests)
  ; - formatul rezultatului funcției (explicat mai jos)
  ; requests conține 6 tipuri de cereri:
  ;   4 moștenite din etapa 3:
  ;   - (<name> <n-items>) - așază persoana <name> la coadă la o casă deschisă
  ;   - (delay <index> <minutes>) - întârzie casa <index> cu <minutes> minute
  ;   - (ensure <average>) - cât timp tt-ul mediu al caselor deschise depășește 
  ;                          <average>, adaugă case fără restricții (case slow)
  ;   - <x> - actualizează starea caselor conform cu trecerea a <x> minute
  ;           de la ultima cerere (afectează câmpurile tt, et, queue)
  ;   plus 2 noi:
  ;   - (close <index>) - închide casa cu indexul <index> (casa există deja)
  ;   - (open <index>) - deschide casa cu indexul <index> (casa există deja)
  ; Sistemul procesează cererile în ordine, astfel:
  ; - așază persoana la casa DESCHISĂ cu tt minim la care are voie;
  ;   se garantează că persoana poate fi distribuită la o casă
  ; - nicio modificare pentru situația când o casă suferă o întârziere
  ; - dacă tt-ul mediu pentru toate casele DESCHISE > <average>,
  ;   adaugă case slow până când media <= <average>
  ; - nicio modificare în modelarea trecerii timpului
  ; - o casă care se închide nu mai primește clienți noi și:
  ;   - primul client (dacă există) își continuă treaba la această casă
  ;   - restul clienților se redistribuie la celelalte case,
  ;     în ordinea în care erau așezați la coadă
  ; - o casă care se deschide redevine disponibilă pentru clienți
  ; Funcția serve întoarce o pereche cu punct între:
  ; - lista clienților care au părăsit magazinul, sortată cronologic
  ;   - elementele listei au forma (index_casă . nume)
  ;   - când mai mulți clienți ies simultan, sortați după indexul casei
  ; - lista cozilor nevide în starea finală, sortată după indexul casei
  ;   - elementele listei au forma (index_casă . coadă) (coada este de tip queue)

  (define (serve requests fast-counters slow-counters)
  
    (define (serve-helper done-clients requests fast-counters slow-counters) ; helper care accepta si lista de clienti care au terminat
    
      (let* ([all-counters (append fast-counters slow-counters)] 
             [open-counters (filter (λ (C) (counter-open? C)) all-counters)]
             [open-slow-counters (filter (λ (C) (counter-open? C)) slow-counters)]
             [allowed-counters (λ (n-items) (if (<= n-items ITEMS) open-counters open-slow-counters))]
             [average-tt (/ (foldl (λ (C acc) (+ acc (counter-tt C))) 0 open-counters) (length open-counters))] ; media include doar casele deschise
             [active-counters (filter (λ (C) (not (queue-empty? (counter-queue C)))) all-counters)]) ; activ inseamna in continuare existenta unui client (poate fi inchisa)

        ; neschimbat de la etapa 3
        (define (pass-time minutes acc fast-counters slow-counters) ; gestioneaza trecerea timpului si scoaterea clientilor de la case
          (let* ([all-counters (append fast-counters slow-counters)] ; va face shadowing local lui all-counters din let*-ul mare
                 [active-counters (filter (λ (C) (not (queue-empty? (counter-queue C)))) all-counters)])
            (define finish-sim ; finalizeaza executia pass-time cand garantat nu mai sunt persoane de scos de la case
              (serve-helper (append done-clients acc)
                            (cdr requests)
                            (map (pass-time-through-counter minutes) fast-counters)
                            (map (pass-time-through-counter minutes) slow-counters)))
 
            (if (null? active-counters) ; cazul simplu in care simularea se incheie
                finish-sim
                (let* ([first-client (min-et active-counters)] 
                       [index (car first-client)]
                       [first-exit (cdr first-client)])
                  (if (> first-exit minutes) ; nimeni nu va iesi de la casa in timpul ramas 
                      finish-sim
                      (let* ([min-counter (car (filter (λ (C) (= index (counter-index C))) all-counters))]
                             [name (car (top (counter-queue min-counter)))]
                             [new-fast-counters (map (pass-time-through-counter first-exit) fast-counters)]
                             [new-slow-counters (map (pass-time-through-counter first-exit) slow-counters)])
                        (pass-time (- minutes first-exit) ; iese primul client si continua simularea
                                   (append acc (list (cons index name)))
                                   (update remove-first-from-counter new-fast-counters index)
                                   (update remove-first-from-counter new-slow-counters index))))))))
 
        ; corpul let*-ului principal
        (if (null? requests)
            (cons done-clients (map (λ (C) (cons (counter-index C) (counter-queue C))) active-counters)) ; caz de baza nou
            (match (car requests)
 
              [(list 'delay index minutes) ; neschimbat de la etapa 3
               (serve-helper done-clients
                             (cdr requests)
                             (update (et-tt+ minutes) fast-counters index)
                             (update (et-tt+ minutes) slow-counters index))]
 
              [(list 'ensure average) ; neschimbat de la etapa 3
               (if (<= average-tt average) ; media e deja in target
                   (serve-helper done-clients
                                 (cdr requests)
                                 fast-counters
                                 slow-counters)
                   (serve-helper done-clients
                                 requests ; nu se trece la urmatorul request pana nu s-au adaugat case suficiente pentru a scadea media
                                 fast-counters
                                 (append slow-counters (list (empty-counter (add1 (length all-counters)))))))]

              [(list 'open index)
               (serve-helper done-clients
                             (cdr requests)
                             (update set-as-open fast-counters index)
                             (update set-as-open slow-counters index))]

              [(list 'close index)
               (let* ([target (car (filter (λ (C) (= index (counter-index C))) all-counters))]
                      [target-queue (counter-queue target)])
                 (let redistribute ([queue (if (queue-empty? target-queue)
                                               target-queue
                                               (dequeue target-queue))]
                                    [new-fast-counters (update close-counter fast-counters index)]
                                    [new-slow-counters (update close-counter slow-counters index)])
                   (if (queue-empty? queue) ; casa nu are clienti, deci nu mai sunt alte calcule de facut
                       (serve-helper done-clients
                                     (cdr requests)
                                     new-fast-counters
                                     new-slow-counters)
                       (let* ([first-client (top queue)]
                              [name (car first-client)]
                              [n-items (cdr first-client)]
                              [open-slow-counters (filter (λ (C) (counter-open? C)) new-slow-counters)]
                              [open-fast-counters (filter (λ (C) (counter-open? C)) new-fast-counters)]
                              [allowed-counters (if (<= n-items ITEMS)
                                                    (append open-fast-counters open-slow-counters)
                                                    open-slow-counters)]
                              [min-index (car (min-tt allowed-counters))])
                         ; apelul let-ului cu nume, avand noua stare a caselor si o persoana mai putin de redistribuit
                         (redistribute (dequeue queue)
                                       (update (add-to-counter name n-items) new-fast-counters min-index)
                                       (update (add-to-counter name n-items) new-slow-counters min-index))))))]
            
              [(list name n-items) ; neschimbat de la etapa 3
               (let ([min-index (car (min-tt (allowed-counters n-items)))])
                 (serve-helper done-clients
                               (cdr requests)
                               (update (add-to-counter name n-items) fast-counters min-index)
                               (update (add-to-counter name n-items) slow-counters min-index)))]

              [x ; neschimbat de la etapa 3
               (pass-time x '() fast-counters slow-counters)]))))

    ; apelul helper-ului
    (serve-helper '() requests fast-counters slow-counters))
