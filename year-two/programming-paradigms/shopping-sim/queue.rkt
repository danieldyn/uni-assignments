#lang racket
(require racket/match)

(provide empty-queue)
(provide queue-empty?)
(provide enqueue)
(provide dequeue)
(provide top)

(provide (struct-out queue))

;; Working with a queue involves many operations of the type:
;; - enqueue (adding an element to the end of the queue)
;; - dequeue (removing an element from the front of the queue)
;; When the queue is a list, the complexity of operations is:
;; - O(n) for enqueue (given by the complexity of an append)
;; - O(1) for dequeue (given by the complexity of a cdr)
;; We want a constant amortized cost (O(1))
;; for both enqueue and dequeue.
;;
;; Solution: we represent the queue using 2 stacks (lists):
;; - the left stack: we dequeue from left
;;   (O(1) if left has elements, otherwise O(n))
;; - the right stack: we enqueue into right (O(1))
;; |     |    |     |
;; |     |    |__5__|
;; |__1__|    |__4__|
;; |__2__|    |__3__|
;;
;; The only costly operation is dequeue
;; when the left stack is empty.
;; In the example: Assume we have already removed 1 and 2
;; from the queue and we perform a new dequeue.
;; In this case, the complexity is O(n):
;; 1. we move (pop + push) all elements from right 
;;    to left (in order, we extract 5, 4, 3)
;; |     |    |     |      |     |    |     |      |     |    |     |
;; |     |    |     |      |     |    |     |      |__3__|    |     |
;; |     |    |__4__|  ->  |__4__|    |     |  ->  |__4__|    |     |
;; |__5__|    |__3__|      |__5__|    |__3__|      |__5__|    |_____|
;;
;; 2. pop from the left stack, eliminating the value 3
;; Each element of the queue is moved at most once from
;; right to left => amortized cost O(1) per operation.


; We define the "queue" structure by:
; - left   (a stack: dequeue = pop on the left stack)
; - right  (a stack: enqueue = push into the right stack)
; - size-l (the number of elements in the left stack)
; - size-r (the number of elements in the right stack)
(define-struct queue (left right size-l size-r) #:transparent) 


; The value that represents an empty queue.
(define empty-queue
  (make-queue '() '() 0 0))


; Function that checks if a queue is empty.
(define (queue-empty? q)
  (and (null? (queue-left q)) (null? (queue-right q))))


; Function that adds an element to the end of a queue.
; Returns the updated queue.
(define (enqueue x q)
  (struct-copy queue q
               [right (cons x (queue-right q))]
               [size-r (add1 (queue-size-r q))]))


; Function that removes the first element from a non-empty queue.
; Returns the updated queue.
; Note: calling dequeue on an empty queue is expected to throw an error.
(define (dequeue q)
  (if (null? (queue-left q))
      (struct-copy queue q ; moves everything from the right stack to the left stack and then removes the first element
                   [left (cdr (reverse (queue-right q)))]
                   [size-l (sub1 (queue-size-r q))]
                   [right '()]
                   [size-r 0])
      (struct-copy queue q ; only removes the first element from the left stack
                   [left (cdr (queue-left q))]
                   [size-l (sub1 (queue-size-l q))])))


; Function that gets the first element from a non-empty queue.
; Returns the element.
; Note: calling top on an empty queue is expected to throw an error.
(define (get-last L) ; returns the last element of a list (necessary for the worst-case scenario of top q)
  (if (null? (cdr L))
      (car L)
      (get-last (cdr L))))

(define (top q)
  (if (null? (queue-left q))
      (get-last (queue-right q))
      (car (queue-left q))))
