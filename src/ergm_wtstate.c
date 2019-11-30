#include "ergm_wtstate.h"

ErgmWtState *ErgmWtStateInit(// Network settings
			     Vertex n_nodes, Rboolean directed_flag, Vertex bip,
                             // Model settings
			     int nterms, const char *funnames, const char *sonames,
                             // Proposal settings
			     const char *MHProposaltype, const char *MHProposalpackage,
                             // Numeric inputs
			     double *inputs,
                             // Network state
                             Edge n_edges,
			     Vertex *tails, Vertex *heads, double *weights){
  ErgmWtState *s = Calloc(1, ErgmWtState);
  
  s->m=WtModelInitialize(funnames, sonames, &inputs, nterms);
  
  /* Form the network */
  s->nwp=WtNetworkInitialize(tails, heads, weights, n_edges, 
                             n_nodes, directed_flag, bip, 0, 0, NULL);

  /* Trigger initial storage update */
  WtInitStats(s->nwp, s->m);

  /* Initialize the M-H proposal */
  s->MHp=NULL;
  if(MHProposaltype)
    s->MHp = WtMHProposalInitialize(MHProposaltype, MHProposalpackage,
                                    inputs,
                                    s->nwp,
                                    s->m->termarray->aux_storage);
  
  return s;
}

void ErgmWtStateDestroy(ErgmWtState *s){
  if(s->MHp) WtMHProposalDestroy(s->MHp, s->nwp);
  if(s->m) WtModelDestroy(s->nwp, s->m);
  if(s->nwp) WtNetworkDestroy(s->nwp);
  Free(s);
}