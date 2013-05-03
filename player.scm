(load "character.scm")
(load "bullet.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             on-ground?
             x-pos
             y-pos)
    (inherit-field x
                   y)
    (define keys (make-hash))
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    (define/public (get-key key)
      (dict-ref keys key #f))
    
    (define/override (update!)
     (let ((holding-right? (get-key 'right))
           (holding-left? (get-key 'left))
           (holding-jump? (get-key 'jump))
           (holding-sprint? (get-key 'sprint))
           (holding-shoot? (get-key 'shoot))
           (ground-y 250)
           (speed 1))
      
       (when holding-shoot?
         (let ((round (new bullet% [x (x-pos)] [y (y-pos)])))
           (send *map* add-object! round)))
       
       (when holding-sprint?
         (set! speed 2.5))
         
       (when holding-right?
         ;;knuff åt höger
         (push! (* 0.05 speed) 0))
       
       (when holding-left?
         ;;knuff åt vänster
         (push! (* -0.05 speed) 0))
      
      (when (and (on-ground?) holding-jump?)
        ;;knuff uppåt
        ;;todo: kolla att man får hoppa
;        (displayln "Jump!")
        (jump!))
       (move!)))
    (super-new)))



      
