(define tile-map%
  (class object%
    (init w
          h)
    (define width w)
    (define height h)
    
    (define tiles (make-vector (* width height) #f))
    
    (define (tile x y)
      (+ (* width y) x))
    
    (define/public (get-tile x y)
      (vector-ref tiles (tile x y)))
    
    (define/public (set-tile! x y value)
      (vector-set! tiles (tile x y) value))
  (super-new)))