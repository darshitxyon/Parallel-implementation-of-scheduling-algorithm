#include<stdio.h>
#include<time.h>
 
__global__ void fcfs(int *b, int * w, int * t)
{
	int k;
	int j=threadIdx.x;
    extern __shared__ int XY[];
    if(i< blockDim-1 ){
        XY[threadIdx.x + 1 ] =b[j]; }

    if(threadIdx.x==0) XY[0]= 0.0; 

    for(unsigned int stride = 1; stride <= threadIdx.x; stride *= 2) {
        __syncthreads();
        XY[threadIdx.x]+= XY[threadIdx.x - stride]; }

    w[j]=XY[threadIdx.x];
        
	   /*for(k=0;k<j;k++)
    	   {
             w[j]=w[j]+b[k];
            }
        */
	__syncthreads();
	t[j]=b[j]+w[j];
}


int main()
{
    
    int bt[20],p[20],wt[20],tat[20],i,j,n,total=0,total1=0,pos,temp;
    float avg_wt,avg_tat;
    printf("Enter number of process:");
    scanf("%d",&n);
 
    //ENTER THE VALUES
    printf("\nEnter Burst Time:\n");
    for(i=0;i<n;i++)
    {
        printf("p%d:",i+1);
        scanf("%d",&bt[i]);
        p[i]=i+1;           //contains process number
    }
    int *d_bt,*d_wt,*d_tat;
    clock_t begin = clock();

    cudaMalloc( (void**)&d_bt, n * sizeof(int) ) ;
    cudaMalloc( (void**)&d_wt, n * sizeof(int) ) ;
    cudaMalloc( (void**)&d_tat, n * sizeof(int) ) ;

    cudaMemcpy( d_bt, bt, n * sizeof(int), cudaMemcpyHostToDevice ) ;

    fcfs<<<1,n>>>(d_bt,d_wt,d_tat);

    cudaMemcpy( wt,d_wt, n * sizeof(int), cudaMemcpyDeviceToHost ) ;
    cudaMemcpy( tat,d_tat, n * sizeof(int), cudaMemcpyDeviceToHost ) ;
    
    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    for(i=0;i<n;i++){
        total+=wt[i];
        total1+=tat[i];
        }
    avg_wt=(float)total/n;
    avg_tat=(float)total1/n;
    printf("\nProcess\t    Burst Time    \tWaiting Time\tTurnaround Time");
    for(i=0;i<n;i++)
    {
        printf("\np[%d]\t\t  %d\t\t    %d\t\t\t%d",i+1,bt[i],wt[i],tat[i]);
    }
    printf("\n\nAverage Waiting Time=%f",avg_wt);
    printf("\nAverage Turnaround Time=%f\n",avg_tat);
    printf("\ntime elapsed in execution=%f\n",time_spent);
    cudaFree( d_bt );
    cudaFree( d_wt );
    cudaFree( d_tat );
	return 0;
}






