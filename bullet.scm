(define bullet%
  (class object%
    (init-field width
                height
                damage
                [x #f]
                [y #f]
                [direction #f]
                [speed 1]
                [the-map #f])
    
    ;;tar bort kulan från banan
    
    (define/public (remove-self!)
      (when the-map
        (send the-map delete-element! this)
        (set! the-map #f)))
    
    ;; tar in canvas och dc som argument och ritar kulan på banan
    (define/public (render canvas dc)
      (send the-map draw-rectangle x y width height "black" canvas dc))
    
    ;;flyttar kulan 
    (define/public (move!)
      (set! x ((if (eq? direction 'left) - +) ;; flytta åt rätt håll beroende på riktning
               x
               (* speed *dt*))))
    (define/public (update!)
      (move!))
    (super-new)))
