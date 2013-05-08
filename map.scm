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
           [bullets '()])
    
    ;; initialisera en testbana
    (for-each (λ (x)
                (send tilemap set-tile! x 11 #t))
              (range 0 16))
    (send tilemap set-tile! 5 11 #f)
    (for-each (λ (x)
                (send tilemap set-tile! x 7 #t))
              (range 6 13))
    (send tilemap set-tile! 13 8 #t)
    (send tilemap set-tile! 15 9 #t)
    (send tilemap set-tile! 15 10 #t)
    
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
    
    ;; dessa två procedurer kanske bör generaliseras
    (define/public (colliding-bullets obj)
      (filter (λ (bullet)
                (and (not (eq? bullet obj)) ;; krockar inte med sig själv
                     (colliding? bullet obj)))
              bullets))
    
    (define/public (colliding-characters obj)
      (filter (λ (character)
                (and (not (eq? obj character)) ;; krockar inte med sig själv
                     (colliding? character obj)))
              characters))
    
        
    (define/public (colliding-tiles obj)
      (or (get-position-tile (get-field x obj)
                             (get-field y obj))
          (get-position-tile (sub1 (+ (get-field x obj)
                                      (get-field width obj)))
                              (get-field y obj))
          (get-position-tile (get-field x obj)
                             (sub1 (+ (get-field y obj)
                                      (get-field height obj))))
          (get-position-tile (sub1 (+ (get-field x obj)
                                      (get-field width obj)))
                               (sub1 (+ (get-field y obj)
                                      (get-field height obj))))))
        
             
             
             
    (define/public (get-next-solid-pixel . args) ;; skicka vidare alla argument
      (send tilemap get-next-solid-pixel . args)) ; till tilemap
    
    (define/public (get-position-tile . args)
      (send tilemap get-position-tile . args))
    
    (define/public (add-element! element)
      (set-field! the-map element this) ;; berätta vad the-map är för objektet
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
      (for-each (λ (elem)
                  (send elem update!))
                characters)
      (for-each (λ (elem)
                  (send elem update!))
                bullets)
      (set! bullets (filter (λ (bullet)
                              (not (colliding-tiles bullet)))
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
    (super-new)))
