#ifndef CHANGESTAT_OPERATOR_H
#define CHANGESTAT_OPERATOR_H

#include "changestat.h"
#include "model.h"
#include "storage.h"

unsigned char *unpack_strasdouble(double **x);
Model *unpack_Modelasdouble(double **x);

#endif