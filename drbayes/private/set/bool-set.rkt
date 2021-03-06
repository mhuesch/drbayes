#lang typed/racket/base

(provide (all-defined-out))

(require "types.rkt"
         "../untyped-utils.rkt")

(struct: Base-Bool-Set Base-Bot-Basic () #:transparent)
(define bool-set? Base-Bool-Set?)

(define-singleton-type Empty-Bool-Set Base-Bool-Set empty-bool-set)
(define-singleton-type Full-Bool-Set Base-Bool-Set bools)
(define-singleton-type True-Bool-Set Base-Bool-Set trues)
(define-singleton-type False-Bool-Set Base-Bool-Set falses)

(define-type Plain-Bool-Set (U True-Bool-Set False-Bool-Set))
(define-type Nonfull-Bool-Set (U Plain-Bool-Set Empty-Bool-Set))
(define-type Nonempty-Bool-Set (U Plain-Bool-Set Full-Bool-Set))
(define-type Bool-Set (U Plain-Bool-Set Empty-Bool-Set Full-Bool-Set))

(: bool-set-member? (-> Bool-Set Boolean Boolean))
(define (bool-set-member? A x)
  (cond [(empty-bool-set? A)  #f]
        [(bools? A)  #t]
        [else  (eq? x (trues? A))]))

(: bool-set-join (case-> (-> Bool-Set Nonempty-Bool-Set (Values Nonempty-Bool-Set #t))
                         (-> Nonempty-Bool-Set Bool-Set (Values Nonempty-Bool-Set #t))
                         (-> Bool-Set Bool-Set (Values Bool-Set #t))))
(define (bool-set-join A B)
  (cond [(empty-bool-set? A)  (values B #t)]
        [(empty-bool-set? B)  (values A #t)]
        [(bools? A)  (values A #t)]
        [(bools? B)  (values B #t)]
        [(eq? A B)  (values A #t)]
        [else  (values bools #t)]))

(: bool-set-intersect (case-> (-> Bool-Set Nonfull-Bool-Set Nonfull-Bool-Set)
                              (-> Nonfull-Bool-Set Bool-Set Nonfull-Bool-Set)
                              (-> Bool-Set Bool-Set Bool-Set)))
(define (bool-set-intersect A B)
  (cond [(bools? A)  B]
        [(bools? B)  A]
        [(empty-bool-set? A)  A]
        [(empty-bool-set? B)  B]
        [(eq? A B)  A]
        [else  empty-bool-set]))

(: bool-set-subtract (case-> (-> Full-Bool-Set Plain-Bool-Set Plain-Bool-Set)
                             (-> Full-Bool-Set Nonfull-Bool-Set Nonempty-Bool-Set)
                             (-> Bool-Set Nonempty-Bool-Set Nonfull-Bool-Set)
                             (-> Bool-Set Bool-Set Bool-Set)))
(define (bool-set-subtract A B)
  (cond [(empty-bool-set? B)  A]
        [(empty-bool-set? A)  A]
        [(bools? B)  empty-bool-set]
        [(bools? A)  (cond [(trues? B)  falses]
                           [else  trues])]
        [(eq? A B)  empty-bool-set]
        [else  A]))

(: bool-set-subseteq? (Bool-Set Bool-Set -> Boolean))
(define (bool-set-subseteq? A B)
  (cond [(empty-bool-set? A)  #t]
        [(empty-bool-set? B)  #f]
        [(bools? B)   #t]
        [(bools? A)   #f]
        [else  (eq? A B)]))

(: booleans->bool-set (case-> (-> #f #f Empty-Bool-Set)
                              (-> #t Boolean Nonempty-Bool-Set)
                              (-> Boolean #t Nonempty-Bool-Set)
                              (-> Boolean Boolean Bool-Set)))
(define (booleans->bool-set t? f?)
  (cond [t?    (if f? bools trues)]
        [else  (if f? falses empty-bool-set)]))

(: bool-set->booleans (-> Bool-Set (Values Boolean Boolean)))
(define (bool-set->booleans A)
  (cond [(empty-bool-set? A)  (values #f #f)]
        [(bools? A)   (values #t #t)]
        [(trues? A)   (values #t #f)]
        [else         (values #f #t)]))

(: boolean->singleton (-> Boolean Plain-Bool-Set))
(define (boolean->singleton b)
  (if b trues falses))

(: bool-set-singleton? (-> Bool-Set Boolean))
(define (bool-set-singleton? A)
  (or (trues? A) (falses? A)))
