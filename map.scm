(load "tilemap.scm")
(define *tilemap* #f) ;; för debugging - ta bort sen!

(define map%
  (class object%
    (init-field width height tile-size)
    
    (define objects '())
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
    
    (define/public (add-object! object)
      (send object set-map! this)
      (set! objects (cons object objects)))
    
    (define/public (delete-object! object)
      (set! objects (filter (λ (obj)
                              (not (eq? obj object)))
                            objects)))
    
    (define/public (update!)
      (for-each (λ (obj)
                 (send obj update!))
               objects))
    
    (define/public (render canvas dc)
      ;; först: rita bakgrund om man har en
      (send tilemap render canvas dc scrolled-distance)
      (for-each (λ (obj)
                  (send obj render canvas dc))
               objects))
    (super-new)))