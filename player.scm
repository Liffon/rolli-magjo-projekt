;; player.scm
;; ==========

;; innehåller klassen player%
;; (baseras på character%)

;; Init-argument: se character%
;;   - width, height, bitmap-left och bitmap-right har dock inte samma standardvärden som i character%

;; Användningsexempel:
; (new player% [x 0] [y 10] [hp 220])

(load "character.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             on-ground?
             hurt!
             take-weapon!
             switch-weapon!
             die!
             shoot!)
    (inherit-field x
                   y
                   width
                   height
                   hp
                   the-map
                   direction
                   inventory
                   weapon)
    (field [has-won? #f])
    (define can-shoot-press #t)
    (define can-shoot-hold #t)
    (define holding-switch-weapon? #f)
    (define can-be-hurt #t)
    
    ;;styr hur ofta man kan skjuta
    
    (define shoot-timer (new timer%
                       [notify-callback (lambda ()
                                          (set! can-shoot-hold #t))]))
    ;;styr hur ofta man kan ta skada
    
    (define hurt-timer (new timer%
                            [notify-callback (lambda ()
                                               (set! can-be-hurt #t))]))
    
    (define keys (make-hash))
    
    ;; Tar in en nyckel och ett booleskt värde som argument och sätter rätt nyckel till det booleska värdet. 
    
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    ;; Tar in en knapptryckning som argument och returnerar ett booleskt värde som representerar om
    ;; knappen är nedtryckt.  
    (define/public (get-key key) 
      (dict-ref keys key #f))    
    
    
    (define (colliding-characters) ;; Returnerar en lista med de karaktärer som spelaren krockar med. 
      (if the-map
          (send the-map colliding-characters this)
          '()))
    
    (define (colliding-items) ;; Returnerar en lista med de items (vapen) som spelaren krockar med.
      (if the-map
          (send the-map colliding-items this)
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
        
        (for-each (λ (item) ;; ta upp alla vapen som kolliderar med spelaren
                    (send the-map delete-element! item)
                    (take-weapon! item))
                  (colliding-items))
        
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
;                    (cond ((zero? (get-field vx this))
                           (if (eq? (get-field direction collidee) 'right)
                               (push! 0.2 0)
                               (push! -0.2 0))
;                          ((< (get-field x this) (get-field x collidee))
;                           (push! -0.2 0)
;                           (push! 0.2 0)))
                    (when can-be-hurt
                      (hurt! (get-field damage collidee))
                      (set! can-be-hurt #f)
                      (send hurt-timer start 500 #t)))
                  collidees)
        ;; om man är nedanför banan, dö!
        (when (and the-map
                   (>= y (* (get-field height the-map)
                            (get-field tile-size the-map))))
          (die!))))
    (super-new [bitmap-left (read-bitmap "sprites/player-left.png")]
               [bitmap-right (read-bitmap "sprites/player-right.png")]
               [width 31] [height 73])))
