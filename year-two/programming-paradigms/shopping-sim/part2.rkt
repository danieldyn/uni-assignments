#lang racket
(require racket/match)

(provide (all-defined-out))

(define ITEMS 5)

;; We are updating the counter structure with the et info:
;; The exit time (et) of a counter represents the time
;; until the first customer leaves that respective counter,
;; meaning the number of items to process for this customer
;; + the delays experienced by the counter (if any).

; Redefine the counter structure.
(define-struct counter (index tt et queue) #:transparent)

; Update to the empty-counter implementation
(define (empty-counter index)
  (make-counter index 0 0 '()))


; Function that applies a transformation f to the counter with a certain index.
; f = unary function with a counter-type parameter,
; counters = list of counters,
; index = the index of the counter to be transformed
; Returs the updated list of counters.
; If no counter with this index exists in counters,
; returns the unmodified list.
(define (update f counters index)
  (cond
    ((null? counters) '())
    ((= index (counter-index (car counters)))
     (cons (f (car counters)) (cdr counters))) ; f is applied upon finding the counter and it is added back to the list
    (else ; recursively continues the search
     (cons (car counters) (update f (cdr counters) index)))))

; Update to the tt+ implementation to:
; - account for the new representation of a counter
; - allow tt+ type operations to be passed as an argument
;   to the update function in the easiest way
; Note: Easiest means that a partial application of the tt+ function 
; will produce a unary function with a counter-type parameter, without
; the need for anonymous or auxiliary functions.
(define (tt+ minutes)
  (λ (C)
    (struct-copy counter C [tt (+ (counter-tt C) minutes)])))

(define (checker-tt+ C minutes)
  ((tt+ minutes) C))


; Function that increases the et of a counter by a given number of minutes.
(define (et+ minutes)
  (λ (C)
    (struct-copy counter C [et (+ (counter-et C) minutes)])))

(define (checker-et+ C minutes)
  ((et+ minutes) C))


; Update to the add-to-counter implementation

(define (my-append queue pair) ; adds a pair to the end of the list of pairs
  (append queue (list pair)))

(define (add-to-counter name n-items)
  (λ (C)
    (if (null? (counter-queue C)) ; checks if the person will be the first at the counter if added
        (struct-copy counter C
                     [et (+ n-items (counter-et C))]
                     [tt (+ n-items (counter-tt C))]
                     [queue (my-append (counter-queue C) (cons name n-items))])
        (struct-copy counter C
                     [tt (+ n-items (counter-tt C))]
                     [queue (my-append (counter-queue C) (cons name n-items))]))))

(define (checker-add-to-counter C name n-items)
  ((add-to-counter name n-items) C))

; Since we will use both min-tt (implemented in stage 1)
; and min-et (new function), define a more abstract function
; from which both min-tt and min-et can be easily derived.
; By analogy with min-tt, we define min-et as follows:
; min-et = function that receives a non-empty list of counters and
; returns a pair of:
; - the index of the counter (from the list) that has the smallest et
; - its et
; (for the same et, the counter with the smallest index is preferred)
;  - min-tt and min-et will be partial applications of the abstract function.

(define ((min-field field) counters)
  (foldl (λ (C pair) (if (<= (cdr pair) (field C))
                              pair
                              (cons (counter-index C) (field C))))
         (cons (counter-index (car counters)) (field (car counters)))
         (cdr counters)))
      

(define min-tt (min-field counter-tt)) ; using the function above
(define min-et (min-field counter-et)) ; using the function above


; Function that removes the first person from the queue of a counter.
; The function assumes, without checking, that there is
; at least one person in the queue of counter C.
; Returns a new structure obtained by modifying the waiting queue.
; If a counter has just been left by someone,
; it means it no longer has delays.

(define (get-next-n-items queue) ; returns n-items for the second person in the list (or 0 if they don't exist)
  (if (null? (cdr queue))
      0
      (cdr (car (cdr queue)))))

(define (remove-first-from-counter C)
  (struct-copy counter C
               [tt (- (counter-tt C) (counter-et C))]
               [et (get-next-n-items (counter-queue C))]
               [queue (cdr (counter-queue C))]))
    

; Function that simulates the customer flow through the counters.
; Compared to part 1, the function operates with the following modifications:
; - we no longer have just 4 counters, but:
;   - fast-counters (a list of counters for a maximum of ITEMS items)
;   - slow-counters (a list of counters without restrictions)
;   (Hint: use the update function to process lists of counters)
; - requests contains 4 types of requests (two more than in stage 1):
;   - (<name> <n-items>) - places the person <name> in line at a counter
;   - (delay <index> <minutes>) - delays counter <index> by <minutes> minutes
;   - (remove-first) - the most advanced person leaves the counter they are at
;   - (ensure <average>) - as long as the average tt of all counters exceeds 
;                          <average>, adds unrestricted counters (slow counters)
; The system processes the requests in order, as follows:
; - places the person at the counter with the minimum tt they are allowed at
;   (as before, but using fast-counters and slow-counters)
; - when a counter experiences a delay, its tt and et increase
;   (even if it has no customers)
; - the most advanced person is the first person at the counter with the minimum et
;   (among the counters that have customers)
;   (if no counter has customers, ignore the request)
; - if the average tt for all counters > <average>,
;   adds slow counters until the average <= <average>
;   (you can mathematically determine how many new counters are needed or
;   recursively add them one by one as long as necessary)

(define (et-tt+ minutes) (compose (tt+ minutes) (et+ minutes))) ; combines the effect of the tt+ and et+ functions for easy use

(define (serve requests fast-counters slow-counters)

  (define all-counters (append fast-counters slow-counters)) ; returns a list with all existing counters at the current moment

  (define (get-allowed-counters n-items) ; returns a list with all allowed counters for the person with n-items
    (if (<= n-items ITEMS)
        all-counters
        slow-counters))

  (define get-active-counters ; returns a list with all counters that have at least one person
    (filter
     (λ (C) (not (null? (counter-queue C))))
     all-counters))

  (define get-average ; returns the average tt of the counters
    (/ (foldl
        (λ (C acc) (+ acc (counter-tt C)))
        0
        all-counters)
       (length all-counters)))
    
  (if (null? requests)
      (append fast-counters slow-counters) ; base case
      (match (car requests)
        [(list 'delay index minutes)
         (serve (cdr requests)
                (update (et-tt+ minutes) ; update will only change the counter with the requested index
                        fast-counters
                        index)
                (update (et-tt+ minutes)
                        slow-counters
                        index))]
        [(list 'remove-first)
         (if (null? get-active-counters) ; ignores the request if all counters are free
             (serve (cdr requests)
                    fast-counters
                    slow-counters)
             (serve (cdr requests)
                    (update remove-first-from-counter
                            fast-counters
                            (car (min-et get-active-counters)))
                    (update remove-first-from-counter
                            slow-counters
                            (car (min-et get-active-counters)))))]
        [(list 'ensure average)
         (if (<= get-average average) ; average is already on target
             (serve (cdr requests)
                    fast-counters
                    slow-counters)
             (serve requests ; does not move to the next request until enough counters have been added to lower the average
                    fast-counters
                    (append slow-counters (list (empty-counter (add1 (length all-counters)))))))]
        [(list name n-items)
         (serve (cdr requests)
                (update (add-to-counter name n-items)
                        fast-counters
                        (car (min-tt (get-allowed-counters n-items))))
                (update (add-to-counter name n-items)
                        slow-counters
                        (car (min-tt (get-allowed-counters n-items)))))])))
