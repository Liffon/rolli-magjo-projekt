(define bullet%
  (class object%
    (init-field width
                height
                damage
                [x #f]
                [y #f]
                [direction #f]
                [speed 1]
                [the-map #f])

    (define/public (remove-self!)
      (when the-map
        (send the-map delete-element! this)
        (set! the-map #f)))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x y width height))
    
    (define/public (move!)
      (set! x ((if (eq? direction 'left) - +) ;; flytta åt rätt håll beroende på riktning
               x
               (* speed *dt*))))
    
    (define/public (update!)
      (move!))
    (super-new)))
