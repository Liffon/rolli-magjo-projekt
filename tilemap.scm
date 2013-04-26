(define tilemap%
  (class object%
    (init w
          h
          [tile-size 40])
    (define width w)
    (define height h)
    (define size tile-size)
    (define tile-picture (make-object bitmap% "tile.png"))
    
    ;; ny bitmap med samma storlek som hela tilemapen
    ;; som har en alpha-kanal (dvs kan vara transparent)
    (define tiles-bitmap (make-object bitmap% (* width size) (* height size) #f #t))
    (define tiles-dc (make-object bitmap-dc% tiles-bitmap))
    
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
    
    (define/public (get-next-solid-under pixel-x pixel-y)
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
      (vector-set! tiles (tile x y) value)
      (render-tile tiles-dc x y))
    
    (define (render-tile dc x y)
      (let ((scaled-x (* size x))
            (scaled-y (* size y)))
        (when (get-tile x y)
          ;rita ut det som finns
          (send dc draw-bitmap tile-picture scaled-x scaled-y))))
      
    (define/public (render canvas dc scrolled-distance)
      (let* ((canvas-width (send canvas get-width))
             (canvas-height (send canvas get-height))
             (left-x (inexact->exact (floor (/ scrolled-distance size))))
             (right-x (inexact->exact (ceiling (/ canvas-width size))))
             (x-list (range 0 right-x))
             (y-list (range 0 height)))
        (send dc draw-bitmap-section tiles-bitmap
              0 0 ;; dest-x dest-y
              scrolled-distance 0 ;; src-x src-y
              canvas-width canvas-height))) ;; src-width src-height
      
  (super-new)))
