;; Muterbar dubbelriktad ring
;; ==========================

;; (innehåller även kod för en muterbar triple)

;; saknar procedurer för att ta reda på längden på en ring
;;               och för att ta bort ett element ur en ring

;; Konstruktor
; skapa en tom ring
(define (make-ring)
  (mcons '() 'ring))

;; Identifierare
; identifierare för en ring
(define (ring? maybe-ring)
  (eq? (mcdr maybe-ring) 'ring))

; identifierare för en tom ring
(define (empty-ring? ring)
  (null? (ring-first ring)))

;; Selektorer
; returnerar första elementet i en ring
(define (ring-first ring)
  (mcar ring))

; returnerar värdet på första elementet i en ring
(define (ring-first-value ring)
  (if (empty-ring? ring)
      (error "No first value of empty ring!" ring)
      (c2r (ring-first ring))))

;; Mutatorer
; stoppar in ett nytt element med givet värde först i ringen
; det gamla första elementet blir "till höger om" det nya
(define (ring-insert! ring value)
  (let ([first-element (ring-first ring)])
    (if (null? first-element)
        (let ([new-element (3cons '() value '())])
          (set-c1r! new-element new-element)
          (set-c3r! new-element new-element)
          (set-mcar! ring new-element))
        (let* ([left-element (c1r first-element)]
               [new-element (3cons left-element value first-element)])
          (set-c1r! first-element new-element)
          (set-c3r! left-element new-element)
          (set-mcar! ring new-element)))))

; roterar ringen ett steg åt "vänster"
(define (ring-rotate-left! ring)
  (let ([left-element (c1r (ring-first ring))])
    (set-mcar! ring left-element)))

; roterar ringen ett steg åt "höger"
(define (ring-rotate-right! ring)
  (let ([right-element (c3r (ring-first ring))])
    (set-mcar! ring right-element)))

;; Muterbar triple
;; ===============

; skapa en triple med värdena a, b, c
(define (3cons a b c)
  (mcons a (mcons b c)))

; returnera första värdet
(define (c1r triple)
  (mcar triple))
; returnera andra värdet
(define (c2r triple)
  (mcar (mcdr triple)))
; returnera tredje värdet
(define (c3r triple)
  (mcdr (mcdr triple)))

; ändra första värdet
(define (set-c1r! triple value)
  (set-mcar! triple value))
; ändra andra värdet
(define (set-c2r! triple value)
  (set-mcar! (mcdr triple) value))
; ändra tredje värdet
(define (set-c3r! triple value)
  (set-mcdr! (mcdr triple) value))