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
                   height
                   the-map)
    
    (define shooting-rate #f)
    
    (define timer (new timer%
                     [notify-callback (lambda ()
                                        (if (and (get-key 'shoot) shooting-rate)
                                            (begin (send *map* add-element! (new bullet% [x x] [y y]))
                                                   (set! shooting-rate #f))
                                        (set! shooting-rate #t)))]))
    (define keys (make-hash))
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    (define/public (get-key key)
      (dict-ref keys key #f))
    
    (define/override (render canvas dc)
      (send dc set-brush "blue" 'solid)
      (send dc draw-rectangle x y width height))
    
    (define/override (update!)
     (let ([holding-right? (get-key 'right)]
           [holding-left? (get-key 'left)]
           [holding-jump? (get-key 'jump)]
           [holding-sprint? (get-key 'sprint)]
           [holding-shoot? (get-key 'shoot)]
           [speed 1]
           [collidees (send the-map colliding-characters this)])
       
       (for-each (λ (collidee)
                   (hurt! (get-field damage collidee))
                   (displayln `(Ow! ,(get-field damage collidee))))
                 collidees))
      
       (define can-shoot? #f)
       
       (when holding-shoot?
         (send timer start 500) ;;ska fixa till
         (send *map* add-element! (new bullet% [x x] [y y]))
         (set! shooting-rate #f))
       
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



      
