------------------------------------------------------------------------
-- Conversion of < to ≤, along with a number of properties
------------------------------------------------------------------------

-- Possible TODO: Prove that a conversion ≤ -> < -> ≤ returns a
-- relation equivalent to the original one (and similarly for
-- < -> ≤ -> <).

open import Relation.Binary

module Relation.Binary.StrictToNonStrict
         {a : Set} (_≈_ _<_ : Rel a)
         where

open import Relation.Nullary
open import Relation.Binary.Consequences
open import Data.Function
open import Logic
open import Data.Product
open import Data.Sum

------------------------------------------------------------------------
-- Conversion

-- _<_ can be turned into _≤_ as follows:

_≤_ : Rel a
x ≤ y = (x < y) ⊎ (x ≈ y)

------------------------------------------------------------------------
-- The converted relations have certain properties
-- (if the original relations have certain other properties)

abstract

  ≤-refl : Reflexive _≈_ _≤_
  ≤-refl = inj₂

  ≤-antisym
    :  IsEquivalence _≈_
    -> Transitive _<_
    -> Irreflexive _≈_ _<_
    -> Antisymmetric _≈_ _≤_
  ≤-antisym eq trans irrefl = antisym
    where
    module Eq = IsEquivalence eq

    antisym : Antisymmetric _≈_ _≤_
    antisym (inj₂ x≈y) _          = x≈y
    antisym (inj₁ _)   (inj₂ y≈x) = Eq.sym y≈x
    antisym (inj₁ x<y) (inj₁ y<x) =
      ⊥-elim (trans∧irr⟶asym Eq.refl trans irrefl x<y y<x)

  ≤-trans
    :  IsEquivalence _≈_ -> _≈_ Respects₂ _<_
    -> Transitive _<_ -> Transitive _≤_
  ≤-trans eq ≈-resp-< <-trans = trans
    where
    module Eq = IsEquivalence eq

    trans : Transitive _≤_
    trans (inj₁ x<y) (inj₁ y<z) = inj₁ $ <-trans x<y y<z
    trans (inj₁ x<y) (inj₂ y≈z) = inj₁ $ proj₁ ≈-resp-< y≈z x<y
    trans (inj₂ x≈y) (inj₁ y<z) = inj₁ $ proj₂ ≈-resp-< (Eq.sym x≈y) y<z
    trans (inj₂ x≈y) (inj₂ y≈z) = inj₂ $ Eq.trans x≈y y≈z

  ≈-resp-≤ : IsEquivalence _≈_ -> _≈_ Respects₂ _<_ -> _≈_ Respects₂ _≤_
  ≈-resp-≤ eq ≈-resp-< = ((\{_ _ _} -> resp₁) , (\{_ _ _} -> resp₂))
    where
    open IsEquivalence eq

    resp₁ : forall {x y' y} -> y' ≈ y -> x  ≤ y' -> x ≤ y
    resp₁ y'≈y (inj₁ x<y') = inj₁ (proj₁ ≈-resp-< y'≈y x<y')
    resp₁ y'≈y (inj₂ x≈y') = inj₂ (trans x≈y' y'≈y)

    resp₂ : forall {y x' x} -> x' ≈ x -> x' ≤ y  -> x ≤ y
    resp₂ x'≈x (inj₁ x'<y) = inj₁ (proj₂ ≈-resp-< x'≈x x'<y)
    resp₂ x'≈x (inj₂ x'≈y) = inj₂ (trans (sym x'≈x) x'≈y)

  ≤-total : Trichotomous _≈_ _<_ -> Total _≤_
  ≤-total <-tri x y with <-tri x y
  ... | Tri₁ x<y x≉y x≯y = inj₁ (inj₁ x<y)
  ... | Tri₂ x≮y x≈y x≯y = inj₁ (inj₂ x≈y)
  ... | Tri₃ x≮y x≉y x>y = inj₂ (inj₁ x>y)

  ≤-decidable : Decidable _≈_ -> Decidable _<_ -> Decidable _≤_
  ≤-decidable ≈-dec <-dec x y with ≈-dec x y | <-dec x y
  ... | yes x≈y | _       = yes (inj₂ x≈y)
  ... | no  x≉y | yes x<y = yes (inj₁ x<y)
  ... | no  x≉y | no  x≮y = no helper
    where
    helper : x ≤ y -> ⊥
    helper (inj₁ x<y) = x≮y x<y
    helper (inj₂ x≈y) = x≉y x≈y