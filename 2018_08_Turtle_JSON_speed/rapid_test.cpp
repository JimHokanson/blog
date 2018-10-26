#include "mex.h"
#include "include/rapidjson/document.h"
#include "include/rapidjson/filereadstream.h"
#include <cstdio>
#include <iostream>

//  mex -DRAPIDJSON_SSE42 rapid_test.cpp
//
/*
tic
for i = 1:10
rapid_test()
end
toc/10
 */

using namespace std;
using namespace rapidjson;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    FILE* fp = std::fopen("./1.json", "r");
    char buffer[65536];
    FileReadStream frs(fp, buffer, sizeof(buffer));
    Document jobj; 
    jobj.ParseStream(frs);

    const Value &coordinates = jobj["coordinates"];
    SizeType len = coordinates.Size();
    double x = 0, y = 0, z = 0;

    for (SizeType i = 0; i < len; i++) {
      const Value &coord = coordinates[i];
      x += coord["x"].GetDouble();
      y += coord["y"].GetDouble();
      z += coord["z"].GetDouble();
    }

//     std::cout << x / len << std::endl;
//     std::cout << y / len << std::endl;
//     std::cout << z / len << std::endl;

    fclose(fp);

}