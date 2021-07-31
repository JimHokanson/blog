#include "mex.h"

// mex mex_struct_v1.c

/*
tic
n = 100000;
for i = 1:n
   out = mex_struct_v1();
end
toc/n
 */

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {


	//mxArray *mxCreateStructMatrix(mwSize m, mwSize n, int nfields, const char **fieldnames);
	
	const char* field_names[] = {
        "time_doing_something_1", 
        "time_doing_something_2", 
        "time_doing_something_3", 
        "time_doing_something_4", 
        "time_doing_something_5", 
        "time_doing_something_6", 
        "time_doing_something_7", 
        "time_doing_something_8", 
        "time_doing_something_9", 
        "time_doing_something_10",
        "time_doing_something_11", 
        "time_doing_something_12", 
        "time_doing_something_13", 
        "time_doing_something_14", 
        "time_doing_something_15", 
        "time_doing_something_16", 
        "time_doing_something_17", 
        "time_doing_something_18", 
        "time_doing_something_19", 
        "time_doing_something_20",
        "time_doing_something_21", 
        "time_doing_something_22", 
        "time_doing_something_23", 
        "time_doing_something_24", 
        "time_doing_something_25", 
        "time_doing_something_26", 
        "time_doing_something_27", 
        "time_doing_something_28", 
        "time_doing_something_29", 
        "time_doing_something_30"};
        
	mxArray* log = mxCreateStructMatrix(1,1,30,field_names);
	
	const char* field_names_out[] = {"log"};
	//s  = struct('t1',[],'t2',[],'t3',[]) %etc.
	plhs[0] = mxCreateStructMatrix(1,1,1,field_names_out);
	
	for (mwIndex i; i < 30; i++){
		//void mxSetFieldByNumber(mxArray *pm, mwIndex index,int fieldnumber, mxArray *pvalue);
		//index -> 0 based index into array
		
		//s.(sprintf('t%d',i)) = i;
		mxArray* field_value = mxCreateDoubleScalar((double)i);
        mxSetField(plhs[0],0,field_names[i],field_value);
		//mxSetFieldByNumber(plhs[0], 0, i, field_value);
	}
	
	//output.log = log;
	mxSetFieldByNumber(plhs[0], 0, 0, log);

}
