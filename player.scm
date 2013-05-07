(load "character.scm")
(load "bullet.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             on-ground?
             hurt!)
    (inherit-field x
                   y
                   width
                   height)
    
    (define can-shoot-press #t)
    (define can-shoot-hold #t)
    
    (define timer (new timer%
                     [notify-callback (lambda ()
                                        (set! can-shoot-hold #t))]))
    
    (define keys (make-hash))
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    (define/public (get-key key)
      (dict-ref keys key #f))
    
    (define/override (render canvas dc)
      (send dc set-brush "blue" 'solid)
      (send dc draw-rectangle x y width height))
    
    (define/override (update!)
     (let ((holding-right? (get-key 'right))
           (holding-left? (get-key 'left))
           (holding-jump? (get-key 'jump))
           (holding-sprint? (get-key 'sprint))
           (holding-shoot? (get-key 'shoot))
           (ground-y 250)
           (speed 1))
       
       ;(if (send the-map overlapping-width this 
       
       
       (when (and holding-shoot?
                  (or can-shoot-press ;;man kan skjuta om man inte har knappen nedtryckt. 
                      can-shoot-hold)) ;;om man håller inne knappen skjuts ett skott var 250 ms. 
         (begin
           (send *map*  add-element! (new bullet% [x x] [y y]))
           (set! can-shoot-press #f)
           (set! can-shoot-hold #f)
           (send timer start 250 #t)))
       
       (unless (get-key 'shoot) ;; Kollar om skjutknappen är nedtryckt. 
         (set! can-shoot-press #t)) ; Gör så att man kan skjuta igen när man släppt skjutknappen. 
            
       
       (when holding-sprint?
         (set! speed 2.5))
         
       (when holding-right? ;;knuff åt höger
         (push! (* 0.05 speed) 0))
       
       (when holding-left? ;;knuff åt vänster
         (push! (* -0.05 speed) 0))
      
       (when (and (on-ground?) holding-jump?)
         (jump!))
       (move!)))
    (super-new)))



      
