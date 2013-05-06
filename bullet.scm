(define bullet%
  (class object%
    (init-field x
                y
                [width 7]
                [height 3])
    (define vx 1)
    (define the-map #f)
    
    (define/public (set-map! new-map)
      (set! the-map new-map))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x y width height))
    
    (define/public (move!)
      (set! x (+ x (* vx *dt*))))
    
    (define/public (update!)
      (move!))
    (super-new)))