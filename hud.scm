(define hud%
  (class object%
    (init-field
     player)
    (define game-over-bitmap (read-bitmap "sprites/game-over2.png"))
    
    (define/public (hit-points life dc)
      (for-each (λ (hit-point)
                  (send dc draw-ellipse hit-point 10 10 10))
                (range 10 (+ (* life 10) 10) 20)))
    
    (define/public (game-over dc)
      (when (zero? (get-field hp player))
        (send dc draw-bitmap game-over-bitmap 0 0)))
      
    (define/public (render canvas dc)
      (game-over dc)
      (send dc set-brush "red" 'solid)
      (hit-points (/ (get-field hp player) 10) dc))
    (super-new)))
               