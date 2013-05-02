(define tilemap%
  (class object%
    (init w
          h
          [tile-size 40])
    (define width w)
    (define height h)
    (define size tile-size)
    (define tile-picture (make-object bitmap% "tile.png"))
    (define empty-tile-pixels (make-bytes (* size size 4) 0)) ;; genomskinlig "tile" som bytestring
    
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
         (inexact->exact (floor (/ x size))) ;;la till heltalskonvertering
         (inexact->exact (floor (/ y size)))));;la till heltalskonvertering
    
    (define/public (get-next-solid-pixel direction pixel-x pixel-y)
      (let-values ([(tile-x tile-y) (get-tile-coord-pos pixel-x pixel-y)]
                   [(next-x next-y end-coordinate pixel-result) ;; fortsätt loopen olika beroende på riktning
                    (case direction
                      ('up (values identity
                                   sub1 
                                   0
                                   (λ (tile-x tile-y)
                                     (sub1 (+ (* size tile-y) size)))))
                      ('down (values identity
                                     add1
                                     (* (+ height 1) size) ;; borde egentligen vara strax nedanför skärmen
                                     (λ (tile-x tile-y)
                                       (* size tile-y))))
                      ('right (values add1
                                      identity
                                      (add1 (* width size))
                                      (λ (tile-x tile-y)
                                        (* size tile-x))))
                      ('left (values sub1
                                     identity
                                     0
                                     (λ (tile-x tile-y)
                                       (+ (* size tile-x) size)))))])
      (define (helper tile-x tile-y)
        (cond [(not (valid-tile-coord? tile-x tile-y)) end-coordinate]
              [(get-tile tile-x tile-y)
               (pixel-result tile-x tile-y)]
              [else (helper (next-x tile-x) (next-y tile-y))]))
        (helper tile-x tile-y)))
    
    (define/public (get-tile x y)
      (vector-ref tiles (tile x y)))
    
    (define/public (set-tile! x y value)
      (vector-set! tiles (tile x y) value)
      (render-tile tiles-dc x y))
    
    (define (render-tile dc x y)
      (let ([scaled-x (* size x)]
            [scaled-y (* size y)])
        (if (get-tile x y)
            (send dc draw-bitmap tile-picture scaled-x scaled-y) ;; Rita om det finns en tile
            (send dc set-argb-pixels scaled-x scaled-y size size empty-tile-pixels)))) ;; Annars, rensa
      
    (define/public (render canvas dc scrolled-distance)
      (let* ([canvas-width (send canvas get-width)]
             [canvas-height (send canvas get-height)]
             [left-x (inexact->exact (floor (/ scrolled-distance size)))]
             [right-x (inexact->exact (ceiling (/ canvas-width size)))]
             [x-list (range 0 right-x)]
             [y-list (range 0 height)])
        (send dc draw-bitmap-section tiles-bitmap
              0 0 ;; dest-x dest-y
              scrolled-distance 0 ;; src-x src-y
              canvas-width canvas-height))) ;; src-width src-height
      
  (super-new)))
