(load "character.scm")

(define enemy%
  (class character%
    (inherit push!
             jump!
             move!
             decelerate!)
    (define/override (update!)
      (push! 0.02 0)
      (move!))
    (super-new)))
             