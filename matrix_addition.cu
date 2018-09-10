#include<iostream>
#include<conio.h>
#include<stdio.h>
#include"cuda.h"

#include<cuda_runtime_api.h>

using namespace std;

/*Kernel function: It takes the 3 matrices and their size as arguments. Each thread
    calculates an element of resultant matrix.*/

__global__ void addKernel(float *a1, float *b1, int n1, float *c1)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
	/*finding the sum of 2 corresponding elements from the 2 matrices represented
       by a thread*/
	if(i < n1)
	  c1[i] = a1[i] + b1[i];//sum of corresponding elements
}

int main(void)
{
    float *A, *B, *C; //Variables for matrices in Host memory
	float *a, *b, *c; //Variables for matrices in Device memory
	int n, m; //variables for no of rows and columns of the matrices

	cout<<"Enter the dimensions of the array:";
	cin>>m>>n; //To enter the dimensions of matrices

	int x = sizeof(float) * n * m; //to find the size of the matrices in bytes

	//Memory allocation for host variables
	A = (float*)malloc(x);
	B = (float*)malloc(x);
    C = (float*)malloc(x);
	
	int y = m * n; //Calculation of total no. of elements in each matrix
	
	//Memory allocation for device variables
	cudaMalloc((void**)&a, x);
	cudaMalloc((void**)&b, x);
	cudaMalloc((void**)&c, x);
		
	//Input to the 1st array
	cout<<"Enter the elements in the 1st array:"<<endl;
	for(int i=0; i<y; i++)
	{
	  cin>>A[i];
	}
	
	//Input to th 2nd array
	cout<<"Enter the elements in the 2nd array:"<<endl;
	for(int i=0; i<y; i++)
	{
	   cin>>B[i];
	}

	//Copying the arrays from Host to Device
	cudaMemcpy(a, A, x, cudaMemcpyHostToDevice);
	cudaMemcpy(b, B, x, cudaMemcpyHostToDevice);
	
	/*Kernel Launch: Each matrix has dimensions m*n and so a total of m blocks 
        and n threads per block are alotted in a way that each thread corresponds to 
        an element in the resultant matrix. Moreover, all the matrices are passed as 
        arguments to the kernel along with the total no. of elements in each 
        matrix.*/

	addKernel<<<m, n>>>(a, b, y, c);
	cudaDeviceSynchronize();

	//Copying the resultant array from Host to Device
	cudaMemcpy(C, c, x, cudaMemcpyDeviceToHost);

	//Output the resultant array
	cout<<"the sum array:"<<endl;
	for(int i=0; i<y; i++)
	{
	   cout<<C[i]<<endl;
	}

	getch();

	//freeing the memory
	free(A);
    free(B);
    free(C);
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);
	return 0;
}