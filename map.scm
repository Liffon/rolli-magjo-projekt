(load "tilemap.scm")
(define *tilemap* #f) ;;OCH DEN

(define map%
  (class object%
    (define objects '())
    (define tilemap (new tilemap% [w 32] [h 24]))
    (set! *tilemap* tilemap) ;TA BORT DENNA NÖRDTRÄSKET LAGGET ÄR BORTA
    (define scrolled-distance 0)

    (define/public (add-object! object)
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