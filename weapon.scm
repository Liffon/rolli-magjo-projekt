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
        (displayln "Bang!")
        (let ([x (get-field x wielder)]
              [y (get-field y wielder)])
          (send the-map add-element! (make-bullet the-map x y direction)))))
    
    (super-new)))

(load "pistol.scm")