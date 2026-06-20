#lang racket
(require racket/match)
(require "queue.rkt")

(provide (all-defined-out))

(define ITEMS 5)

; The counter structure does not change.
; However, the implementation of the queue field changes:
; - instead of a list, it will be a queue structure
; - the change is not visible in the structure definition,
;   but in the implementation of the counter type operations
(define-struct counter (index tt et queue) #:transparent)


; Updates to the functions below according to 
; the new representation of the people queue.
(define (empty-counter index)
  (make-counter index 0 0 empty-queue))

(define (update f counters index)
  (cond
    ((null? counters) '())
    ((= index (counter-index (car counters)))
     (cons (f (car counters)) (cdr counters)))
    (else
     (cons (car counters) (update f (cdr counters) index)))))

(define ((tt+ minutes) C) ; analogous to update
  (struct-copy counter C [tt (+ (counter-tt C) minutes)]))

(define ((et+ minutes) C) ; analogous to tt+
  (struct-copy counter C [et (+ (counter-et C) minutes)]))

(define ((add-to-counter name items) C)
  (if (queue-empty? (counter-queue C))
      (struct-copy counter C
                   [et (+ items (counter-et C))] ; the person will be first in line
                   [tt (+ items (counter-tt C))]
                   [queue (enqueue (cons name items) (counter-queue C))])
      (struct-copy counter C
                   [tt (+ items (counter-tt C))]
                   [queue (enqueue (cons name items) (counter-queue C))])))

(define ((min-field field) counters)

  (define (min-field-helper counters index acc) ; helper with tail recursion
    (cond
      ((null? counters) (cons index acc))
      ((<= acc (field (car counters))) (min-field-helper (cdr counters) index acc))
      (else (min-field-helper (cdr counters) (counter-index (car counters)) (field (car counters))))))

  ; calling the helper
  (min-field-helper (cdr counters) (counter-index (car counters)) (field (car counters))))
      

(define min-tt (min-field counter-tt)) ; using the function above
(define min-et (min-field counter-et)) ; using the function above

(define (remove-first-from-counter C)
  ((λ (c) ; function that waits for the dequeue to happen and then decides what happens with the et field
     (if (queue-empty? (counter-queue c))
         (struct-copy counter c [et 0])
         (struct-copy counter c [et (cdr (top (counter-queue c)))])))
   (struct-copy counter C ; the part that does the dequeue and enters as the second term of the application
                [tt (- (counter-tt C) (counter-et C))]
                [queue (dequeue (counter-queue C))])))


; Function that calculates the state
; of a counter after a given number of minutes.
; It function assumes, without checking, that during this time
; no one leaves the queue, so only the 
; tt and et fields are modified.
; It is the user's responsibility not to call
; the function with minutes > et and a non-empty queue.
; For counters without customers, it does not produce negative times.
(define ((pass-time-through-counter minutes) C)
  (if (< minutes (counter-et C))
      (struct-copy counter C
                   [et (- (counter-et C) minutes)]
                   [tt (- (counter-tt C) minutes)])
      (struct-copy counter C
                   [et 0]
                   [tt (- (counter-tt C) (counter-et C))])))

; Compared to part 2, there are changes to the customer flow function in:
; - the format of the request list (requests)
; - the format of the function's result (explained below)
; requests contains 4 types of requests:
;   3 inherited from stage 2:
;   - (<name> <n-items>) - places the person <name> in line at a counter
;   - (delay <index> <minutes>) - delays counter <index> by <minutes> minutes
;   - (ensure <average>) - as long as the average tt of all counters exceeds 
;                          <average>, adds unrestricted counters (slow counters)
;   plus the new one:
;   - <x> - updates the state of the counters according to the passage of <x> minutes
;           since the last request (affects the tt, et, queue fields)
; Note: The (remove-first) requests from stage 2 are replaced by a more  
; sophisticated mechanism to remove customers from the queue (as time passes).
; The system processes the requests in order, as follows:
; - no modification for the requests inherited from stage 2
; - when the time through the system advances by <x> minutes, the state of the counters
;   is updated to reflect the passage of time;
;   customer exits from the queue are recorded in chronological order.
; The serve function returns a dotted pair between:
; - the list of customers who have left the store, sorted chronologically
;   - the elements of the list have the form (counter_index . name)
;   - when multiple customers leave simultaneously, sort by counter index
; - the list of counters in the final state (like the result from stages 1 and 2)

(define (et-tt+ minutes) (compose (tt+ minutes) (et+ minutes))) ; combines the effect of the tt+ and et+ functions for easy use

(define (serve requests fast-counters slow-counters)
  
  (define (serve-helper done-clients requests fast-counters slow-counters) ; helper that also accepts the list of clients who have finished
    
    (define all-counters (append fast-counters slow-counters)) ; returns a list with all existing counters at the current moment 
    
    (define (get-allowed-counters n-items) ; returns a list with all allowed counters for the person with n-items
      (if (<= n-items ITEMS)
          all-counters
          slow-counters))

    (define get-average ; returns the average tt of the counters
    (/ (foldl
        (λ (C acc) (+ acc (counter-tt C)))
        0
        all-counters)
       (length all-counters)))

    (define (pass-time minutes acc fast-counters slow-counters) ; manages the passage of time and the removal of clients from counters
      (let* ([all-counters (append fast-counters slow-counters)] ; other variables will depend on all-counters, let* is needed
             [active-counters (filter (λ (C) (not (queue-empty? (counter-queue C)))) all-counters)])

        (define finish-sim ; finishes the execution of pass-time when there are guaranteed to be no more people to remove from the counters
          (serve-helper (append done-clients acc)
                        (cdr requests)
                        (map (pass-time-through-counter minutes) fast-counters)
                        (map (pass-time-through-counter minutes) slow-counters)))

        (if (null? active-counters) ; the simple case where the simulation ends
            finish-sim
            (let* ([first-client (min-et active-counters)] 
                   [index (car first-client)]
                   [first-exit (cdr first-client)])
              (if (> first-exit minutes) ; no one will leave the counter in the remaining time 
                  finish-sim
                  (let* ([min-counter (car (filter (λ (C) (= index (counter-index C))) all-counters))]
                         [name (car (top (counter-queue min-counter)))]
                         [new-fast-counters (map (pass-time-through-counter first-exit) fast-counters)]
                         [new-slow-counters (map (pass-time-through-counter first-exit) slow-counters)])
                    (pass-time (- minutes first-exit) ; the first client leaves and the simulation continues
                               (append acc (list (cons index name)))
                               (update remove-first-from-counter new-fast-counters index)
                               (update remove-first-from-counter new-slow-counters index))))))))

    ; the body of the helper
    (if (null? requests)
        (cons done-clients all-counters) ; base case
        (match (car requests)

          [(list 'delay index minutes)
           (serve-helper done-clients
                         (cdr requests)
                         (update (et-tt+ minutes)
                                 fast-counters
                                 index)
                         (update (et-tt+ minutes)
                                 slow-counters
                                 index))]

          [(list 'ensure average)
           (if (<= get-average average) ; average is already on target
               (serve-helper done-clients
                             (cdr requests)
                             fast-counters
                             slow-counters)
               (serve-helper done-clients
                             requests ; does not move to the next request until enough counters have been added to lower the average
                             fast-counters
                             (append slow-counters (list (empty-counter (add1 (length all-counters)))))))]

          [(list name n-items)
           (let ([min-index (car (min-tt (get-allowed-counters n-items)))])
             (serve-helper done-clients
                           (cdr requests)
                           (update (add-to-counter name n-items)
                                   fast-counters
                                   min-index)
                           (update (add-to-counter name n-items)
                                   slow-counters
                                   min-index)))]

          [x (pass-time x '() fast-counters slow-counters)])))

  ; calling the helper
  (serve-helper '() requests fast-counters slow-counters))
