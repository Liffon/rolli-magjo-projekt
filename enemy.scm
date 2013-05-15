(load "character.scm")

(define enemy%
  (class character%
    (init-field [damage 10])
    (inherit push!
             jump!
             move!
             decelerate!
             hurt!
             swap-direction
             find-obstacle)
    (inherit-field x
                   width
                   the-map
                   direction)
    
    (define (colliding-bullets)
      (if the-map
          (send the-map colliding-bullets this)
          '()))
    
    (define/override (left-x)
      (max (find-obstacle #t 'left)
           (send the-map get-next-empty-pixel 'left x (find-obstacle #t 'down))))
    
    (define/override (right-x)
      (min (- (find-obstacle #t 'right) width)
           (- (send the-map get-next-empty-pixel 'right x (find-obstacle #t 'down)) width)))
      
    (define/override (update!)
      (let ([colliding-bullets (colliding-bullets)])
        (for-each (λ (bullet)
                    (hurt! (get-field damage bullet))
                    (send bullet remove-self!))
                  colliding-bullets)
        
        (when the-map
          (when (or (= x (left-x))
                    (= x (right-x)))
            (set! direction (swap-direction direction)));; Vänd när den stöter emot något
            
          (push! (if (eq? direction 'right)
                     0.02
                     -0.02)
                 0) ;; gå framåt åt rätt håll hela tiden
          (move!))))
    (super-new)))
