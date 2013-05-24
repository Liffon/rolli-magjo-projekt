;; bullet.scm
;; ==========

;; innehåller klassen bullet%
;; Init-argument: width, height, damage, x, y, direction, speed, the-map
;; (width, height och damage obligatoriska)

;; Användningsexempel:
; (new bullet% [width 4] [height 2] [damage 20] [x 40] [y 80] [direction 'right] [the-map a-map])

(define bullet%
  (class object%
    (init-field width
                height
                damage
                [x 0]
                [y 0]
                [direction 'right] ;; vänster eller höger
                [speed 1]
                [the-map #f]) ;; pekare till banan
    
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
