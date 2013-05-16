(define hud%
  (class object%
    (init-field
     player)
    (define game-over-bitmap (read-bitmap "sprites/game-over2.png"))
    (define empty-heart-bitmap (read-bitmap "sprites/empty-heart.png"))
    (define heart-bitmap (read-bitmap "sprites/heart.png"))
    
    (define/public (hit-points life dc)
      (for-each (λ (x)
;<<<<<<< HEAD
;                  (send dc set-brush "white" 'solid)
;                  (send dc draw-rectangle x 10 5 15))
;                (range 10 (+ (* 10 10) 10) 7))
;      (for-each (λ (hit-point)
;                  (send dc set-brush "black" 'solid)
;                  (send dc draw-rectangle hit-point 10 5 15))
;                (range 10 (+ (* life 10) 10) 7)))
;=======
                  ;(send dc set-brush "white" 'solid)
                  ;(send dc draw-ellipse x 10 10 10)
                  (send dc draw-bitmap empty-heart-bitmap x 10))
                (range 10 (+ (* 10 10) 10) 20))
      (for-each (λ (hit-point)
                  ;(send dc set-brush "red" 'solid)
                  ;(send dc draw-ellipse hit-point 10 10 10)
                  (send dc draw-bitmap heart-bitmap hit-point 10))
                (range 10 (+ (* life 10) 10) 20)))
    
    ;; Ritar ut vapnets bild (om den finns) och namn
    (define/public (draw-weapon canvas dc)
      (let ([weapon (get-field weapon player)])
        (when weapon
          (let* ([bitmap (get-field bitmap weapon)]
                 [name (get-field name weapon)]
                 [width (if bitmap
                            (+ (get-field width weapon) 10)
                            0)])
            (when bitmap
              (send dc draw-bitmap bitmap 10 30))
            (send dc draw-text name (+ 10 width) 30 #t)))))
    
    (define/public (game-over dc)
      (when (zero? (get-field hp player))
        (send dc draw-bitmap game-over-bitmap 0 0)))
      
    (define/public (render canvas dc)
      (game-over dc)
      (hit-points (/ (get-field hp player) 10) dc)
      (draw-weapon canvas dc))
    (super-new)))
               