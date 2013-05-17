(define tilemap%
  (class object%
    (init-field width
                height
                tile-size
                [tiles #f])
    ;; skapa en hash med bitmaps för alla tile-typer
    (define tile-bitmaps (make-hash))
    (hash-set*! tile-bitmaps
                'ground (read-bitmap "sprites/ground.png")
                'exit (read-bitmap "sprites/exit.png"))
    
    ;; genomskinlig "tile" som bytestring
    ;; för rensning i render-tile
    (define empty-tile-pixels (make-bytes (* tile-size tile-size 4) 0))
    
    ;; ny bitmap med samma storlek som hela tilemapen
    ;; som har en alpha-kanal (dvs kan vara transparent)
    (define tiles-bitmap (make-object bitmap% (* width tile-size) (* height tile-size) #f #t))
    (define tiles-dc (make-object bitmap-dc% tiles-bitmap))
    
    ;; tile : x, y -> vector-index
    ;; returnerar motsvarande index (heltal) i tiles-vectorn
    (define (tile x y)
      (+ (* width y) x))
    
    ;; spara tiles-vectorn till en fil med filnamn filename
    (define/public (dump-tiles-to-file filename)
      (write-to-file tiles filename #:exists 'replace))
    
    ;; ladda in tiles från en vector eller en fil med filnamn input
    (define/public (load-tiles! input)
      (cond
        [(string? input)
         (displayln (string-append "Got filename. Loading tiles from '" input "'..."))
         (set! tiles (file->value input))]
        [(vector? input)
         (set! tiles input)]
        [else (error "load-tiles!: Expected vector or string - got " input)])
      (render-tiles! tiles-dc (range 0 width) (range 0 height)))
    
    (define/public (get-tile-coord-pos x y) ;;tar in pixlar och returnerar tile-koord. 
      (values (inexact->exact (floor (/ x tile-size)))
              (inexact->exact (floor (/ y tile-size)))))
    
    (define/public (valid-tile-coord? x y)
      (and (<= 0 x (- width 1))
           (<= 0 y (- height 1))))
    
    (define/public (get-position-tile x y) ;tar in pixlar som argument.
      (let-values ([(x y) (get-tile-coord-pos x y)])
        (get-tile x y)))
    
    ;; get-next-tile-pixel : solid? x y direction -> heltal
    ;;   Börjar på position (x,y) och går åt hållet direction
    ;;   tills den stöter på en solid eller tom (beroende på "solid?") tile
    ;;   eller tills banan tar slut. Returnerar x- eller y-koordinaten för den punkten
    ;;   (beroende på om den letade i x- eller y-led)
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
                                     (+ (* height tile-size) 80)
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
      (render-tiles! tiles-dc x y))
    
    ;; ritar ut tiles på drawing context dc.
    ;; Om xs och ys är listor, gå igenom alla kombinationer av x och y i listorna.
    ;; om xs och ys är tal, rita ut tilen med koordinater (xs, ys).
    (define/public (render-tiles! dc xs ys)
      (for* ([x (if (list? xs)
                    xs
                    (list xs))]
             [y (if (list? ys)
                    ys
                    (list ys))])
        (let* ([scaled-x (* tile-size x)]
               [scaled-y (* tile-size y)]
               [tile-type (get-tile x y)]
               [tile-bitmap (hash-ref tile-bitmaps tile-type #f)])
          (cond
            [(eq? tile-type 'empty) ; om det ska vara tomt, rensa
             (send dc set-argb-pixels scaled-x scaled-y tile-size tile-size empty-tile-pixels)]
            [tile-bitmap ; om det finns någon bitmap för den typen av tile, rita den
             (send dc draw-bitmap tile-bitmap scaled-x scaled-y)]
            [else (error "Unknown tile type: " tile-type)])))) ; annars, fel!
    
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
    
    ;; om tiles angetts som en vector, kolla att den har rätt längd
    ;; om det är en sträng, ladda in en vector från filen
    ;; annars, initiera en tom vector med rätt längd
    (cond
      [(vector? tiles)
       (unless (= (vector-length tiles) (* width height))
         (error "Bad length of provided init vector: " tiles))]
      [(string? tiles)
       (load-tiles! tiles)]
      [else
       (set! tiles (make-vector (* width height) 'empty))])
    
    (super-new)))
