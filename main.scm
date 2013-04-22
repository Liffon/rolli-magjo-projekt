(require racket/gui)
(require racket/bool)
(define *g* 0.005) ;; gravitation
(define *dt* (round (/ 1000 60))) ;; millisekunder
(load "player.scm")
(load "character.scm")

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
          ('release
           (case (send key-event get-key-release-code)
             ((#\space up)
              (send *player* set-key! 'jump #f))
             ((#\a left)
              (send *player* set-key! 'left #f))
             ((#\d right)
              (send *player* set-key! 'right #f))
             ((#\x)
              (send *player* set-key! 'sprint #f)))))))
    (super-new)))

(define *canvas* (new game-canvas%
                      [parent *frame*]
                      [paint-callback (lambda (canvas dc)
                                        (send *player* render canvas dc)
                                        (send *enemy* render canvas dc))]))

(define *timer* (new timer%
                     [notify-callback (lambda ()
                                        (send *player* update)
                                        (send *enemy* update)
                                        (send *canvas* refresh))]))

(send *timer* start *dt*)

(define *player* (new player%))
(send *frame* show #t)
(define *enemy* (new character%))
                     
