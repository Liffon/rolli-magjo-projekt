(require racket/gui)
(define *g* 0.001) ;; gravitation
(define *dt* (round (/ 1000 60))) ;; millisekunder
(load "player.scm")

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
           (send *player* jump!))
          ((#\a left)
           (send *player* move-left!))
          ((#\d right)
           (send *player* move-right!)))))
    (super-new)))

(define *canvas* (new game-canvas%
                      [parent *frame*]
                      [paint-callback (lambda (canvas dc)
                                        (send *player* render canvas dc))]))

(define *timer* (new timer%
                     [notify-callback (lambda ()
                                        (send *player* update)
                                        (send *canvas* refresh))]))

(send *timer* start *dt*)

(define *player* (new player%))
(send *frame* show #t)
                     
