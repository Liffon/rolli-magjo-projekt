;; weapon.scm
;; ==========

;; innehåller klassen weapon%
;;   och procedurerna (make-pistol) och (make-machine-gun)
;;   som skapar vapen

(load "bullet.scm")

(define weapon%
  (class object%
    (init-field width
                height
                cooldown
                bullet
                [name "Weapon"]
                [bitmap #f]
                [x 0]
                [y 0]
                [wielder #f])
    
    ;; returnerar en bullet med angivna the-map, x, y och direction
    ;;   och samma width, height, damage och speed som "standard-bulleten" för vapnet
    (define (make-bullet the-map x y direction)
      (new bullet%
           [x x] [y y] [direction direction]
           [width (get-field width bullet)]
           [height (get-field height bullet)]
           [damage (get-field damage bullet)]
           [speed (get-field speed bullet)]
           [the-map the-map]))
    
    ;; ritar ut vapnet på skärmen om det har en bitmap specifierad och befinner sig i en map
    (define/public (render canvas dc)
      (when (is-a? wielder map%)
        (if bitmap
            (send wielder draw-bitmap bitmap x y canvas dc)
            (send wielder draw-rectangle x y width height "red" canvas dc))))
    
    ;; avlossar ett skott om vapnet befinner sig hos en spelare
    (define/public (fire! the-map direction)
      (when (is-a? wielder player%)
        (let ([x (get-field x wielder)]
              [y (get-field y wielder)])
          (send the-map add-element! (make-bullet the-map
                                                  (if (eq? direction 'left)
                                                      x
                                                      (+ x (get-field width wielder)))
                                                  (+ y (/ (get-field height wielder) 3)) direction)))))
    
    (super-new)))

;; returnerar en pistol på de angivna koordinaterna eller (0,0)
(define (make-pistol [x 0] [y 0]) (new weapon%
                               [width 33]
                               [height 20]
                               [x x]
                               [y y]
                               [name "Pistol"]
                               [bitmap (read-bitmap "sprites/pistol.png")]
                               [cooldown 250]
                               [bullet (new bullet% [width 7] [height 3] [damage 20])]))

;; returnerar ett automatvapen på de angivna koordinaterna eller (0,0)
(define (make-machine-gun [x 0] [y 0]) (new weapon%
                               [width 12]
                               [height 8]
                               [x x]
                               [y y]
                               [name "Machine gun"]
                               [cooldown 100]
                               [bullet (new bullet% [width 5] [height 2] [damage 10])]))
