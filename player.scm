(load "character.scm")
(load "bullet.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             on-ground?
             hurt!
             switch-weapon!
             shoot!)
    (inherit-field x
                   y
                   width
                   height
                   the-map
                   direction
                   inventory
                   weapon)
    
    (define can-shoot-press #t)
    (define can-shoot-hold #t)
    (define holding-switch-weapon? #f)
    
    (define timer (new timer%
                       [notify-callback (lambda ()
                                          (set! can-shoot-hold #t))]))
    
    (define keys (make-hash))
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    (define/public (get-key key)
      (dict-ref keys key #f))
    
    (define/override (render canvas dc)
      (send the-map draw-rectangle x y width height "blue" canvas dc))
    
    (define (colliding-characters)
      (if the-map
          (send the-map colliding-characters this)
          '()))
    
    (define/override (update!)
      
      (let ([holding-right? (get-key 'right)]
            [holding-left? (get-key 'left)]
            [holding-jump? (get-key 'jump)]
            [holding-sprint? (get-key 'sprint)]
            [holding-shoot? (get-key 'shoot)]
            [next-weapon? (and (not holding-switch-weapon?)
                               (get-key 'next-weapon))]
            [prev-weapon? (and (not holding-switch-weapon?)
                               (get-key 'prev-weapon))]
            [speed 1]
            [collidees (colliding-characters)])
        
        (when next-weapon?
          (switch-weapon! 'next))
        (when prev-weapon?
          (switch-weapon! 'prev))
        (set! holding-switch-weapon? (or (get-key 'next-weapon)
                                         (get-key 'prev-weapon)))
        
        (when (and holding-shoot?
                   (or can-shoot-press ;;man kan skjuta om man inte har knappen nedtryckt. 
                       can-shoot-hold)
                   weapon) 
          
          (shoot!)
          (set! can-shoot-press #f)
          (set! can-shoot-hold #f)
          (send timer start (get-field cooldown weapon) #t)) ;;olika vapen kan ha olika cooldown
        
        (unless (get-key 'shoot) ;; Kollar om skjutknappen är nedtryckt. 
          (set! can-shoot-press #t)) ; Gör så att man kan skjuta igen när man släppt skjutknappen. 
        
        
        (when holding-sprint?
          (set! speed 2.5))
        
        (when holding-right? ;;knuff åt höger
          (set! direction 'right)
          (push! (* 0.05 speed) 0))
        
        (when holding-left? ;;knuff åt vänster
          (set! direction 'left)
          (push! (* -0.05 speed) 0))
        
        (when (and holding-jump? (on-ground?))
          (jump!))
        (move!)
        (for-each (λ (collidee)
                    (hurt! (get-field damage collidee))
                    (displayln `(Ow! ,(get-field damage collidee))))
                  collidees)))
    (super-new)))
