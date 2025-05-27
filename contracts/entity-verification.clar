;; Entity Verification Contract
;; Validates interplanetary trade participants

(define-map verified-entities
    { entity-id: principal }
    {
        entity-type: (string-ascii 50),
        planet-origin: (string-ascii 50),
        verification-level: uint,
        verified-at: uint,
        is-active: bool
    }
)

(define-map entity-reputation
    { entity-id: principal }
    { reputation-score: uint, trade-count: uint }
)

(define-data-var contract-owner principal tx-sender)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u1001))
(define-constant ERR-ENTITY-NOT-FOUND (err u1002))
(define-constant ERR-INVALID-VERIFICATION-LEVEL (err u1003))

;; Register a new entity
(define-public (register-entity (entity-type (string-ascii 50)) (planet-origin (string-ascii 50)))
    (begin
        (map-set verified-entities
            { entity-id: tx-sender }
            {
                entity-type: entity-type,
                planet-origin: planet-origin,
                verification-level: u1,
                verified-at: block-height,
                is-active: true
            }
        )
        (map-set entity-reputation
            { entity-id: tx-sender }
            { reputation-score: u100, trade-count: u0 }
        )
        (ok true)
    )
)

;; Verify entity (admin only)
(define-public (verify-entity (entity-id principal) (verification-level uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (and (>= verification-level u1) (<= verification-level u5)) ERR-INVALID-VERIFICATION-LEVEL)
        (match (map-get? verified-entities { entity-id: entity-id })
            entity-data (begin
                (map-set verified-entities
                    { entity-id: entity-id }
                    (merge entity-data { verification-level: verification-level })
                )
                (ok true)
            )
            ERR-ENTITY-NOT-FOUND
        )
    )
)

;; Update reputation
(define-public (update-reputation (entity-id principal) (reputation-change int))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (match (map-get? entity-reputation { entity-id: entity-id })
            rep-data (begin
                (let ((new-score (+ (get reputation-score rep-data) (if (> reputation-change 0) (to-uint reputation-change) u0))))
                    (map-set entity-reputation
                        { entity-id: entity-id }
                        {
                            reputation-score: new-score,
                            trade-count: (+ (get trade-count rep-data) u1)
                        }
                    )
                )
                (ok true)
            )
            ERR-ENTITY-NOT-FOUND
        )
    )
)

;; Read-only functions
(define-read-only (get-entity-info (entity-id principal))
    (map-get? verified-entities { entity-id: entity-id })
)

(define-read-only (get-entity-reputation (entity-id principal))
    (map-get? entity-reputation { entity-id: entity-id })
)

(define-read-only (is-entity-verified (entity-id principal))
    (match (map-get? verified-entities { entity-id: entity-id })
        entity-data (and (get is-active entity-data) (>= (get verification-level entity-data) u2))
        false
    )
)
