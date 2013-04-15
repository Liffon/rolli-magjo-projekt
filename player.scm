(define player%
  (class object%
    (init [x 0]
          [y 0])
    (define x-pos x)
    (define y-pos y)
    (define vx 0)
    (define vy 0)
    (define ax 0)
    (define ay 0)
    
    (define/public (set-a! new-ax new-ay)
      (set! ax new-ax)
      (set! ay new-ay))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x-pos y-pos 50 50))
    (define/public (update)
     
      (if (> y-pos 250)
          (set! vy 0)
          (begin  (set! ay (+ ay (* *g* *dt*))) ;; gravitation
                  (set! vy (+ vy (* ay *dt*)))))
          
      (set! vx (+ vx (* ax *dt*)))
      (set! x-pos (+ x-pos (* vx *dt*)))
      (set! y-pos (+ y-pos (* vy *dt*))))
    ;;to-do: gravitation
    (super-new)))



      
