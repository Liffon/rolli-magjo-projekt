(require racket/gui)
(require racket/bool)
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

(define game-canvas%
  (class canvas%
    (define/override (on-char key-event)
      (let ((key-code (send key-event get-key-code)))
        (case key-code
          ((#\space up)
           (send *player* set-key! 'jump #t))
          ((#\a left)
           (send *player* set-key! 'left #t))
          ((#\d right)
           (send *player* set-key! 'right #t))
          ((#\x)
           (send *player* set-key! 'sprint #t))
          ((#\c)
              (send *player* set-key! 'shoot #t))
          ('release
           (case (send key-event get-key-release-code)
             ((#\space up)
              (send *player* set-key! 'jump #f))
             ((#\a left)
              (send *player* set-key! 'left #f))
             ((#\d right)
              (send *player* set-key! 'right #f))
             ((#\x)
              (send *player* set-key! 'sprint #f))
             ((#\c)
              (send *player* set-key! 'shoot #f)))))))
    (super-new)))

(define *canvas* (new game-canvas%
                      [parent *frame*]
                      [paint-callback (lambda (canvas dc)
                                        (send *map* render canvas dc))]))

(define *timer* (new timer%
                     [notify-callback (lambda ()
                                        (send *map* update!)
                                        (send *canvas* refresh))]))

(send *timer* start *dt*)

(define *player* (new player%))
(define *map* (new map% [width 16] [height 12] [tile-size 40]))
(send *map* add-element! *player*)
(send *map* add-element! *player*)
(send *map* add-element! (new enemy% [x 300] [direction 'right]))
(send *frame* show #t)
;(define *enemy* (new enemy%))
;(send *map* add-object! *enemy*)
