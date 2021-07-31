#include "mex.h"

// mex mex_struct_v.0c

/*
tic
n = 100000;
for i = 1:n
   out = mex_struct_v0();
end
toc/n
tic
n = 100000;
for i = 1:n
   out = json.parse('[12345]');
end
toc/n
 */

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	
	const char* field_names_out[] = {"log"};
	plhs[0] = mxCreateStructMatrix(1,1,1,field_names_out);
}
