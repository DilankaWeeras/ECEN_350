// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

scalar dummyScalar;
scalar fScalarIsForced=0;
scalar fScalarIsReleased=0;
scalar fScalarHasChanged=0;
scalar fForceFromNonRoot=0;
scalar fNettypeIsForced=0;
scalar fNettypeIsReleased=0;
void  hsG_0__0 (struct dummyq_struct * I1106, EBLK  * I1107, U  I656);
void  hsG_0__0 (struct dummyq_struct * I1106, EBLK  * I1107, U  I656)
{
    U  I1350;
    U  I1351;
    U  I1352;
    struct futq * I1353;
    I1350 = ((U )vcs_clocks) + I656;
    I1352 = I1350 & ((1 << fHashTableSize) - 1);
    I1107->I702 = (EBLK  *)(-1);
    I1107->I706 = I1350;
    if (I1350 < (U )vcs_clocks) {
        I1351 = ((U  *)&vcs_clocks)[1];
        sched_millenium(I1106, I1107, I1351 + 1, I1350);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I656 == 1)) {
        I1107->I707 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I702 = I1107;
        peblkFutQ1Tail = I1107;
    }
    else if ((I1353 = I1106->I1065[I1352].I719)) {
        I1107->I707 = (struct eblk *)I1353->I718;
        I1353->I718->I702 = (RP )I1107;
        I1353->I718 = (RmaEblk  *)I1107;
    }
    else {
        sched_hsopt(I1106, I1107, I1350);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
