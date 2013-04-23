(define tilemap%
  (class object%
    (init w
          h
          [tile-size 20])
    (define width w)
    (define height h)
    (define size tile-size)
    
    (define tiles (make-vector (* width height) #f))
    
    (define (tile x y)
      (+ (* width y) x))
    
    (define/public (get-tile x y)
      (vector-ref tiles (tile x y)))
    
    (define/public (set-tile! x y value)
      (vector-set! tiles (tile x y) value))
    
    (define (render-tile canvas dc x y)
      (send dc draw-rectangle (* size x) (* size y) size size))
    
    (define/public (render canvas dc scrolled-distance)
      (let* ((canvas-width (send canvas get-width))
             (left-x (inexact->exact (floor (/ scrolled-distance size))))
             (right-x (+ left-x (inexact->exact (ceiling (/ canvas-width size)))))
             (x-list (range left-x (+ right-x 1)))
             (y-list (range 0 height)))
        (send dc translate (- scrolled-distance) 0)  
        (for-each (λ (x)
                    (for-each (λ (y)
                                (render-tile canvas dc x y))
                              y-list))
                    x-list)
        (send dc translate scrolled-distance 0)))
      
  (super-new)))