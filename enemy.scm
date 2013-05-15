(load "character.scm")

(define enemy%
  (class character%
    (init-field [damage 10])
    (inherit push!
             jump!
             move!
             decelerate!
             left-x
             right-x
             hurt!
             swap-direction)
    (inherit-field x
                   the-map
                   direction)
    
    (define (colliding-bullets)
      (if the-map
          (send the-map colliding-bullets this)
          '()))
    
    (define/override (update!)
      (let ([colliding-bullets (colliding-bullets)])
        (for-each (λ (bullet)
                    (hurt! (get-field damage bullet))
                    (send bullet remove-self!))
                  colliding-bullets)
        
        (when the-map
          (when (or (= x (left-x))
                    (= x (right-x))
            (set! direction (swap-direction direction)));; Vänd när den stöter emot något
          (push! (if (eq? direction 'right)
                     0.02
                     -0.02)
                 0) ;; gå framåt åt rätt håll hela tiden
          (move!))))
    (super-new)))
