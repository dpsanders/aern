#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "GenericCoeff/coeff.h"
#include "GenericCoeff/poly.h"
#include "EvalExport_stub.h"

void
ADD_COEFF_CODE(printPoly)(Poly *p)
{
  printf("Polynomial C-level details:\n");

  Size arity = p -> maxArity;
  Size psize = p -> psize;
  Term * terms = p -> terms;

  printf("  maxArity = %d\n", p -> maxArity);
  printf("  maxSize = %d\n", p -> maxSize);
  printf("  maxTermArity = %d\n", p -> maxTermArity);
  printf("    constant term addr = %p\n", p -> constTerm);
  printf("  psize = %d\n", psize);

  for (int i = 0; i < psize; i++)
    {
      printf("    term ");
      printf(" monomial degree = %d,", MONOMIAL_DEGREE(terms[i].powers));
      printf(" arity = %d\n", TERM_ARITY(terms[i].powers));
      FOREACH_VAR_ARITY(var, arity)
        {
          printf("[%d]", POWER_OF_VAR(terms[i].powers, var));
        }
      printf(" coeff addr = %p\n", terms[i].coeff);
    }
}

void
ADD_COEFF_CODE(freePoly)(Poly *p)
{
  //  printf("freePoly: starting\n");
  // free the Poly struct:
  Size maxSize = p -> maxSize;
  Size psize = p -> psize;
  Term * terms = p -> terms;
  CFM_FREE(p -> constTerm);
  CFM_FREE(p -> errorBound);
  free(p);

  Size i = 0;
  // free the power arrays:
  while (i < psize)
    {
      free(terms[i].powers);
      CFM_FREE(terms[i].coeff);
      i++;
    }

  // free the coeffs:
  while (i < maxSize)
    {
      free(terms[i].powers);
      i++;
    }

  // free the terms array:
  free(terms);
  //  printf("freePoly: finished\n");
}

void
ADD_COEFF_CODE(mapCoeffsInPlace)(ConversionOp convert, Poly *p)
{
  Coeff temp = p -> constTerm;
  p -> constTerm = CFM_CONVERT(convert, p -> constTerm);
  CFM_FREE(temp);

  temp = p -> errorBound;
  p -> errorBound = CFM_CONVERT(convert, p -> errorBound);
  CFM_FREE(temp);

  Size psize = p -> psize;
  Term * terms = p -> terms;
  for (Size i = 0; i < psize; ++i)
    {
      temp = terms[i].coeff;
      terms[i].coeff = CFM_CONVERT(convert, terms[i].coeff);
      CFM_FREE(temp);
    }
}

Poly *
ADD_COEFF_CODE(newConstPoly)(Coeff c, Coeff errorBound, Var maxArity,
    Size maxSize, Power maxDeg, Var maxTermArity)
{
  //  printf("newConstPoly: starting\n");
  Poly * poly = (Poly *) malloc(sizeof(Poly));
  poly -> maxArity = maxArity;
  poly -> maxSize = maxSize;
  poly -> maxDeg = maxDeg;
  poly -> maxTermArity = maxTermArity;
  poly -> errorBound = errorBound;
  poly -> psize = 0;
  poly -> constTerm = c;
  poly -> terms = malloc(maxSize * sizeof(Term));

  // allocate space for terms' powers:
  for (Size i = 0; i < maxSize; i++)
    {
      (poly -> terms)[i].powers = (Power *) malloc(SIZEOF_POWERS(maxArity));
      // no need to initialise powers and
      // coefficients as these terms are inactive
    }

  //  printf("newConstPoly: returning\n");
  return poly;
}

Poly *
ADD_COEFF_CODE(newTestPoly)(Coeff c, Coeff a0, Coeff a1, Coeff errorBound)
{
  //  printf("newConstPoly: starting\n");
  Poly * poly = (Poly *) malloc(sizeof(Poly));
  poly -> maxArity = 2;
  poly -> maxSize = 2;
  poly -> maxDeg = 3;
  poly -> maxTermArity = 3;
  poly -> errorBound = errorBound;
  poly -> constTerm = c;
  poly -> psize = 2;
  poly -> terms = malloc(poly -> maxSize * sizeof(Term));

  Power * powers0 = (Power *) malloc(SIZEOF_POWERS(poly -> maxArity));
  MONOMIAL_DEGREE(powers0) = 1;
  TERM_ARITY(powers0) = 1;
  POWER_OF_VAR(powers0, 0) = 1;
  POWER_OF_VAR(powers0, 1) = 0;
  (poly -> terms)[0].powers = powers0;
  (poly -> terms)[0].coeff = a0;

  Power * powers1 = (Power *) malloc(SIZEOF_POWERS(poly -> maxArity));
  MONOMIAL_DEGREE(powers1) = 3;
  TERM_ARITY(powers1) = 2;
  POWER_OF_VAR(powers1, 0) = 2;
  POWER_OF_VAR(powers1, 1) = 1;
  (poly -> terms)[1].powers = powers1;
  (poly -> terms)[1].coeff = a1;

  // no need to initialise powers and
  // coefficients as these terms are inactive

  //  printf("newConstPoly: returning\n");
  return poly;
}

// ASSUMES: 0 <= var < maxArity
// ASSUMES: 0 < maxSize
// ASSUMES: 0 < maxDeg
// ASSUMES: 0 < maxTermArity <= 14

Poly *
ADD_COEFF_CODE(newProjectionPoly)(Coeff zero, Coeff one, Coeff errorBound,
    Var var, Var maxArity, Size maxSize, Power maxDeg, Var maxTermArity)
{
  Poly * poly = ADD_COEFF_CODE(newConstPoly)(zero, errorBound, maxArity,
      maxSize, maxDeg, maxTermArity);

  // add one term for the variable:
  poly -> psize = 1;
  Term * term = poly -> terms;

  // initialise the term's coeff:
  term -> coeff = one;
  //  printf("newProjectionPoly: coeff one address = %p\n", term -> coeff);

  // initialise the term's powers:
  Power * powers = term -> powers;

  // initialise the "cache" of the monomial degree:
  MONOMIAL_DEGREE(powers) = 1;

  // initialise the "cache" of the term arity:
  TERM_ARITY(powers) = 1;

  // all zero:
  FOREACH_VAR_ARITY(v,maxArity)
    {
      POWER_OF_VAR(powers,v) = 0;
    }

  // except the chosen var:
  POWER_OF_VAR(powers,var) = 1;

  return poly;
}
