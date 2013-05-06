(load "character.scm")
(load "bullet.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             hurt!
             on-ground?)
    (inherit-field x
                   y
                   width
                   height)
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
      
       (when holding-shoot?
         (let ((round (new bullet% [x x] [y y])))
           (send *map* add-object! round)))
       
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



      
