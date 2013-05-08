(require racket/gui)
(define *g* 0.005) ;; gravitation
(define *dt* (round (/ 1000 60))) ;; millisekunder
(load "map.scm")
(load "player.scm")
(load "enemy.scm")

;; behövs på astmatix, finns ite inbyggd i gamla versionen av Racket
(define (range x y . step?)
  (let ([step (if (null? step?)
                  1
                  (car step?))])
    (if (< x y)
        (cons x (apply range `(,(+ x step) ,y . ,step?))) ;; rekursionen borde gå att skriva snyggare
        '())))

(define *frame* (new frame%
                     [label "testbana"]
                     [width 640]
                     [height 480]))

(define controls (make-hash))
(hash-set*! controls
            #\space 'jump
            #\x 'jump
            'up 'jump
            'left 'left
            'right 'right
            #\z 'sprint
            #\c 'shoot)

(define game-canvas%
  (class canvas%
    (define/override (on-char key-event)
      (let* ([key-code (send key-event get-key-code)]
             [pressed? (not (eq? key-code 'release))]
             [key (if pressed?
                      key-code
                      (send key-event get-key-release-code))]
             [action (hash-ref controls key)])
        (when action
          (send *player* set-key! action pressed?))))
    (super-new)))

(define *canvas* (new game-canvas%
                      [parent *frame*]
                      [paint-callback (λ (canvas dc)
                                        (send *map* render canvas dc))]))

(define *timer* (new timer%
                     [notify-callback (λ ()
                                        (send *map* update!)
                                        (send *canvas* refresh))]))

(send *timer* start *dt*)

(define *player* (new player%))
(define *edgar* (new enemy% [x 300] [direction 'right]))
(define *map* (new map% [width 16] [height 12] [tile-size 40]))
(send *map* add-element! *player*)
(send *map* add-element! *edgar*)
(send *frame* show #t)
;(define *enemy* (new enemy%))
;(send *map* add-object! *enemy*)
