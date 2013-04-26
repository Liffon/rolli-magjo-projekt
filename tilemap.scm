(define tilemap%
  (class object%
    (init w
          h
          [tile-size 40])
    (define width w)
    (define height h)
    (define size tile-size)
    (define tile-picture (make-object bitmap% "tile.png"))
    (define all-tiles (new bitmap%))
    
    (define tiles (make-vector (* width height) #f))
    
    (define (tile x y)
      (+ (* width y) x))
    
    (define/public (get-tile-coord-pos x y)
      (values (inexact->exact (floor (/ x size)))
              (inexact->exact (floor (/ y size)))))

    (define/public (valid-tile-coord? x y)
      (and (<= 0 x (- width 1))
           (<= 0 y (- height 1))))
          
    (define/public (get-position-tile x y)
        (get-tile
         (floor (/ x size))
         (floor (/ y size))))
    
    (define/public (get-next-solid pixel-x pixel-y)
      (define (helper tile-x tile-y)
        (cond ((not (valid-tile-coord? tile-x tile-y)) 530) 
              ((get-tile tile-x tile-y)
               (* size tile-y))
              (else (helper tile-x (+ 1 tile-y)))))
      
      (let-values ([(tile-x tile-y) (get-tile-coord-pos pixel-x
                                                        pixel-y)]) 
            (helper tile-x tile-y)))
    
    (define/public (get-tile x y)
      (vector-ref tiles (tile x y)))
    
    (define/public (set-tile! x y value)
      (vector-set! tiles (tile x y) value))
    
    (define (render-tile canvas dc x y)
      (let ((scaled-x (* size x))
            (scaled-y (* size y)))
        (when (get-tile x y)
          ;rita ut det som finn
          (send dc draw-bitmap tile-picture scaled-x scaled-y))))
      
    (define/public (render canvas dc scrolled-distance)
      (let* ((canvas-width (send canvas get-width))
             (left-x (inexact->exact (floor (/ scrolled-distance size))))
             (right-x (inexact->exact (ceiling (/ canvas-width size))))
             (x-list (range 0 right-x))
             (y-list (range 0 height)))
;        (displayln canvas-width)
;        (displayln (/ canvas-width size))
;        (displayln x-list)
        (send dc translate (- scrolled-distance) 0)  
        (for-each (λ (x)
                    (for-each (λ (y)
                                (render-tile canvas dc x y))
                              y-list))
                    x-list)
        (send dc translate scrolled-distance 0)))
      
  (super-new)))
