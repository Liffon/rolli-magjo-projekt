(load "tilemap.scm")
(define *tilemap* #f) ;; för debugging - ta bort sen!

(define map%
  (class object%
    (init-field width height tile-size)

    (define tilemap (new tilemap%
                         [width width]
                         [height height]
                         [tile-size tile-size]))
    (set! *tilemap* tilemap) ;; för debugging - ta bort sen!
    (field [scrolled-distance 0]
           [characters '()]
           [bullets '()]
           [canvas #f])
    
    ;; initialisera en testbana
    (for-each (λ (x)
                (send tilemap set-tile! x 11 'ground))
              (range 0 28))
    (for-each (λ (x)
                (send tilemap set-tile! x 10 'ground))
              (range 29 32))
    (send tilemap set-tile! 5 11 #f)
    (for-each (λ (x)
                (send tilemap set-tile! x 7 'ground))
              (range 6 13))
    (send tilemap set-tile! 13 8 'ground)
    (send tilemap set-tile! 15 9 'ground)
    (send tilemap set-tile! 15 10 'ground)
    
    ;; Hjälpfunktion för kollisionshantering mellan objekt
    (define/public (colliding? obj1 obj2)
      ;; kollar om paren ligger utan "överlappande punkter"
      (define (separated-pairs? x1a x1b x2a x2b)
        (or (> (min x1a x1b) (max x2a x2b))
            (< (max x1a x1b) (min x2a x2b))))
      (if (and (or (is-a? obj1 player%) ;; den här kollen bör göras med ett interface istället
                   (is-a? obj1 enemy%)
                   (is-a? obj1 bullet%)
                   (is-a? obj1 character%))
               (or (is-a? obj2 player%)
                   (is-a? obj2 enemy%)
                   (is-a? obj2 bullet%)
                   (is-a? obj2 character%)))
          (let ([x1 (get-field x obj1)]
                [y1 (get-field y obj1)]
                [x2 (get-field x obj2)]
                [y2 (get-field y obj2)]
                [w1 (get-field width obj1)]
                [h1 (get-field height obj1)]
                [w2 (get-field width obj2)]
                [h2 (get-field height obj2)])
            (and (not (separated-pairs? x1 (+ x1 w1)
                                        x2 (+ x2 w2)))
                 (not (separated-pairs? y1 (+ y1 h1)
                                        y2 (+ y2 h2)))))
          #f))
    
    (define/public (colliding-bullets obj)
      (colliding-in bullets obj))
    
    (define/public (colliding-characters obj)
      (colliding-in characters obj))
    
    (define/public (colliding-in lst obj)
      (filter (λ (element)
                (and (not (eq? obj element)) ;; krockar inte med sig själv
                     (colliding? obj element)))
              lst))
        
    (define/public (colliding-tiles obj)
      (let ([x (get-field x obj)]
            [y (get-field y obj)]
            [width (get-field width obj)]
            [height (get-field height obj)])
        (or (solid-tile-at? x y)
            (solid-tile-at? (+ x width -1) y)
            (solid-tile-at? x (+ y height -1))
            (solid-tile-at? (+ x width -1) (+ y height -1)))))
             
    (define/public (get-next-solid-pixel . args) ;; skicka vidare alla argument
      (send tilemap get-next-solid-pixel . args)) ; till tilemap
    
    (define/public (get-position-tile . args)
      (send tilemap get-position-tile . args))
    
    (define/public (solid-tile-at? . args)
      (send tilemap solid-tile-at? . args))
    
    (define/public (add-element! element)
      (set-field! the-map element this) ;; berätta för objektet vad the-map är
      (if (or (is-a? element player%)
              (is-a? element enemy%))
          (set! characters (cons element
                                 characters))
          (set! bullets (cons element
                              bullets))))
    
    (define/public (delete-element! element)
      (if (or (is-a? element player%)
              (is-a? element enemy%))
          (set! characters (filter (λ (elem)
                                     (not (eq? elem element)))
                                   characters))
          (set! bullets (filter (λ (elem)
                                  (not (eq? elem element)))
                                bullets))))
    
    (define/public (update!)
      ;; uppdatera characters
      (for-each (λ (character)
                  (send character update!))
                characters)
      ;; uppdatera bullets
      (for-each (λ (bullet)
                  (send bullet update!))
                bullets)
      
      ;; justera scrolled-distance så att spelaren är på skärmen
      (let ([canvas-width (send canvas get-width)]
            [player-x (get-field x *player*)]
            [scroll-width 280])
        (set! scrolled-distance
              (cond
                [(< player-x (+ scrolled-distance scroll-width))
                 (max 0 (- player-x scroll-width))]
                [(> player-x (+ scrolled-distance canvas-width (- scroll-width)))
                 (min (- (* tile-size width) canvas-width)
                      (+ player-x scroll-width (- canvas-width)))]
                [else scrolled-distance])))
      
      ;; ta bort bullets som kolliderar med tiles
      (set! bullets (filter (λ (bullet)
                              (not (colliding-tiles bullet)))
                            bullets))
      ;; ta bort bullets som är utanför skärmen
      ;; (hänsyn bör tas till varje bullets storlek också)
      ;; Ska det verkligen vara utanför skärmen eller bör det vara utanför banan?
      ;; Den egentliga frågan: ska man kunna skjuta fiender utanför skärmen?
      (set! bullets (filter (λ (bullet)
                              (<= scrolled-distance
                                  (get-field x bullet)
                                  (+ scrolled-distance
                                     (send *canvas* get-width))))
                            bullets)))
                                                         
    
    (define/public (render canvas dc)
      ;; först: rita bakgrund om man har en
      (send tilemap render canvas dc scrolled-distance)
      (for-each (λ (elem)
                  (send elem render canvas dc))
                characters)
      (for-each (λ (elem)
                  (send elem render canvas dc))
                bullets))
    
    ;; Ritar ut en rektangel med en viss färg och kompenserar i x-led för sidoscrollning
    (define/public (draw-rectangle x y width height color canvas dc)
      (send dc set-brush color 'solid)
      (send dc draw-rectangle (- x scrolled-distance) y width height))
    
    (super-new)))
