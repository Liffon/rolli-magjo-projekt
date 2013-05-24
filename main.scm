;; main.scm
;; ========

;; För att starta spelet, kör den här filen.

(require racket/gui)
(load "map.scm")
(load "player.scm")
(load "enemy.scm")
(load "weapon.scm")
(load "hud.scm")

(define *g* 0.004) ;; gravitation
(define *dt* (round (/ 1000 60))) ;; uppdateringen ska ske 60 gånger per sekund
(define *level-filename* "level.sexpr")

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

(define *editing?* #f)
(define *current-tile* 'ground)

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
          (send *player* set-key! action pressed?))
        (when (send key-event get-control-down)
          (case (send key-event get-key-code)
            ['#\e (set! *editing?* (not *editing?*))]
            ['#\s (displayln (string-append "Saving level to " *level-filename* "..."))
                  (send *map* dump-tiles-to-file *level-filename*)]))))
    (define/override (on-event event)
      (when *editing?* ;; bara för leveleditorn
        (cond
          [(or (send event button-down? 'left) ;; vänsterklick sätter ut en tile
               (and (send event dragging?) ;; men också att klicka och dra för att sätta ut flera i taget
                    (send event get-left-down)))
           (let ([x (send event get-x)]
                 [y (send event get-y)])
             (when (send *map* valid-tile-coord-at-screen? x y)
               (send *map* set-tile-at-screen! x y *current-tile*)))]
          [(send event button-down? 'right) ;; högerklick kopierar en tile
           (let ([x (send event get-x)]
                 [y (send event get-y)])
             (when (send *map* valid-tile-coord-at-screen? x y)
               (set! *current-tile* (send *map* get-screen-position-tile x y))))])))
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

(define *player* (new player%
                      [x 20] [y 400]
                      [hp 100] [direction 'right]))

;; skapa en bana med storlek 32x12 tiles och varje tile är 40x40 pixlar
(define *map* (new map%
                   [width 64] [height 12]
                   [tile-size 40]
                   [canvas *canvas*]
                   [tiles *level-filename*]))

(define *hud* (new hud% [player *player*]))

;; lägg in spelaren och fiender i banan
(send *map* add-element! *player*)
(send *map* add-element! (new enemy%
                              [x 1069] [y 280]
                              [direction 'right]))
(send *map* add-element! (new enemy%
                              [x 1550] [y 200]
                              [direction 'left]))
(send *map* add-element! (make-pistol 760 300))
(send *map* add-element! (make-machine-gun 892 47))

;; visa spelfönstret
(send *frame* show #t)
