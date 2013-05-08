(define pistol%
  (class weapon%
    (inherit-field width
                   height
                   cooldown
                   bullet)
    (super-new)
    (set! width 7)
    (set! height 5)
    (set! cooldown 250)
    (set! bullet (new bullet%
                      [width 7]
                      [height 3]
                      [damage 20]))))