/-
  The dependency audit for the editable tensors core. Every
  theorem of the core is printed with the foundational
  principles it depends on; the family gate fails if any
  printed principle lies outside the allowed set of three.
-/

import Tensors

open Tensor

#print axioms applyEd_untouched
#print axioms applyEd_empty
#print axioms look_append
#print axioms applyEd_append
#print axioms look_invOf
#print axioms reversal_exact
#print axioms look_some_mem
#print axioms adm_protects
#print axioms adm_append
#print axioms tie_control
#print axioms chg_control
#print axioms view_obscure_free
#print axioms view_agree
#print axioms view_det
