/*
 * scalar.c
 *
 *  Created on: 15 Feb 2011
 *      Author: jas
 */

#include "GenericCoeff/coeff.h"
#include "GenericCoeff/poly.h"

void
ADD_COEFF_CODE(scaleTerms)(Ops * ops, CoeffMutable c, Poly * p)
{
  Var pSize = p -> psize;
  if (pSize > 0) // any terms to scale?
  {
    Term * terms = p -> terms;
    CoeffMutable coeffScaledDn = CFM_NEW(ops, CFM_SAMPLE(ops));
    CoeffMutable maxError = CFM_NEW(ops, CFM_SAMPLE(ops));
    CoeffMutable errorBound = CFM_NEW(ops, CFM_SAMPLE(ops));
    for (int i = 0; i < pSize; i++)
    {
      CFM_MUL_DN(ops, coeffScaledDn, c, terms[i].coeff);
      CFM_MUL_UP(ops, terms[i].coeff, c, terms[i].coeff); // scale coefficient
      // note that we choose the upward rounded scaled constant term, can cause upward drift
      CFM_SUB_UP(ops, maxError, terms[i].coeff, coeffScaledDn); // bound rounding error
      CFM_ADD_UP(ops, errorBound, errorBound, maxError); // accumulate rounding error
    }
    CFM_FREE(coeffScaledDn);
    CFM_FREE(maxError);
    CFM_ASSIGN(ops, p -> errorBound, errorBound); // account for rounding errors
    CFM_FREE(errorBound);
  }
}

void
ADD_COEFF_CODE(scaleUpThin)(Coeff zero, Ops * ops, CoeffMutable c, Poly * p)
{
  ADD_COEFF_CODE(scaleTerms)(ops, c, p); // scale non-constant terms
  CoeffMutable constTerm = CFM_NEW(ops, CFM_SAMPLE(ops));
  CFM_MUL_UP(ops, constTerm, c, p -> constTerm); // scale constTerm up
  CFM_ADD_UP(ops, p -> constTerm, constTerm, p -> errorBound); // account for errorBound
  CFM_FREE(constTerm);
  CFM_ASSIGN_VAL(ops, p -> errorBound, zero); // collapse errorBound
}

void
ADD_COEFF_CODE(scaleDnThin)(Coeff zero, Ops * ops, CoeffMutable c, Poly * p)
{
  ADD_COEFF_CODE(scaleTerms)(ops, c, p); // scale non-constant terms
  CoeffMutable constTerm = CFM_NEW(ops, CFM_SAMPLE(ops));
  CFM_MUL_DN(ops, constTerm, c, p -> constTerm); // scale constTerm down
  CFM_SUB_DN(ops, p -> constTerm, constTerm, p -> errorBound); // account for errorBound
  CFM_FREE(constTerm);
  CFM_ASSIGN_VAL(ops, p -> errorBound, zero); // collapse errorBound
}

void
ADD_COEFF_CODE(scaleEncl)(Ops * ops, CoeffMutable c, Poly * p)
{
  ADD_COEFF_CODE(scaleTerms)(ops, c, p); // scale non-constant terms
  CoeffMutable oldConstTerm = CFM_NEW(ops, CFM_SAMPLE(ops));
  CoeffMutable constTermScaledUp = CFM_NEW(ops, CFM_SAMPLE(ops));
  CoeffMutable constTermScaledDn = CFM_NEW(ops, CFM_SAMPLE(ops));
  CoeffMutable maxError = CFM_NEW(ops, CFM_SAMPLE(ops));
  CFM_ASSIGN(ops, oldConstTerm, p -> constTerm); // fetch constTerm value
  CFM_MUL_UP(ops, constTermScaledUp, c, oldConstTerm); // scale constTerm
  CFM_MUL_DN(ops, constTermScaledDn, c, oldConstTerm);
  CFM_FREE(oldConstTerm);
  CFM_ASSIGN(ops, p -> constTerm, constTermScaledUp); // update constTerm
  CFM_SUB_UP(ops, maxError, constTermScaledUp, constTermScaledDn); // bound rounding error
  CFM_FREE(constTermScaledUp);
  CFM_FREE(constTermScaledDn);
  CFM_ADD_UP(ops, p -> errorBound, p -> errorBound, maxError); // account for rounding error
  CFM_FREE(maxError);
}
