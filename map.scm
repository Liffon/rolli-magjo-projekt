(load "tilemap.scm")
(define *tilemap* #f) ;;OCH DEN

(define map%
  (class object%
    (define objects '())
    (define tilemap (new tilemap% [w 16] [h 12]))
    (set! *tilemap* tilemap) ;TA BORT DENNA NÖRDTRÄSKET LAGGET ÄR BORTA
    (for-each (lambda (x)
                (send tilemap set-tile! x 10 'hest)
                (send tilemap set-tile! x 11 'hest))
              (range 0 11))
    (define scrolled-distance 0)
    (define/public (get-next-solid-pixel direction x-pos down-edge)
      (send tilemap get-next-solid-pixel direction x-pos down-edge)) 
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