(define bullet%
  (class object%
    (init-field x
                y
                [width 10]
                [height 10])
    (define vx 10)
    (define the-map #f)
    
    (define/public (set-map! new-map)
      (set! the-map new-map))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x y width height))
    
    (define/public (move!)
      (set! x (* vx *dt*)))
    
    (define/public (update!)
      (move!))
    (super-new)))