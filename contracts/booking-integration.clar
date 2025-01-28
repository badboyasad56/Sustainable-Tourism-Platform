;; Booking Integration Contract

(define-map sustainability-metrics
  { entity-id: uint }
  {
    energy-consumption: uint,
    water-usage: uint,
    waste-production: uint,
    local-sourcing-percentage: uint,
    last-updated: uint
  }
)

(define-map certified-entities
  { entity-id: uint }
  { is-certified: bool }
)

(define-public (update-sustainability-metrics
  (entity-id uint)
  (energy-consumption uint)
  (water-usage uint)
  (waste-production uint)
  (local-sourcing-percentage uint)
)
  (begin
    (asserts! (is-authorized-updater tx-sender) (err u403))
    (map-set sustainability-metrics
      { entity-id: entity-id }
      {
        energy-consumption: energy-consumption,
        water-usage: water-usage,
        waste-production: waste-production,
        local-sourcing-percentage: local-sourcing-percentage,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

(define-read-only (get-sustainability-metrics (entity-id uint))
  (map-get? sustainability-metrics { entity-id: entity-id })
)

(define-read-only (is-authorized-updater (address principal))
  (or
    (is-eq address tx-sender)
    (is-eq address 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
    (is-eq address 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
    (is-eq address 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC)
  )
)

(define-public (certify-entity (entity-id uint))
  (begin
    (asserts! (is-authorized-updater tx-sender) (err u403))
    (map-set certified-entities
      { entity-id: entity-id }
      { is-certified: true }
    )
    (ok true)
  )
)

(define-read-only (is-certified (entity-id uint))
  (default-to false (get is-certified (map-get? certified-entities { entity-id: entity-id })))
)

(define-public (book-sustainable-stay (entity-id uint) (nights uint))
  (begin
    (asserts! (is-certified entity-id) (err u400))
    ;; Here we would integrate with an external booking system
    ;; For demonstration, we'll just emit an event
    (print { type: "booking", entity-id: entity-id, nights: nights })
    (ok true)
  )
)

