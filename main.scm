(require racket/gui)
(define *g* 0.005) ;; gravitation
(define *dt* (round (/ 1000 60))) ;; millisekunder
(load "map.scm")
(load "player.scm")
(load "enemy.scm")
(load "weapon.scm")

;; behövs på astmatix, finns inte inbyggd i gamla versionen av Racket
(define (range x y . maybe-step)
  (let ([step (if (null? maybe-step) 1 (car maybe-step))])
    (if (< x y)
        (cons x (apply range `(,(+ x step) ,y . ,maybe-step))) ;; rekursionen borde gå att skriva snyggare
        '())))

(define *frame* (new frame%
                     [label "testbana"]
                     [min-width 640]
                     [min-height 480]
                     [stretchable-width #f]
                     [stretchable-height #f]))

(define *controls* (make-hash))
(hash-set*! *controls*
            #\space 'jump
            #\x 'jump
            'up 'jump
            'left 'left
            'right 'right
            #\z 'sprint
            #\c 'shoot
            #\s 'prev-weapon
            #\d 'next-weapon)

(define game-canvas%
  (class canvas%
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
(define *map* (new map% [width 32] [height 12] [tile-size 40]))
(send *map* add-element! *player*)
(send *map* add-element! *edgar*)
(set-field! canvas *map* *canvas*)
(send *frame* show #t)
(send *player* take-weapon! (make-machine-gun 23 23))
(send *player* take-weapon! (make-pistol 42 32))
(send *player* take-weapon! (new weapon% ;; improviserat köttvapen
                                 [x 0]
                                 [y 0]
                                 [width 16]
                                 [height 16]
                                 [cooldown 1500]
                                 [bullet (new bullet% [width 16] [height 16] [damage 200] [speed 0.3])]))
