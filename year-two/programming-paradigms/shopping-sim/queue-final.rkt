#lang racket
(require racket/match)

(provide empty-queue)
(provide make-queue)
(provide queue-empty?)
(provide rotate)
(provide enqueue)
(provide dequeue)
(provide top)

(provide (struct-out queue))

;; In part 3 we implemented the queue ADT ensuring amortized O(1) cost
;; for both enqueue and dequeue.
;; We represented the queue as a collection of 2 stacks:
;; - the left stack: for removing elements upon dequeue 
;; - the right stack: for adding elements upon enqueue 
;;
;; The only case where an operation was not O(1) was dequeue when the left stack was empty.
;; Such a dequeue was O(n), due to moving all elements from right to left.
;; We want to improve the worst-case cost of the dequeue operation,
;; from O(n) to O(1).
;;
;; Solution: we keep the 2-stack representation, but we ensure that, upon dequeue, 
;; the left stack is never empty, maintaining the invariant:
;;        size(left) ≥ size(right)
;; Whenever an operation leads to the violation of the invariant, we perform a rotation:
;;        <left, right>   becomes   <left ++ (reverse right), []>
;; As long as the stacks are Racket lists, a rotation has O(n) complexity,
;; caused by append and reverse. Is there a better representation?
;;
;; Yes! We will represent the left stack as a stream.
;; Unlike append (denoted here ++) on lists (O(n)),
;; append on streams is an incremental operation:
;; - the elements in the result are provided one by one, when needed
;; - ex: A = the stream [1,2,3,4,5], represented as (stream-cons 1 <delayed-computation-rest>)
;;       B = some random stream
;;       A ++ B will be (stream-cons 1 <delayed-computation-append-between-restA-and-B>)
;;   (this result is obtained in O(1) time)
;; Thus we solve the complexity of the append operation from the expression
;;       "left ++ (reverse right)"
;;
;; How do we solve the complexity of the reverse operation from the same expression?
;; Since append is already an incremental operation, the idea is to perform one 
;; reverse step every time we perform an append step.
;; This trick finishes both operations at roughly the same time,
;; as rotations trigger when right becomes longer than left,
;; meaning size(right) = size(left) + 1.
;; Remember the code for append, and tail-recursive reverse respectively:
;; (define (append A B)                     (define (reverse L Acc)
;;   (if (null? A)                            (if (null? L)
;;       B                                        Acc
;;       (cons (car A) (append (cdr A) B))))      (reverse (cdr L) (cons (car L) Acc))))
;;
;; We implement a rotation according to the following axioms
;; (notice the fusion of append and reverse):
;; rotate([], [y], Acc)        = y : Acc                    
;; rotate((x:xs), (y:ys), Acc) = x : rotate(xs, ys, y : Acc)
;; Note: 
;; - x : rotate(...) represents an append step ( : means cons)
;; - y : Acc         represents a reverse step


; The queue structure does not change.
; What changes is the implementation of the left field
; - from a list, left becomes a stream
; - this is not visible in the queue structure definition,
;   but in the implementation of the type's operations 
(define-struct queue (left right size-l size-r) #:transparent) 


; The value that represents an empty queue.
(define empty-queue
  (make-queue empty-stream '() 0 0))


; Function that checks if a queue is empty.
(define (queue-empty? q)
  (stream-empty? (queue-left q)))

;; We implement a rotation according to the following axioms
;; rotate([], [y], Acc)        = y : Acc                    
;; rotate((x:xs), (y:ys), Acc) = x : rotate(xs, ys, y : Acc)
;; Note: 
;; - x : rotate(...) represents an append step ( : means cons)
;; - y : Acc         represents a reverse step


; The rotate function, according to the axioms above.
(define (rotate left right Acc)
  (if (stream-empty? left)
      (stream-cons (car right) Acc)
      (stream-cons (stream-first left)
                   (rotate (stream-rest left)
                           (cdr right)
                           (stream-cons (car right) Acc)))))

; Function that adds an element to the end of a queue.
; Returns the updated queue.
(define (enqueue x q)
  (let* ([new-size-r (add1 (queue-size-r q))]
         [new-size-l (queue-size-l q)]
         [new-right (cons x (queue-right q))]
         [new-left (queue-left q)])
    (if (>= new-size-l new-size-r)
        (make-queue new-left new-right new-size-l new-size-r) ; the invariant is already respected
        (make-queue (rotate new-left new-right empty-stream) '() (+ new-size-l new-size-r) 0))))


; Function that removes the first element from a non-empty queue.
; Returns the updated queue.
; Note: calling dequeue on an empty queue is expected to throw an error.
(define (dequeue q)
  (let* ([new-size-r (queue-size-r q)]
         [new-size-l (sub1 (queue-size-l q))]
         [new-left (stream-rest (queue-left q))]
         [new-right (queue-right q)]) 
    (if (>= new-size-l new-size-r)
        (make-queue new-left new-right new-size-l new-size-r) ; the invariant is already respected
        (make-queue (rotate new-left new-right empty-stream) '() (+ new-size-l new-size-r) 0))))


; Function that gets the first element from a non-empty queue.
; Returns the element.
; Note: calling top on an empty queue is expected to throw an error.
(define (top q)
  (stream-first (queue-left q)))
