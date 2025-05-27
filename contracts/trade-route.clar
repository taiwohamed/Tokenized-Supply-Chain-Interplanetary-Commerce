;; Trade Route Contract
;; Manages interplanetary supply chains

(define-map trade-routes
    { route-id: uint }
    {
        origin-planet: (string-ascii 50),
        destination-planet: (string-ascii 50),
        route-operator: principal,
        estimated-duration: uint,
        base-cost: uint,
        is-active: bool,
        created-at: uint
    }
)

(define-map route-capacity
    { route-id: uint }
    { max-capacity: uint, current-load: uint }
)

(define-data-var next-route-id uint u1)
(define-data-var contract-owner principal tx-sender)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u2001))
(define-constant ERR-ROUTE-NOT-FOUND (err u2002))
(define-constant ERR-ROUTE-FULL (err u2003))
(define-constant ERR-INVALID-CAPACITY (err u2004))

;; Create new trade route
(define-public (create-trade-route
    (origin-planet (string-ascii 50))
    (destination-planet (string-ascii 50))
    (estimated-duration uint)
    (base-cost uint)
    (max-capacity uint))
    (let ((route-id (var-get next-route-id)))
        (map-set trade-routes
            { route-id: route-id }
            {
                origin-planet: origin-planet,
                destination-planet: destination-planet,
                route-operator: tx-sender,
                estimated-duration: estimated-duration,
                base-cost: base-cost,
                is-active: true,
                created-at: block-height
            }
        )
        (map-set route-capacity
            { route-id: route-id }
            { max-capacity: max-capacity, current-load: u0 }
        )
        (var-set next-route-id (+ route-id u1))
        (ok route-id)
    )
)

;; Book capacity on route
(define-public (book-route-capacity (route-id uint) (cargo-size uint))
    (match (map-get? route-capacity { route-id: route-id })
        capacity-data (begin
            (asserts! (<= (+ (get current-load capacity-data) cargo-size) (get max-capacity capacity-data)) ERR-ROUTE-FULL)
            (map-set route-capacity
                { route-id: route-id }
                (merge capacity-data { current-load: (+ (get current-load capacity-data) cargo-size) })
            )
            (ok true)
        )
        ERR-ROUTE-NOT-FOUND
    )
)

;; Release capacity
(define-public (release-route-capacity (route-id uint) (cargo-size uint))
    (match (map-get? route-capacity { route-id: route-id })
        capacity-data (begin
            (let ((new-load (if (>= (get current-load capacity-data) cargo-size)
                               (- (get current-load capacity-data) cargo-size)
                               u0)))
                (map-set route-capacity
                    { route-id: route-id }
                    (merge capacity-data { current-load: new-load })
                )
            )
            (ok true)
        )
        ERR-ROUTE-NOT-FOUND
    )
)

;; Deactivate route (operator only)
(define-public (deactivate-route (route-id uint))
    (match (map-get? trade-routes { route-id: route-id })
        route-data (begin
            (asserts! (is-eq tx-sender (get route-operator route-data)) ERR-NOT-AUTHORIZED)
            (map-set trade-routes
                { route-id: route-id }
                (merge route-data { is-active: false })
            )
            (ok true)
        )
        ERR-ROUTE-NOT-FOUND
    )
)

;; Read-only functions
(define-read-only (get-route-info (route-id uint))
    (map-get? trade-routes { route-id: route-id })
)

(define-read-only (get-route-capacity (route-id uint))
    (map-get? route-capacity { route-id: route-id })
)

(define-read-only (get-available-capacity (route-id uint))
    (match (map-get? route-capacity { route-id: route-id })
        capacity-data (some (- (get max-capacity capacity-data) (get current-load capacity-data)))
        none
    )
)
