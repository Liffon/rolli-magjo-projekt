(load "ring.scm")

(define character%
  (class object%
    (init-field [x 0]
                [y 0]
                [width 25]
                [height 50]
                [hp 100]
                [the-map #f]
                [direction 'right])
    (field [inventory (make-ring)]
           [weapon #f])
    (define vx 0)
    (define vy 0)
    (define maxspeed 0.05)
    
    (define/public (add-item! item)
      (ring-insert! inventory item)
      (set-field! wielder item this))
    
;    implementeras i ring.scm om det visar sig behövas
;    (define/public (remove-item! removee)
;      (ring-delete! inventory removee)
;      (set-field! wielder removee the-map))
    
    (define/public (take-weapon! new-weapon)
      (set! weapon new-weapon)
      (add-item! new-weapon))

    (define/public (switch-weapon! next/prev)
      (unless (empty-ring? inventory)
        (displayln "Not empty")
        (if (eq? next/prev 'next)
            (ring-rotate-right! inventory)
            (ring-rotate-left! inventory))
        (set! weapon (ring-first-value inventory)))
      (displayln "Switch!"))
    
    (define/public (shoot!)
      (when weapon
        (send weapon fire! the-map direction)))
    
    (define/public (remove-self!)
      (when the-map
        (send the-map delete-element! this)
        (set! the-map #f)
        (displayln "Removed a character.")))

    (define/public (swap-direction direction)
      (case direction
        ('left 'right)
        ('right 'left)))
    
    (define/public (on-ground?)
      (eq? (inexact->exact y) (ground-y)))
    
    (define/public (find-obstacle direction)
      (let-values
          ([(lower-val upper-val iterator)
            (case direction
              [(up down) ;; kolla flera olika x
               (values x
                       (+ x width -1)
                       (lambda (x)
                         (send the-map get-next-tile-pixel #t direction x y)))]
              [(left right) ;; kolla flera olika y
               (values y
                       (+ y height -1)
                       (lambda (y)
                         (send the-map get-next-tile-pixel #t direction x y)))])])
        (let* ([tile-size (get-field tile-size the-map)]
               [checklist (cons upper-val (range lower-val upper-val tile-size))])
          (apply (if (or (eq? direction 'up)
                         (eq? direction 'left))
                     max
                     min)
                 (map iterator checklist)))))
    
    (define/public (roof-y)
      (add1 (find-obstacle 'up)))
    (define/public (left-x)
      (find-obstacle 'left))
    (define/public (right-x)
      (- (find-obstacle 'right) width))
    (define/public (ground-y)
      (- (find-obstacle 'down) height))
    
    (define/public (decelerate!)
      (set! vx (* vx 0.85)))
    
    (define/public (gravitate!)
      (push! 0 (* *g* *dt*)))
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    (define/public (jump!)
      (set! vy -0.9))
    
    (define/public (render canvas dc)
      (send the-map draw-rectangle x y width height "white" canvas dc))
    
    (define/public (move!)
      (when (is-a? the-map map%)
        (unless (on-ground?)
          (gravitate!)) ;; tyngdacceleration
        
        (decelerate!) ;; bromsa i x-led
        
        (let ([new-x (+ x (* vx *dt*))]
              [new-y (+ y (* vy *dt*))]
              [min-x (left-x)] ;; största och minsta tillåtna värden på koordinaterna
              [max-x (right-x)]
              [min-y (roof-y)]
              [max-y (ground-y)])
          
          (cond
            [(positive? vx) (set! x (min new-x max-x))]
            [(negative? vx) (set! x (max new-x min-x))])
          (cond
            [(positive? vy) (set! y (min new-y max-y))]
            [(negative? vy) (set! y (max new-y min-y))])
          
          (when (or (= x min-x)
                    (= x max-x))
            (set! vx 0))
          (when (or (= y min-y)
                    (= y max-y))
            (set! vy 0)))))

    (define/public (die!)
      (displayln "Blargh!")
      (remove-self!)) ;; detta kanske inte bör göras omedelbart
    
    (define/public (hurt! damage)
      (set! hp (- hp damage))
      (when (not (positive? hp))
        (die!)))
    
    (define/public (update!)
      (when the-map
        (move!)))
    
    (super-new)))
