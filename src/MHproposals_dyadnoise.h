#ifndef MHproposals_dyadnoise_H
#define MHproposals_dyadnoise_H

#include "edgetree.h"
#include "changestat.h"
#include "model.h"
#include "MHproposal.h"

void MH_dyadnoiseTNT (MHproposal *MHp, Network *nwp);
void MH_dyadnoisemTNT (MHproposal *MHp, Network *nwp);
void MH_dyadnoise (MHproposal *MHp, Network *nwp);
void MH_dyadnoisem (MHproposal *MHp, Network *nwp);

#endif 

