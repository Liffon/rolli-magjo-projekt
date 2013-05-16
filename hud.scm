(define hud%
  (class object%
    (init-field
     player)
    (define game-over-bitmap (read-bitmap "sprites/game-over2.png"))
    (define empty-heart-bitmap (read-bitmap "sprites/empty-heart.png"))
    (define heart-bitmap (read-bitmap "sprites/heart.png"))
    
    (define (hit-points life dc)
      (for-each (λ (x)
                  (send dc draw-bitmap empty-heart-bitmap x 10))
                (range 10 (+ (* 10 10) 10) 20))
      (for-each (λ (hit-point)
                  (send dc draw-bitmap heart-bitmap hit-point 10))
                (range 10 (+ (* life 10) 10) 20)))
    
    ;; Ritar ut vapnets bild (om den finns) och namn
    (define (draw-weapon canvas dc)
      (let ([weapon (get-field weapon player)])
        (when weapon
          (let* ([bitmap (get-field bitmap weapon)]
                 [name (get-field name weapon)]
                 [width (if bitmap
                            (+ (get-field width weapon) 10)
                            0)])
            (when bitmap
              (send dc draw-bitmap bitmap 10 30))
            (send dc set-text-foreground "black")
            (send dc draw-text name (+ 10 width) 30 #t)))))
    
    (define (draw-editing canvas dc)
      (when *editing*
        (send dc set-text-foreground "red")
        (send dc draw-text "EDITING" (- (send canvas get-width) 80) 10)))
    
    (define (game-over dc)
      (when (zero? (get-field hp player))
        (send dc draw-bitmap game-over-bitmap 0 0)))
      
    (define/public (render canvas dc)
      (game-over dc)
      (hit-points (/ (get-field hp player) 10) dc)
      (draw-weapon canvas dc)
      (draw-editing canvas dc))
    (super-new)))
               