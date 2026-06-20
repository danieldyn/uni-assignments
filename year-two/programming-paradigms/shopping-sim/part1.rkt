#lang racket
(require racket/match)

(provide (all-defined-out))

(define ITEMS 5)

; We define a structure that describes a counter by:
; - index (from 1 to 4)
; - tt (the total time described above)
; - queue (the queue with the waiting people)
(define-struct counter (index tt queue) #:transparent)


; Function that returns an empty counter structure.
; tt is 0 and the queue is empty.
(define (empty-counter index)
  (make-counter index 0 '()))

; Function that increases the tt of a counter by a given number of minutes.
(define (tt+ C minutes)
  (struct-copy counter C [tt (+ (counter-tt C) minutes)]))

; Tail recursive function that receives a non-empty list 
; of counters and returns a pair of:
; - the index of the counter (from the list) that has the smallest tt
; - its tt
; Note: when multiple counters have the same tt,
; the counter with the smallest index is preferred
(define (get-current-tt counters) (counter-tt (car counters))) ; extracts the tt of the first counter from the list

(define (get-current-index counters) (counter-index (car counters))) ; extracts the index of the first counter from the list

(define (min-tt counters)
  (min-tt-helper (cdr counters) (get-current-index counters) (get-current-tt counters)))

(define (min-tt-helper counters index tt)
  (cond
    ((null? counters) (cons index tt))
    ((< (get-current-tt counters) tt) ; better tt than the accumulator
     (min-tt-helper (cdr counters) (get-current-index counters) (get-current-tt counters)))
    ((and (= (get-current-tt counters) tt) (< (get-current-index counters) index)) ; equal tt but smaller index than the accumulator
     (min-tt-helper (cdr counters) (get-current-index counters) (get-current-tt counters)))
    (else ; the accumulator is the better answer
     (min-tt-helper (cdr counters) index tt))))

; The same functionality as above, using stack recursion.
(define (get-remaining-tt counters) (cdr (min-tt-stack (cdr counters)))) ; extracts the tt of the response coming from recursion

(define (get-remaining-index counters) (car (min-tt-stack (cdr counters)))) ; extracts the index of the response coming from recursion

(define (min-tt-stack counters)
  (cond
    ((null? (cdr counters)) (cons (get-current-index counters) (get-current-tt counters)))
    ((< (get-current-tt counters) (get-remaining-tt counters))
     (cons (get-current-index counters) (get-current-tt counters))) ; current tt smaller than in recursion
    ((and (= (get-current-tt counters) (get-remaining-tt counters)) (< (get-current-index counters) (get-remaining-index counters)))
     (cons (get-current-index counters) (get-current-tt counters))) ; current index smaller than in recursion and equal tt
    (else (min-tt-stack (cdr counters))))) ; the response from recursion is better

; Function that adds a person to a counter.
; C = counter, name = the person's name,
; n-items = the number of items bought
; Returns a new structure obtained by placing the pair
; (name . n-items) at the end of the waiting queue.
(define (my-append queue pair)
  (append queue (list pair)))

(define (add-to-counter C name n-items)
  (struct-copy counter C
               [tt (+ n-items (counter-tt C))]
               [queue (my-append (counter-queue C) (cons name n-items))]))


; Function that simulates the customer flow through the counters.
; requests = list of requests which can be of 2 types:
; - (<name> <n-items>) - places the person <name> in line at a counter
; - (delay <index> <minutes>) - delays counter <index> by <minutes> minutes
; C1, C2, C3, C4 = structures corresponding to the 4 counters
; The system processes the requests in order, as follows:
; - places the person at the counter with the minimum allowed tt
;   (according to the logic implemented by min-tt)
; - when a counter experiences a delay, its tt increases
(define (serve requests C1 C2 C3 C4)

  (define (get-counter index) ; returns the counter that has the index given as a parameter
    (cond
      ((= index 1) C1)
      ((= index 2) C2)
      ((= index 3) C3)
      (else C4)))

  (define (serve-next index modified-counter) ; launches the recursive call for the new state of the counters and the next request
    (cond
      ((= index 1) (serve (cdr requests) modified-counter C2 C3 C4))
      ((= index 2) (serve (cdr requests) C1 modified-counter C3 C4))
      ((= index 3) (serve (cdr requests) C1 C2 modified-counter C4))
      (else (serve (cdr requests) C1 C2 C3 modified-counter))))

  (define (get-min-tt-counter n-items) ; returns the counter that satisfies the requirement
    (if (> n-items ITEMS)
        (get-counter (car (min-tt (list C2 C3 C4))))
        (get-counter (car (min-tt (list C1 C2 C3 C4))))))

  (define (get-min-tt-index n-items) (counter-index (get-min-tt-counter n-items))) ; returns the index of the counter that satisfies the requirement

  (if (null? requests)
      (list C1 C2 C3 C4)
      (match (car requests)
        [(list 'delay index minutes)
         (serve-next index (tt+ (get-counter index) minutes))]
        [(list name n-items)
         (serve-next (get-min-tt-index n-items) (add-to-counter (get-min-tt-counter n-items) name n-items))])))
