#lang racket
(require racket/match)
(require "queue-final.rkt")

(provide (all-defined-out))

(define ITEMS 5)

; Now that there are both closed and open counters, we have multiple combinations to differentiate:
; - fast and closed
; - fast and open
; - slow and closed
; - slow and open
; Rather than processing 4 lists with inevitable overlaps, we added a boolean field open?
(define-struct counter (index open? tt et queue) #:transparent)

; Code taken from part 3
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

; New functions that take into account the field added in the counter structure
(define (empty-counter index)
  (make-counter index #t 0 0 empty-queue))

(define (set-as-open C)
  (struct-copy counter C [open? #t]))

(define (set-as-closed C)
  (struct-copy counter C [open? #f]))

(define (set-tt-to-et C) ; behaves as if all people at the counter, except the first one, have been redistributed
  (struct-copy counter C [tt (counter-et C)]))

(define (remove-rest C) ; manages the redistribution of clients from a counter in order to close it
  (if (queue-empty? (counter-queue C))
      C
      (let* ([queue (counter-queue C)]
             [head (top queue)])
        (let loop ([rest (dequeue queue)])
          (if (queue-empty? rest)
              (struct-copy counter C [queue (enqueue head empty-queue)])
              (loop (dequeue rest)))))))

(define close-counter
  (compose set-as-closed set-tt-to-et remove-rest)) ; combines everything necessary to determine the new state of the queue upon closing

; Compared to part 3, there are changes to the customer flow in:
; - the format of the request list (requests)
; - the format of the function's result (explained below)
; requests contains 6 types of requests:
;   4 inherited from stage 3:
;   - (<name> <n-items>) - places the person <name> in line at an open counter
;   - (delay <index> <minutes>) - delays counter <index> by <minutes> minutes
;   - (ensure <average>) - as long as the average tt of open counters exceeds 
;                          <average>, adds unrestricted counters (slow counters)
;   - <x> - updates the state of the counters according to the passage of <x> minutes
;           since the last request (affects the tt, et, queue fields)
;   plus 2 new ones:
;   - (close <index>) - closes the counter with the index <index> (the counter already exists)
;   - (open <index>) - opens the counter with the index <index> (the counter already exists)
; The system processes the requests in order, as follows:
; - places the person at the OPEN counter with the minimum allowed tt;
;   it is guaranteed that the person can be distributed to a counter
; - no modification for the situation when a counter experiences a delay
; - if the average tt for all OPEN counters > <average>,
;   adds slow counters until the average <= <average>
; - no modification in modeling the passage of time
; - a closing counter no longer receives new customers and:
;   - the first customer (if any) continues their business at this counter
;   - the rest of the customers are redistributed to the other counters,
;     in the order they were standing in line
; - an opening counter becomes available to customers again
; The serve function returns a dotted pair between:
; - the list of customers who have left the store, sorted chronologically
;   - the elements of the list have the form (counter_index . name)
;   - when multiple customers leave simultaneously, sort by counter index
; - the list of non-empty queues in the final state, sorted by counter index
;   - the elements of the list have the form (counter_index . queue) (the queue is of type queue)

(define (serve requests fast-counters slow-counters)

  (define (serve-helper done-clients requests fast-counters slow-counters) ; helper that also accepts the list of clients who have finished
  
    (let* ([all-counters (append fast-counters slow-counters)] 
           [open-counters (filter (λ (C) (counter-open? C)) all-counters)]
           [open-slow-counters (filter (λ (C) (counter-open? C)) slow-counters)]
           [allowed-counters (λ (n-items) (if (<= n-items ITEMS) open-counters open-slow-counters))]
           [average-tt (/ (foldl (λ (C acc) (+ acc (counter-tt C))) 0 open-counters) (length open-counters))] ; the average only includes open counters
           [active-counters (filter (λ (C) (not (queue-empty? (counter-queue C)))) all-counters)]) ; active means the continued existence of a client (it can be closed)

      (define (pass-time minutes acc fast-counters slow-counters) ; manages the passage of time and the removal of clients from counters
        (let* ([all-counters (append fast-counters slow-counters)] ; will locally shadow all-counters from the large let*
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

      ; the body of the main let*
      (if (null? requests)
          (cons done-clients (map (λ (C) (cons (counter-index C) (counter-queue C))) active-counters)) ; new base case
          (match (car requests)

            [(list 'delay index minutes)
             (serve-helper done-clients
                           (cdr requests)
                           (update (et-tt+ minutes) fast-counters index)
                           (update (et-tt+ minutes) slow-counters index))]

            [(list 'ensure average)
             (if (<= average-tt average) ; average is already on target
                 (serve-helper done-clients
                               (cdr requests)
                               fast-counters
                               slow-counters)
                 (serve-helper done-clients
                               requests ; does not move to the next request until enough counters have been added to lower the average
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
                 (if (queue-empty? queue) ; the counter has no clients, so there are no other calculations to make
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
                       ; the call to the named let, with the new state of the counters and one less person to redistribute
                       (redistribute (dequeue queue)
                                     (update (add-to-counter name n-items) new-fast-counters min-index)
                                     (update (add-to-counter name n-items) new-slow-counters min-index))))))]

            [(list name n-items)
             (let ([min-index (car (min-tt (allowed-counters n-items)))])
               (serve-helper done-clients
                             (cdr requests)
                             (update (add-to-counter name n-items) fast-counters min-index)
                             (update (add-to-counter name n-items) slow-counters min-index)))]

            [x (pass-time x '() fast-counters slow-counters)]))))

  ; calling the helper
  (serve-helper '() requests fast-counters slow-counters))
