(define bullet%
  (class object%
    (init-field x
                y
                direction
                [width 7]
                [height 3]
                [damage 5]
                [the-map #f])
    (define vx 1)

    (define/public (remove-self!)
      (when the-map
        (send the-map delete-element! this)
        (set! the-map #f)))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x y width height))
    
    (define/public (move!)
      (set! x ((if (eq? direction 'left) - +) ;; flytta åt rätt håll beroende på riktning
               x
               (* vx *dt*))))
    
    (define/public (update!)
      (move!))
    (super-new)))