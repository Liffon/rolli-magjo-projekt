(define player%
  (class object%
    (init [x 0]
          [y 0])
    (define x-pos x)
    (define y-pos y)
    (define vx 0)
    (define vy 0)
    (define maxspeed 0.05)
    (define on-ground? #f)
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    (define/public (move-right!)
      (push! 0.2 0))
    
    (define/public (move-left!)
      (push! -0.2 0))
    
    (define/public (jump!)
      (when on-ground?
        (set! on-ground? #f)
        (push! 0 -0.4)))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x-pos y-pos 50 50))
    (define/public (update)
     
      (cond
        (holding-right?
         ;;knuff åt höger
         void)
        (holding-left?
         ;;knuff åt vänster
         void)
        (else
         ;;bromsa
         void))
      (when holding-jump?
        ;;knuff uppåt
        ;;todo: kolla att man får hoppa
        void)
      
;      (if (and (> y-pos 250)
;               (not on-ground?))
;          (begin (set! vy 0)
;                 (set! y-pos 250)
;                 (set! on-ground? #t))
;          (set! vy (+ vy (* *g* *dt*))))
;          
;      (set! x-pos (+ x-pos (* vx *dt*)))
;      (unless on-ground?
;        (set! y-pos (+ y-pos (* vy *dt*)))))
        )
    ;;to-do: gravitation
    (super-new)))



      
