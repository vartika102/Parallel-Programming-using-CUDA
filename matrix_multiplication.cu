#include<iostream>
#include<conio.h>
#include"cuda.h"
#include<stdio.h>
#include<cuda_runtime_api.h>

using namespace std;

/*Kernel Function: All the 3 matrices along with the width(no. of elements in each row of 1st matrix)
 are recieved as arguments for the function. Each thread calculates one element of the product
 matrix i.e. (i*width+j)th thread calculates the ith row and jth column element of the product
 matrix by multiplying each element  of ith row of the 1st matrix to the corresponding elements 
 of the jth column of 2nd matrix.*/

__global__ void mulKernel(float *A1, float *B1, float *C1, int width)
{
    int row = blockIdx.x;
	int col = threadIdx.x;
	if(row<width && col<width)
	{
	    C1[row*width + col] = 0; //initialising element to 0.

	    /*To calculating the sum of the product of the corresponding elements of 
	      the (row)th row of 1st  array and (col)th column of the 2nd array inorder to 
          get the element of the (row)th row and (col)th column of the product 
          matrix*/

	    for(int i=0; i<width; i++) 
	        C1[row*width + col] += A1[row*width + i]* B1[i*width + col];
	}
}

int main(void)
{
   //declaration of Host and Device variables
   float *A, *B, *C;
   float *a, *b, *c;
   int w, am, an, bm, bn;

   //Input the dimensions of the input array
   cout<<"Enter the dimensions of the 1st array:";
   cin>>am>>an;
   cout<<"Enter the dimensions of the 2nd array:";
   cin>>bm>>bn;
   w = an; //width of the product matrix

   //memory allocation on Host Memory
   A = (float*)malloc(sizeof(float)*am*an);
   B = (float*)malloc(sizeof(float)*bm*bn);
   C = (float*)malloc(sizeof(float)*am*bn);

   //memory allocation on Device Memory
   cudaMalloc((void**)&a,sizeof(float)*am*an);
   cudaMalloc((void**)&b,sizeof(float)*bm*bn);
   cudaMalloc((void**)&c,sizeof(float)*am*bn);

   //Input to 1st array in vector form
   cout<<"Enter the 1st array:"<<endl;
   for(int i=0; i<an*am; i++)
       cin>>A[i];

   //Input to 2nd array in vector form
   cout<<"Enter the 2nd array:"<<endl;
   for(int i=0; i<bn*bm; i++)
       cin>>B[i];

   //Copying input matrices from Host to Device
   cudaMemcpy(a,A,sizeof(float)*am*an,cudaMemcpyHostToDevice);
   cudaMemcpy(b,B,sizeof(float)*bm*bn,cudaMemcpyHostToDevice);

   /*Kernel Launch: here ‘am’ is the no. of rows of the 1st matrix and ‘bn’ is the no. 
     of columns of the  2nd matrix, and hence the dimensions of the product 
     matrix. Each Block corresponds to a row in the product matrix and each thread 
     corresponds to each element of the product matrix. Moreover, the 2 input 
     matrices, the product matrix and the width are passed as vector arguments to 
     the Kernel Function.*/

   mulKernel<<<am,bn>>>(a,b,c,w);
   cudaDeviceSynchronize();

   //Copying product matrix from Device to Host
   cudaMemcpy(C,c,sizeof(float)*am*bn,cudaMemcpyDeviceToHost);

   //Output the product matrix
   cout<<"resultant array:"<<endl;
   for(int i=0; i<am; i++)
   {
      for(int j=0; j<bn; j++)
         cout<<C[i*am + j];
     cout<<endl;
   }

   getch();
   return 0;
}