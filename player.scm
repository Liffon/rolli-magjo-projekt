(load "character.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             on-ground?
             hurt!
             switch-weapon!
             die!
             shoot!)
    (inherit-field x
                   y
                   width
                   height
                   the-map
                   direction
                   inventory
                   weapon)
    
    (define bitmap (read-bitmap "sprites/player.png"))
    (define can-shoot-press #t)
    (define can-shoot-hold #t)
    (define holding-switch-weapon? #f)
    (define can-be-hurt #t)
    
    (define shoot-timer (new timer%
                       [notify-callback (lambda ()
                                          (set! can-shoot-hold #t))]))
    (define hurt-timer (new timer%
                            [notify-callback (lambda ()
                                               (set! can-be-hurt #t))]))
    
    (define keys (make-hash))
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    (define/public (get-key key) ;; Tar in en knapptryckning som argument och returnerar ett booleskt värde som representerar om
      (dict-ref keys key #f))    ;; knappen har någon funktion. 
    
    (define/override (render canvas dc) ;; Tar canvas och dc som argument och säger till banan att rita ut spelaren. 
      (send the-map draw-bitmap bitmap x y canvas dc))
    
    
    (define (colliding-characters) ;; Sänder banan en lista med de karaktärer som spelaren krockar med. 
      (if the-map
          (send the-map colliding-characters this)
          '()))
    
    (define/override (update!) ;; Avgör vad som ska hända under varje frame.
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
                   (or can-shoot-press
                       can-shoot-hold)
                   weapon) 
          
          (shoot!)
          (set! can-shoot-press #f)
          (set! can-shoot-hold #f)
          (send shoot-timer start (get-field cooldown weapon) #t)) ;;olika vapen kan ha olika cooldown
        
        (unless (get-key 'shoot) ;; Kollar om skjutknappen är nedtryckt. 
          (set! can-shoot-press #t)) ; Gör så att man kan skjuta igen när man släppt skjutknappen. 
        
        
        (when holding-sprint? ;; öka hastigheten om man håller nere sprint
          (set! speed 2.5))
        
        ;; ändra hastigheten när man håller nere vänster eller höger
        (when holding-right?
          (set! direction 'right)
          (push! (* 0.05 speed) 0))
        
        (when holding-left?
          (set! direction 'left)
          (push! (* -0.05 speed) 0))
        
        ;; Gör så att man hoppar om man står på marken och trycker på hoppknappen.
        (when (and holding-jump? (on-ground?))
          (jump!))
        (move!)
        (for-each (λ (collidee)
                      (if (eq? (get-field direction collidee) 'right)
                          (push! 0.2 0)
                          (push! -0.2 0))
                    (when can-be-hurt
                      (hurt! (get-field damage collidee))
                      (set! can-be-hurt #f)
                      (send hurt-timer start 500 #t)))
                  collidees)
        (when (>= y (* (get-field height the-map)
                       (get-field tile-size the-map)))
          (die!))))
    (super-new)))
