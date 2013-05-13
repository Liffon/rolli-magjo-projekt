(define weapon%
  (class object%
    (init-field x
                y
                width
                height
                cooldown
                bullet
                [wielder #f])
    
    (define (make-bullet the-map x y direction)
      (new bullet%
           [x x] [y y] [direction direction]
           [width (get-field width bullet)]
           [height (get-field height bullet)]
           [damage (get-field damage bullet)]
           [speed (get-field speed bullet)]
           [the-map the-map]))
    
    (define/public (fire! the-map direction)
      (when (is-a? wielder player%)
        (let ([x (get-field x wielder)]
              [y (get-field y wielder)])
          (send the-map add-element! (make-bullet the-map x y direction)))))
    
    (super-new)))

(define (make-pistol x y) (new weapon%
                               [x x]
                               [y y]
                               [width 7]
                               [height 5]
                               [cooldown 250]
                               [bullet (new bullet% [width 7] [height 3] [damage 20])]))

(define (make-machine-gun x y) (new weapon%
                               [x x]
                               [y y]
                               [width 12]
                               [height 8]
                               [cooldown 100]
                               [bullet (new bullet% [width 5] [height 2] [damage 10])]))


(load "pistol.scm")