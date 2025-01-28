;; Reward Distribution Contract

(define-fungible-token eco-token)

(define-map reward-pools
  { entity-id: uint }
  { balance: uint }
)

(define-public (create-reward-pool (entity-id uint) (initial-balance uint))
  (begin
    (try! (ft-mint? eco-token initial-balance tx-sender))
    (try! (ft-transfer? eco-token initial-balance tx-sender (as-contract tx-sender)))
    (map-set reward-pools
      { entity-id: entity-id }
      { balance: initial-balance }
    )
    (ok true)
  )
)

(define-public (distribute-reward (entity-id uint) (recipient principal) (amount uint))
  (let
    ((pool (unwrap! (map-get? reward-pools { entity-id: entity-id }) (err u404))))
    (asserts! (>= (get balance pool) amount) (err u401))
    (try! (as-contract (ft-transfer? eco-token amount tx-sender recipient)))
    (map-set reward-pools
      { entity-id: entity-id }
      { balance: (- (get balance pool) amount) }
    )
    (ok true)
  )
)

(define-read-only (get-reward-pool-balance (entity-id uint))
  (match (map-get? reward-pools { entity-id: entity-id })
    pool (ok (get balance pool))
    (err u404)
  )
)

(define-read-only (get-token-balance (account principal))
  (ft-get-balance eco-token account)
)

