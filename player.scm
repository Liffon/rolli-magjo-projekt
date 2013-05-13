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
    (define holding-next-weapon? #f)
    
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
    
    (define/public (switch-weapon!)
      (unless (null? inventory) ;; borde kunna göras snyggare med en ring istället
        (let ([rest (member weapon inventory)])
          (if (null? (cdr rest))
              (set! weapon (car inventory))
              (set! weapon (cadr rest)))))
      (displayln "Switch!"))
    
    (define/override (update!)
      
      (let ([holding-right? (get-key 'right)]
            [holding-left? (get-key 'left)]
            [holding-jump? (get-key 'jump)]
            [holding-sprint? (get-key 'sprint)]
            [holding-shoot? (get-key 'shoot)]
            [switch-weapon? (and (not holding-next-weapon?)
                                 (get-key 'next-weapon))]
            [speed 1]
            [collidees (colliding-characters)])
        
        (when switch-weapon?
            (switch-weapon!))
        (set! holding-next-weapon? (get-key 'next-weapon))
        
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
