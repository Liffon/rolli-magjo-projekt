(load "character.scm")
(load "bullet.scm")

(define player%
  (class character%
    (inherit decelerate!
             push!
             move!
             jump!
             on-ground?)
    (inherit-field x
                   y)
    
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
    
    (define/override (update!)
     (let ((holding-right? (get-key 'right))
           (holding-left? (get-key 'left))
           (holding-jump? (get-key 'jump))
           (holding-sprint? (get-key 'sprint))
           (holding-shoot? (get-key 'shoot))
           (ground-y 250)
           (speed 1))
      
       (define can-shoot? #f)
       
       (when holding-shoot?
         (send timer start 500)
         (send *map* add-element! (new bullet% [x x] [y y]))
         (set! shooting-rate #f))
       
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
        (jump!))
       (move!)))
    (super-new)))



      
