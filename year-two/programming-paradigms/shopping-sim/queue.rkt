#lang racket
(require racket/match)

(provide empty-queue)
(provide queue-empty?)
(provide enqueue)
(provide dequeue)
(provide top)

(provide (struct-out queue)) ; pentru testare

;; Lucrul cu o coadă implică multe operații de tip:
;; - enqueue (adăugare element la sfârșitul cozii)
;; - dequeue (scoatere element de la începutul cozii)
;; Când coada este o listă, complexitatea operațiilor este:
;; - O(n) la enqueue (dată de complexitatea unui append)
;; - O(1) la dequeue (dată de complexitatea unui cdr)
;; Dorim cost amortizat constant (O(1))
;; atât pentru enqueue cât și pentru dequeue.
;;
;; Soluție: reprezentăm coada folosind 2 stive (liste):
;; - stiva left: din left scoatem la dequeue
;;   (O(1) dacă left are elemente, altfel O(n))
;; - stiva right: în right adăugăm la enqueue (O(1))
;; |     |    |     |
;; |     |    |__5__|
;; |__1__|    |__4__|
;; |__2__|    |__3__|
;;
;; Singura operație costisitoare este dequeue
;; când stiva left este vidă.
;; Pe exemplu: Presupunem că am scos deja 1 și 2
;; din coadă și facem un nou dequeue.
;; În acest caz, complexitatea este O(n):
;; 1. mutăm (pop + push) toate elementele din right 
;;    în left (în ordine, extragem 5, 4, 3)
;; |     |    |     |      |     |    |     |      |     |    |     |
;; |     |    |     |      |     |    |     |      |__3__|    |     |
;; |     |    |__4__|  ->  |__4__|    |     |  ->  |__4__|    |     |
;; |__5__|    |__3__|      |__5__|    |__3__|      |__5__|    |_____|
;;
;; 2. pop din stiva left, eliminând valoarea 3
;; Fiecare element al cozii se mută maxim o dată din
;; right în left => cost amortizat O(1) per operație.


; Definim structura "coadă" prin:
; - left   (o stivă: dequeue = pop pe stiva left)
; - right  (o stivă: enqueue = push în stiva right)
; - size-l (numărul de elemente din stiva left)
; - size-r (numărul de elemente din stiva right)
; Obs: Listele Racket sunt practic stive (push = cons, pop = car).
(define-struct queue (left right size-l size-r) #:transparent) 


; TODO 1 (5p)
; Definiți valoarea care reprezintă o coadă goală.
(define empty-queue
  (make-queue '() '() 0 0))


; TODO 2 (5p)
; Implementați o funcție care verifică dacă o coadă este goală.
(define (queue-empty? q)
  (and (null? (queue-left q)) (null? (queue-right q))))


; TODO 3 (5p)
; Implementați o funcție care adaugă un element la
; sfârșitul unei cozi. Întoarceți coada actualizată.
(define (enqueue x q)
  (struct-copy queue q
               [right (cons x (queue-right q))]
               [size-r (add1 (queue-size-r q))]))


; TODO 4 (10p)
; Implementați o funcție care scoate primul element
; dintr-o coadă nevidă. Întoarceți coada actualizată.
; Obs: dequeue pe coada vidă este firesc să dea eroare.
(define (dequeue q)
  (if (null? (queue-left q))
      (struct-copy queue q ; se muta tot din stiva dreapta in stiva stanga si apoi se scoate primul element
                   [left (cdr (reverse (queue-right q)))]
                   [size-l (sub1 (queue-size-r q))]
                   [right '()]
                   [size-r 0])
      (struct-copy queue q ; doar se scoate primul element din stiva stanga
                   [left (cdr (queue-left q))]
                   [size-l (sub1 (queue-size-l q))])))


; TODO 5 (5p)
; Implementați o funcție care obține primul element
; dintr-o coadă nevidă. Întoarceți elementul.
; Obs: top pe coada vidă este firesc să dea eroare.
(define (get-last L) ; intoarce ultimul element dintr-o lista (necesar pentru cazul defavorabil al lui top q
  (if (null? (cdr L))
      (car L)
      (get-last (cdr L))))

(define (top q)
  (if (null? (queue-left q))
      (get-last (queue-right q))
      (car (queue-left q))))
