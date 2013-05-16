(load "ring.scm")

(define character% ;; En karaktärsklass som både spelaren och fienderna bygger på. 
  (class object%
    (init-field [x 0] ;; x-position
                [y 0] ;; y-position
                [width 40]
                [height 80]
                [hp 100] ;; Liv
                [the-map #f]
                [direction 'right])
    (field [inventory (make-ring)]
           [weapon #f]
           [vx 0]
           [vy 0])
    (define maxspeed 0.05)
    
    (define/public (add-item! item) ;; Tar ett föremål som argument och lägger in det i karaktärens inventarium
      (ring-insert! inventory item) ;; samt gör så att föremålet vet vem/vad som bär det. 
      (set-field! wielder item this))
    
;    implementeras i ring.scm om det visar sig behövas
;    (define/public (remove-item! removee)
;      (ring-delete! inventory removee)
;      (set-field! wielder removee the-map))
    
    (define/public (take-weapon! new-weapon) ;; Tar ett vapen som argument, gör det till aktuellt vapen (som karaktären 
      (set! weapon new-weapon)               ;; använder) och lägger in vapnet i inventariet. 
      (add-item! new-weapon))

    (define/public (switch-weapon! next/prev) ;; Tar in 'next eller 'prev, roterar inventariet (som är en ring)
      (unless (empty-ring? inventory)         ;; i en viss riktning och sätter det första värdet i ringen till aktuellt vapen. 
        (displayln "Not empty")
        (if (eq? next/prev 'next)
            (ring-rotate-right! inventory)
            (ring-rotate-left! inventory))
        (set! weapon (ring-first-value inventory)))
      (displayln "Switch!"))
    
    (define/public (shoot!) ;; Om karaktären har ett vapen så sänder den proceduren fire! till vapnet som gör att vapnet avfyras
      (when weapon          ;; i rätt riktning. 
        (send weapon fire! the-map direction)))
    
    (define/public (remove-self!) ;; Tar bort karaktären ur banans lista över element. 
      (when the-map
        (send the-map delete-element! this)
        (set! the-map #f)
        (displayln "Removed a character.")))

    (define/public (swap-direction direction) ;; Tar in riktningen höger eller vänster som argument och byter från
      (case direction                         ;; vänster till höger eller höger till vänster. 
        ('left 'right)
        ('right 'left)))
    
    (define/public (on-ground?) ;; Kollar om karaktären står på marken och returnerar #t eller #f. 
      (eq? (inexact->exact y) (ground-y)))
    
    (define/public (find-obstacle solid? direction) ;; Tar in ett booleskt värde (som anger om man letar en solid eller
      (let-values                                   ;; tom tile) och en riktning som argument och returnerar närmaste tiles
          ([(lower-val upper-val iterator)          ;; pixelkoordinat (antingen i x- eller yled beroende på riktning).  
            (case direction
              [(up down) ;; kolla flera olika x
               (values x
                       (+ x width -1)
                       (lambda (x)
                         (send the-map get-next-tile-pixel solid? direction x y)))]
              [(left right) ;; kolla flera olika y
               (values y
                       (+ y height -1)
                       (lambda (y)
                         (send the-map get-next-tile-pixel solid? direction x y)))])])
        (let* ([tile-size (get-field tile-size the-map)]
               [checklist (cons upper-val (range lower-val upper-val tile-size))])
          (apply (if (or (eq? direction 'up)
                         (eq? direction 'left))
                     max
                     min)
                 (map iterator checklist)))))
    
    (define/public (roof-y) ;; Returnerar närmsta solida pixel-koordinat ovan karaktären. 
      (add1 (find-obstacle #t 'up)))
    (define/public (left-x) ;; Returnerar närmsta solida pixel-koordinat vänster om karaktären. 
      (find-obstacle #t 'left))
    (define/public (right-x) ;; Returnerar närmsta solida pixel-koordinat höger om karaktären. 
      (- (find-obstacle #t 'right) width))
    (define/public (ground-y) ;; Returnerar närmsta solida pixel-koordinat under karaktären. 
      (- (find-obstacle #t 'down) height))
    
    (define/public (decelerate!) ;; Minskar karaktärens hastighet i x-led. 
      (set! vx (* vx 0.85)))
    
    (define/public (gravitate!) ;; Ökar karaktärens hastighet i y-led. 
      (push! 0 (* *g* *dt*)))
    
    (define/public (push! dvx dvy) ;; Tar in ändring av hastighet i både x- och yled och ökar karaktärens hastighet. 
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    (define/public (jump!) ;; Ger karaktären en negativ hastighet i y-led. 
      (set! vy -0.9))
    
    (define/public (render canvas dc) ;; Tar in canvas och dc som argument och säger åt banan att rita en rektangel. 
      (send the-map draw-rectangle x y width height "white" canvas dc))
    
    (define/public (move!) ;; Exekverar en rad procedurer vid anrop, som talar om hur karaktären skall röra sig.
      (when (is-a? the-map map%)
        (unless (on-ground?)
          (gravitate!)) ;; Låter tyngdaccelerationen verka om man inte står på marken. 
        
        (decelerate!)
        
        (let ([new-x (+ x (* vx *dt*))] ;; Detta let-uttryck gör så att karaktären inte kan gå igenom solida tiles. 
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

    (define/public (die!) ;; Se remove-self!
      (displayln "Blargh!")
      (remove-self!)) ;; detta kanske inte bör göras omedelbart
    
    (define/public (hurt! damage) ;; Tar in ett heltal som argument och minskar karaktärens liv med det talet. 
      (set! hp (- hp damage))
      (when (not (positive? hp))
        (die!)))
    
    (define/public (update!) ;; Kör move!-proceduren vid anrop. 
      (when the-map
        (move!)))
    
    (super-new)))
