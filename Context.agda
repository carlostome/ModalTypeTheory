------------------------------------------------------------------------------
-- A context is just a snoc list.

module Context where

open import Data.Nat
open import Data.Empty
open import Data.Sum

infix  4 _∋_
infixl 5 _⧺_
infixl 6 _,_

data Context (Ty : Set) : Set where
  ∅   : Context Ty
  _,_ : (Γ : Context Ty) → (T : Ty) → Context Ty

-- A shorthand for empty stack
pattern [] = ∅ , ∅

private
  variable
    Ty  : Set
    Γ Δ : Context Ty
    A B : Ty

_⧺_ : Context Ty → Context Ty → Context Ty
Γ ⧺ ∅       = Γ
Γ ⧺ (Δ , A) = (Γ ⧺ Δ) , A

------------------------------------------------------------------------------
-- Membership

data _∋_ {Ty : Set} : Context Ty → Ty → Set where
  Z  : {Γ : Context Ty} {A : Ty}
     → Γ , A ∋ A
  S_ : {Γ : Context Ty} {A B : Ty}
     → Γ     ∋ A
     → Γ , B ∋ A

lookup : Context Ty → ℕ → Ty
lookup (Γ , A) zero     =  A
lookup (Γ , _) (suc n)  =  lookup Γ n
lookup ∅       _        =  ⊥-elim impossible
  where postulate impossible : ⊥

count : (n : ℕ) → Γ ∋ lookup Γ n
count {Γ = Γ , _} zero     =  Z
count {Γ = Γ , _} (suc n)  =  S (count n)
count {Γ = ∅}     _        =  ⊥-elim impossible
  where postulate impossible : ⊥

ext
  : (∀ {A : Ty} →       Γ ∋ A →     Δ ∋ A)
    ---------------------------------
  → (∀ {A B : Ty} → Γ , B ∋ A → Δ , B ∋ A)
ext ρ Z      =  Z
ext ρ (S x)  =  S (ρ x)

------------------------------------------------------------------------------
-- Properties of ⧺

⧺-∋ : ∀ Δ → Γ ⧺ Δ ∋ A → Γ ∋ A ⊎ Δ ∋ A
⧺-∋ ∅       x     = inj₁ x
⧺-∋ (Δ , A) Z     = inj₂ Z
⧺-∋ (Δ , A) (S x) with ⧺-∋ Δ x
... | inj₁ Γ∋A = inj₁ Γ∋A
... | inj₂ Δ∋A = inj₂ (S Δ∋A)

∋-⧺⁺ˡ : Γ ∋ A → Γ ⧺ Δ ∋ A
∋-⧺⁺ˡ {Δ = ∅}     x = x
∋-⧺⁺ˡ {Δ = Δ , B} x = S (∋-⧺⁺ˡ x)

∋-⧺⁺ʳ : ∀ Γ → Δ ∋ A → Γ ⧺ Δ ∋ A
∋-⧺⁺ʳ Γ Z     = Z
∋-⧺⁺ʳ Γ (S x) = S ∋-⧺⁺ʳ Γ x
