#include <iostream>
#include <cstdlib>
#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <ctime>

using namespace std;

#define N (1024*128)
#define M (100000)

__global__ void cudakernel(float *buf)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	buf[i] = 1.0001f * i / N + 0.0002f;
	for (int j = 0; j < M; j++)
		buf[i] = buf[i] * buf[i] - 0.25f;
	buf[i] += (float)i / (float)N;
}

int main()
{
	float data[N];
	float *d_data;
	unsigned int start_time = clock();
	cudaMalloc(&d_data, N * sizeof(float));
	cudakernel << <N / 256, 256 >> >(d_data);
	cudaDeviceSynchronize();
	cudaMemcpy(data, d_data, N * sizeof(float), cudaMemcpyDeviceToHost);
	cudaFree(d_data);
	unsigned int end_time = clock(); // конечное время
	unsigned int search_time = end_time - start_time; // искомое время
	cout << "runtime = " << search_time / 1000.0 << endl;
	while (true)
	{
		int index;
		printf("Enter an index: ");
		cin >> index;
		printf("data[%d] = %f\n", index, data[index]);
	}
}