;; enemy.scm
;; =========

;; innehåller klassen enemy%
;; (baseras på character%)

;; Init-argument: se character%
;;   - bitmap-left och bitmap-right har dock inte samma standardvärden som i character%

;; Användningsexempel:
; (new enemy% [x 0] [y 10] [hp 40])

(load "character.scm")

(define enemy%
  (class character%
    (init-field [damage 20]) ;; hur mycket skada spelaren ska ta emot om den krockar med fienden
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
    
    ;; Returnerar en lista över alla bullets som kolliderar med fienden
    (define (colliding-bullets)
      (if the-map
          (send the-map colliding-bullets this)
          '()))
    
    ;; Returnerar nästa pixel (x-koordinat) till vänster om fienden som inte ska kunna passeras.
    ;; (dvs solida tiles och kanter på plattformar)
    (define/override (left-x)
      (max (find-obstacle #t 'left)
           (send the-map get-next-empty-pixel 'left x (find-obstacle #t 'down))))
    
    ;; Som left-x, men åt höger
    (define/override (right-x)
      (min (- (find-obstacle #t 'right) width)
           (- (send the-map get-next-empty-pixel 'right x (find-obstacle #t 'down)) width)))
      
    ;; Avgör vad som ska hända varje frame:
    ;; fienden ska gå framåt tills den stöter emot något
    ;; och skadas av eventuella kulor den krockar med
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
