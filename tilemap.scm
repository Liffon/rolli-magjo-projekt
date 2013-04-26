(define tilemap%
  (class object%
    (init w
          h
          [tile-size 40])
    (define width w)
    (define height h)
    (define size tile-size)
    (define tile-picture (make-object bitmap% "tile.png"))
    ;(define all-tiles (new bitmap%))
    
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
    
    (define/public (get-next-solid-pixel direction pixel-x pixel-y)
      (let-values ([(tile-x tile-y) (get-tile-coord-pos pixel-x
                                                        pixel-y)]
                   ((next-x next-y end-coordinate pixel-result)
                    (case direction
                      ('up (values identity sub1 0 (lambda (tile-x tile-y)
                                                     (sub1 (+ (* size tile-y) size)))))
                      ('down (values identity add1 (* (+ height 1) size) (lambda (tile-x tile-y)
                                                                           (* size tile-y))))
                      ('right (values add1 identity (add1 (* width size)) (lambda (tile-x tile-y)
                                                                            (* size tile-x))))
                      ('left (values sub1 identity 0 (lambda (tile-x tile-y)
                                                     (+ (* size tile-x) size)))))))
      (define (helper tile-x tile-y)
        (cond ((not (valid-tile-coord? tile-x tile-y)) end-coordinate) 
              ((get-tile tile-x tile-y)
               (pixel-result tile-x tile-y))
              (else (helper (next-x tile-x) (next-y tile-y)))))
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
