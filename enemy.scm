(load "character.scm")

(define enemy%
  (class character%
    (init-field [damage 20])
    (inherit push!
             jump!
             move!
             decelerate!
             hurt!
             swap-direction
             find-obstacle)
    (inherit-field x
                   y
                   width
                   the-map
                   direction)
    
;    (define bitmap-left (read-bitmap "sprites/enemy-left.png"))
;    (define bitmap-right (read-bitmap "sprites/enemy-right.png"))
    
    (define (colliding-bullets)
      (if the-map
          (send the-map colliding-bullets this)
          '()))
    
;    (define/override (render canvas dc)
;      (let ([bitmap (if (eq? direction 'left)
;                        bitmap-left
;                        bitmap-right)])
;        (send the-map draw-bitmap bitmap x y canvas dc)))
    
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
    (super-new [bitmap-right (read-bitmap "sprites/enemy-right.png")]
               [bitmap-left (read-bitmap "sprites/enemy-left.png")])))
