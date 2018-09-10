
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include<iostream>
#include<conio.h>

#include<time.h>

using namespace std;

/*Kernel Function:
    Variables passed to the Kernel:

•	darr – Stores the input matrix.
•	dqueu – Stores the weight calculated for each vertex.
•	ddept – Stores the depth of each vertex.
•	dvis – Initially stores the value for visited vertices and later the final output path.
•	st- Stores the starting vertex.
•	nw – Stores the total no. of vertices.
•	d – Stores the value of maximum depth.
*/

__global__ void myKernel(int *darr, int *dqueu, int *ddept, int *dvis, int st, int nw, int *d)
{
    int x = threadIdx.x;
	int y = blockIdx.x;
	ddept[st] = 0;//updating the depth of the starting vertex with 0.
	dqueu[st] = 0;//Initialising the weight ‘dqueu’ for the starting vertex with 0.
	dvis[st] = 1;//Marking the dvis for starting vertex as visited.
	
	d[0]=0;//Initialising the maximum depth with 0.

	//Calculating depth, weight(queue), dvis of each vertex and maximum depth
	while(ddept[x]==-1)
	{
	    if(darr[y*nw +x] == 1)
	    {
	        if(ddept[x] == -1)
	        {
	            if(ddept[y] != -1)
	            {
	                dvis[x] = 1;
		            ddept[x] = ddept[y]+1;
		            dqueu[x] = dqueu[y]*10 + x;
		            if(d[0]<ddept[x])
	            	    d[0]=ddept[x];
	            }
	        }
	    }
	    __syncthreads();
	    if(darr[y*nw +x] == 1)
	    {
	        if(ddept[y] == -1)
	        {
	            if(ddept[x] != -1)
	            {
	                dvis[y] = 1;
		            ddept[y] = ddept[x]+1;
		            dqueu[y] = dqueu[x]*10 + y;
		            if(d[0]<ddept[y])
	                	  d[0]=ddept[y];
	            }
	        }
	    }
        __syncthreads();
	}
	__syncthreads();

	//Updating weight of vertices having more than one parent vertices.
	for(int i=0; i<d[0]; i++)
	if(darr[y*nw+x] == 1 && ddept[x] != ddept[y])
	{
	    if(ddept[x]>ddept[y] && dqueu[y]<dqueu[x]/10)
	    {
	        if(x<10)
	            dqueu[x]=dqueu[y]*10 + x;
	        else if(x<100)
	            dqueu[x]=dqueu[y]*100 + x;
	        else if(x<1000)
           	    dqueu[x]=dqueu[y]*1000 + x;
	    }
	    __syncthreads();
	    if(ddept[y] > ddept[x] && dqueu[x] < dqueu[y]/10)
	    {
	        if(y<10)
	            dqueu[y] = dqueu[x]*10 + y;
	        else if(y<100)
	            dqueu[y] = dqueu[x]*100 + y;
	        else if(y<1000)
	            dqueu[y] = dqueu[x]*1000 + y;
	    }
	    __syncthreads();
	}
	__syncthreads();

	//Arranging the vertices in increasing order of their weights
	int n1=0;
	x = threadIdx.x;
	for(int i=0; i<nw; i++)
	    if(dqueu[i]<dqueu[x])
	        n1++;
	dvis[n1]=x;
	__syncthreads();

}


int main(void)
{
    /*
    Firstly, all the required variables are declared,

    Variables on the Host:
    •	array- Stores a matrix of size n* n (where n is the total no. of vertices) on Host, which displays the connections between the different vertices i.e. element has a value 1 if its row no. and column no. are connected, else stores 0.
    •	queue – n dimensional vector that stores the weights alotted to each vertex as they are transversed by the threads.
    •	depth – n dimensional vector that stores the depth or heirachy level of each vertex.
    •	vis- n dimensional vector whose all elements are initialised to 0 at first and then , after the kernel launch , updated with different values. It is basically a vector which stores the info whether a particular vertex is visited or not and later it is overwritten by the output.
    •	dmax – Stores the value of maximum depth.
    •	start – Stores the starting vertex.
    •	n – Stores the total no. of vertices.

    Variables on the Device:
    •	darray – n*n matrix to store the values of matrix ‘array’ on Device.
    •	dqueue- n dimensional vector to store values for ‘queue’ on Device.
    •	ddepth – n dimensional vector to store the values for ‘depth’ on Device.
    •	dvist – n dimensional vector to store the values for vis on Device.
    •	dd – Stores the value of maximum depth.

    */

	//Declaration of variables
    int *array, *queue, *depth, *vis, *q, *dmax;
	int *darray, *dqueue, *ddepth, *dvist, *dque, *dd;
	int n, start;
	
	//To input the total no. of vertices
	cout<<"Enter the no. of vertices: ";
	cin>>n;

	//memory allocation on Host
	array = (int*)malloc(sizeof(int)*n*n);
	queue = (int*)malloc(sizeof(int)*n);
	depth = (int*)malloc(sizeof(int)*n);
	vis = (int*)malloc(sizeof(int)*n);
	q = (int*)malloc(sizeof(int)*n);
	dmax = (int*)malloc(sizeof(int)*2);
	
	//Initialising all the elements of the input matrix to 0
	for(int i=0; i<n; i++)
	for(int j=0; j<n; j++)
	{
	    array[i*n+j]=0;
	}

	//Input to the vertices and their connections
	int c;
	for(int i=0; i<n; i++)
	{
	    int x;
		cout<<"Enter the no. of vertices connected with "<<i<<": ";
		cin>>x;
		cout<<"Enter the vertices: ";
		for(int j=0; j<x; j++)
		{
		    cin>>c;
			array[i*n+c]=1;
		}
	}

	//Displaying the matrix representing the connected vertices
	for(int i=0; i<n; i++)
	{
	    for(int j=0; j<n; j++)
	        cout<<array[i*n+j]<<" ";
	    cout<<endl;
	}

	//Input to the starting vertex
	cout<<"Enter the starting vertex: ";
	cin>>start;

	//memory allocation on Device
	cudaMalloc((void**)&darray,sizeof(int)*n*n);
	cudaMalloc((void**)&dqueue,sizeof(int)*n);
	cudaMalloc((void**)&dvist,sizeof(int)*n);
	cudaMalloc((void**)&ddepth,sizeof(int)*n);
	cudaMalloc((void**)&dd,sizeof(int)*2);
	cudaMalloc((void**)&dque,sizeof(int)*n);

	//Initialising the vector dvist(vector to store the visited  to 0 and ddepth to -1
	cudaMemset(dvist,0,sizeof(int)*n);
	cudaMemset(ddepth,-1,sizeof(int)*n);

	//Copying the input matrix from Host to Device.
	cudaMemcpy(darray,array,sizeof(int)*n*n,cudaMemcpyHostToDevice);

	//Kernel Launch
	myKernel<<<n, n>>>(darray, dqueue, ddepth, dvist, start, n, dd);
	cudaDeviceSynchronize();
	
	//Copying the updated values from Device to Host.
	cudaMemcpy(array,darray,sizeof(int)*n*n,cudaMemcpyDeviceToHost);
	cudaMemcpy(queue,dqueue,sizeof(int)*n,cudaMemcpyDeviceToHost);
	cudaMemcpy(depth,ddepth,sizeof(int)*n,cudaMemcpyDeviceToHost);
	cudaMemcpy(vis,dvist,sizeof(int)*n,cudaMemcpyDeviceToHost);
	cudaMemcpy(dmax,dd,sizeof(int)*2,cudaMemcpyDeviceToHost);

	//Displaying the output
	for(int i=0; i<n; i++)
	{
	    cout<<i<<" "<<depth[i]<<" ";
	    cout<<queue[i]<<" ";
	    cout<<endl;
	}
	cout<<"Maximum Depth: "<<dmax[0]<<endl;
	 
	cout<<"The Result of BFS: "; 
	for(int i=0; i<n; i++)
	    cout<<vis[i]<<" ";

   //Freeing the memory.
	free(array);
	free(queue);
	free(depth);
	free(vis);
	free(dmax);
	cudaFree(darray);
	cudaFree(dqueue);
	cudaFree(ddepth);
	cudaFree(dvist);
	cudaFree(dd);

	getch();
}