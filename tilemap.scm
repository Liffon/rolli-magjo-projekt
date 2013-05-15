(define tilemap%
  (class object%
    (init-field width height tile-size)
    (define tile-bitmaps (make-hash))
    (hash-set*! tile-bitmaps
               'ground (make-object bitmap% "tile.png")
               'exit (make-object bitmap% "tile.png"))
    (define empty-tile-pixels (make-bytes (* tile-size tile-size 4) 0)) ;; genomskinlig "tile" som bytestring
    
    ;; ny bitmap med samma storlek som hela tilemapen
    ;; som har en alpha-kanal (dvs kan vara transparent)
    (define tiles-bitmap (make-object bitmap% (* width tile-size) (* height tile-size) #f #t))
    (define tiles-dc (make-object bitmap-dc% tiles-bitmap))
    
    (define tiles (make-vector (* width height) 'empty))
    
    (define (tile x y)
      (+ (* width y) x))
    
    (define/public (get-tile-coord-pos x y) ;;tar in pixlar och returnerar tile-koord. 
      (values (inexact->exact (floor (/ x tile-size)))
              (inexact->exact (floor (/ y tile-size)))))

    (define/public (valid-tile-coord? x y)
      (and (<= 0 x (- width 1))
           (<= 0 y (- height 1))))
          
    (define/public (get-position-tile x y) ;tar in pixlar som argument.
      (let-values ([(x y) (get-tile-coord-pos x y)])
        (get-tile x y)))
    
    (define/public (get-next-tile-pixel solid? direction pixel-x pixel-y)
      (let-values ([(tile-x tile-y) (get-tile-coord-pos pixel-x pixel-y)]
                   [(next-x next-y end-coordinate pixel-result) ;; fortsätt loopen olika beroende på riktning
                    (case direction
                      ('up (values identity
                                   sub1 
                                   0
                                   (λ (tile-x tile-y)
                                     (sub1 (+ (* tile-size tile-y) tile-size)))))
                      ('down (values identity
                                     add1
                                     (* (+ height 1) tile-size) ;; borde egentligen vara strax nedanför skärmen
                                     (λ (tile-x tile-y)
                                       (* tile-size tile-y))))
                      ('right (values add1
                                      identity
                                      (* width tile-size)
                                      (λ (tile-x tile-y)
                                        (* tile-size tile-x))))
                      ('left (values sub1
                                     identity
                                     0
                                     (λ (tile-x tile-y)
                                       (+ (* tile-size tile-x) tile-size)))))])
        (define (helper tile-x tile-y)
        (cond [(not (valid-tile-coord? tile-x tile-y)) end-coordinate]
              [((if solid? identity not) (solid-tile? tile-x tile-y))
               (pixel-result tile-x tile-y)]
              [else (helper (next-x tile-x) (next-y tile-y))]))
        (helper tile-x tile-y)))
    
    (define/public (solid-tile? x y)
      (eq? (get-tile x y) 'ground))
    
    (define/public (solid-tile-at? pixel-x pixel-y)
      (let-values ([(x y) (get-tile-coord-pos pixel-x pixel-y)])
        (if (valid-tile-coord? x y)
            (solid-tile? x y)
            #f)))

    (define/public (get-tile x y)
      (vector-ref tiles (tile x y)))
    
    (define/public (set-tile! x y value)
      (vector-set! tiles (tile x y) value)
      (render-tile tiles-dc x y))
    
    (define (render-tile dc x y)
      (let* ([scaled-x (* tile-size x)]
             [scaled-y (* tile-size y)]
             [tile-type (get-tile x y)]
             [tile-bitmap (hash-ref tile-bitmaps tile-type #f)])
        (cond
          [(eq? tile-type 'empty) ; om det ska vara tomt, rensa
            (send dc set-argb-pixels scaled-x scaled-y tile-size tile-size empty-tile-pixels)]
          [tile-bitmap ; om det fanns någon bitmap för den typen av tile, rita den
           (send dc draw-bitmap tile-bitmap scaled-x scaled-y)]
          [else (error "Unknown tile type: " tile-type)])))
      
    (define/public (render canvas dc scrolled-distance)
      (let* ([canvas-width (send canvas get-width)]
             [canvas-height (send canvas get-height)]
             [left-x (inexact->exact (floor (/ scrolled-distance tile-size)))]
             [right-x (inexact->exact (ceiling (/ canvas-width tile-size)))]
             [x-list (range 0 right-x)]
             [y-list (range 0 height)])
        (send dc draw-bitmap-section tiles-bitmap
              0 0 ;; dest-x dest-y
              scrolled-distance 0 ;; src-x src-y
              canvas-width canvas-height))) ;; src-width src-height
      
  (super-new)))
