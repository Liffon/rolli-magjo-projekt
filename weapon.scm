;; weapon.scm
;; ==========

;; innehåller klassen weapon%
;;   och procedurerna (make-pistol) och (make-machine-gun)
;;   som skapar vapen

;; Init-argument: width, height, cooldown, bullet, name, bitmap, x, y, wielder
;; (width, height, cooldown och bullet är obligatoriska)

;; Användningsexempel:
; (new weapon [width 300] [height 200] [cooldown 500] [bullet a-bullet] [name "Ofantligt stort vapen"])
; där a-bullet är en instans av bullet%

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
                [wielder #f]) ;; vem som håller i vapnet (en character% eller en map%)
    
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
        (let* ([wielder-x (get-field x wielder)]
               [wielder-y (get-field y wielder)]
               [wielder-width (get-field width wielder)]
               [wielder-height (get-field height wielder)]
               [x (if (eq? direction 'left)
                      wielder-x
                      (+ wielder-x wielder-width))]
               [y (+ wielder-y (/ wielder-height 3))])
          (send the-map add-element! (make-bullet the-map x y direction)))))
    
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
                               [width 73]
                               [height 27]
                               [x x]
                               [y y]
                               [name "Machine gun"]
                               [bitmap (read-bitmap "sprites/machine-gun.png")]
                               [cooldown 100]
                               [bullet (new bullet% [width 5] [height 2] [damage 10])]))
