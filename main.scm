;; main.scm
;; ========

(require racket/gui)
(define *g* 0.005) ;; gravitation
(define *dt* (round (/ 1000 60))) ;; uppdateringen ska ske 60 gånger per sekund
(load "map.scm")
(load "player.scm")
(load "enemy.scm")
(load "weapon.scm")
(load "hud.scm")

;; behövs på astmatix, finns inte inbyggd i gamla versionen av Racket
(define (range x y . maybe-step)
  (let ([step (if (null? maybe-step) 1 (car maybe-step))])
    (if (< x y)
        (cons x (apply range `(,(+ x step) ,y . ,maybe-step))) ;; rekursionen borde gå att skriva snyggare
        '())))

;; skapa själva spel-framen
(define *frame* (new frame%
                     [label "testbana"]
                     [min-width 640]
                     [min-height 480]
                     [stretchable-width #f] ;; framen ska inte kunna ändra storlek
                     [stretchable-height #f]))


;; alla kontroller i spelet
(define *controls* (make-hash))
(hash-set*! *controls*
            'left 'left
            'right 'right
            #\space 'jump
            #\x 'jump
            'up 'jump
            #\z 'sprint
            #\c 'shoot
            #\s 'prev-weapon
            #\d 'next-weapon)

;; en ny canvas som kan hantera tangenttryckningar
(define game-canvas%
  (class canvas%
    ;; När en tangent trycks ned eller släpps upp körs denna procedur
    ;;   som uppdaterar spelarens lista på vilka tangenter som är nedtryckta
    (define/override (on-char key-event)
      (let* ([key-code (send key-event get-key-code)]
             [pressed? (not (eq? key-code 'release))] ; var det nedtryckning eller släpp?
             [key (if pressed?
                      key-code
                      (send key-event get-key-release-code))]
             [action (hash-ref *controls* key #f)])
        (when action
          (send *player* set-key! action pressed?))))
    (super-new)))

;; skapa canvasen
(define *canvas* (new game-canvas%
                      [parent *frame*] ;; lägg den i *frame*
                      [paint-callback (λ (canvas dc) ;; varje gång något ska ritas ut,
                                        (send *map* render canvas dc) ; rita först banan och allt i den
                                        (send *hud* render canvas dc))])) ; och sen HUD

;; skapa timern som sköter uppdateringen av spellogiken
(define *timer* (new timer%
                     [notify-callback (λ ()
                                        (send *map* update!)
                                        (send *canvas* refresh))]))

;; starta timern
(send *timer* start *dt*)

(define *player* (new player% [width 40] [height 80] [hp 100]))
(define *edgar* (new enemy% [x 300] [direction 'right]))

;; skapa en bana med storlek 32x12 tiles och varje tile är 40x40 pixlar
(define *map* (new map% [width 32] [height 12] [tile-size 40] [canvas *canvas*]))

(define *hud* (new hud% [player *player*]))

;; lägg in spelaren och fienden i banan
(send *map* add-element! *player*)
(send *map* add-element! *edgar*)

(send *frame* show #t)
(send *player* take-weapon! (make-machine-gun))
(send *player* take-weapon! (make-pistol))
(send *player* take-weapon! (new weapon% ;; improviserat köttvapen
                                 [width 16]
                                 [height 16]
                                 [name "The Great Big Kötter"]
                                 [cooldown 1500]
                                 [bullet (new bullet% [width 16] [height 16] [damage 200] [speed 0.3])]))
