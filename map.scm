(load "tilemap.scm")
(define *tilemap* #f) ;; för debugging - ta bort sen!

(define map%
  (class object%
    (init-field width height tile-size)
    
    (define characters '())
    (define bullets '())
    (define tilemap (new tilemap% [width width] [height height] [tile-size tile-size]))
    (set! *tilemap* tilemap) ;; för debugging - ta bort sen!
    (define scrolled-distance 0)

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

    (define/public (get-next-solid-pixel . args) ;; skicka vidare alla argument
      (send tilemap get-next-solid-pixel . args)) ; till tilemap
    
    (define/public (get-position-tile . args)
      (send tilemap get-position-tile . args))
    
    (define/public (add-element! element)
      (send element set-map! this)
      (if (or (is-a? player% element)
              (is-a? bullet% element))
          (set! characters (cons element
                                 characters))
          (set! bullets (cons element
                              bullets))))
    
    
    
    (define/public (delete-element! element)
      (if (or (is-a? player% element)
              (is-a? bullet% element))
      (set! objects (filter (λ (elem)
                              (not (eq? elem element)))
                            objects))
      (set! bullets (filter (λ (elem)
                              (not (eq? elem element)))
                            bullets))))
    
    (define/public (update!)
      (for-each (λ (elem)
                 (send elem update!))
               characters)
      (for-each (λ (elem)
                 (send elem update!))
               bullets))
    
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