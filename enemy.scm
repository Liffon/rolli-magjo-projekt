(load "character.scm")

(define enemy%
  (class character%
    (init-field [damage 10] [direction 'right])
    (inherit push!
             jump!
             move!
             decelerate!
             left-x
             right-x)
    (inherit-field x)
    
    (define (swap-direction direction)
      (case direction
        ('left 'right)
        ('right 'left)))
    
    (define/override (update!)
      (when (or (= x (left-x))
              (= x (right-x)))
        (set! direction (swap-direction direction))) ;; Vänd när den stöter emot något
      
      (push! (if (eq? direction 'right)
                 0.02
                 -0.02)
             0) ;; gå framåt åt rätt håll hela tiden
      (move!))
    (super-new)))
