;; hud.scm
;; =======

;; innehåller klassen hud%

;; Init-argument: player

;; Användningsexempel:
;; (new hud% [player *player*])

(define hud%
  (class object%
    (init-field
     player)
    ;; bilder från png-filer
    (define game-over-bitmap (read-bitmap "sprites/game-over2.png"))
    (define empty-heart-bitmap (read-bitmap "sprites/empty-heart.png"))
    (define heart-bitmap (read-bitmap "sprites/heart.png"))
    (define the-end-bitmap (read-bitmap "sprites/the-end.png"))
    
    ;; rita ut vinst-meddelandet som visar att spelaren har vunnit
    (define (end-screen dc)
      (send dc draw-bitmap the-end-bitmap 0 0))
    
    ;; ritar ut hjärtan för att visa spelarens HP
    (define (hit-points life dc)
      ;; gråa, "tomma" hjärtan i bakgrunden
      (for-each (λ (x)
                  (send dc draw-bitmap empty-heart-bitmap x 10))
                (range 10 (+ (* 10 10) 10) 20))
      ;; fyll i rätt antal för spelarens HP
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
    
    ;; skriver ut EDITING i övre högra hörnet av skärmen om man är inne i leveleditorn
    (define (draw-editing canvas dc)
      (when *editing?*
        (send dc set-text-foreground "red")
        (send dc draw-text "EDITING" (- (send canvas get-width) 80) 10)))
    
    ;; ritar ut meddelandet GAME OVER på skärmen om spelarens HP == 0
    (define (game-over dc)
      (when (zero? (get-field hp player))
        (send dc draw-bitmap game-over-bitmap 0 0)))
      
    
    ;; ritar ut HUD:en
    (define/public (render canvas dc)
      (if (get-field has-won? player)
          (end-screen dc)
          (begin (game-over dc)
                 (hit-points (/ (get-field hp player) 10) dc)
                 (draw-weapon canvas dc)
                 (draw-editing canvas dc))))
    (super-new)))
