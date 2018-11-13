#define CUDA_API_PER_THREAD_DEFAULT_STREAM
#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#define STRCOUNT 2

__global__ void vecAdd(double *res, double *inA, double *inB, size_t n) {
	int x = blockDim.x * blockIdx.x + threadIdx.x;
	if (x >= n) return;
	res[x] = inA[x] + inB[x];
}

void add() {
	size_t N = 10000;
	double *A = new double[N];
	double *B = new double[N];
	double *C = new double[N];
	double *dev_A;
	double *dev_B;
	double *dev_C;
	cudaError_t err;
	int alloc_size = N * sizeof(double);

	cudaStream_t workerstreams[STRCOUNT];
	int str_block = N / STRCOUNT;
	err = cudaMalloc((void **)&dev_A, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}

	err = cudaMalloc((void **)&dev_B, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}

	err = cudaMalloc((void **)&dev_C, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}

	for (int i = 0; i < N; i++) {
		A[i] = i;
		B[i] = i;
	}

	for (int i = 0; i < STRCOUNT; i++) {
		cudaStreamCreate(&workerstreams[i]);
		int k = i * str_block;
		int memsize = str_block * sizeof(double);
		if (i == STRCOUNT - 1) memsize = (N - k) * sizeof(double);

		err = cudaMemcpyAsync(&dev_A[k], &A[k], memsize, cudaMemcpyHostToDevice, workerstreams[i]);
		if (err != cudaSuccess) {
			printf("ERROR: unable to copy h2d!\n");
			std::cerr << "Err is " << cudaGetErrorString(err)
				<< std::endl;
		}

		err = cudaMemcpyAsync(&dev_B[k], &B[k], memsize, cudaMemcpyHostToDevice, workerstreams[i]);
		if (err != cudaSuccess) {
			printf("ERROR: unable to copy h2d!\n");
			std::cerr << "Err is " << cudaGetErrorString(err)
				<< std::endl;
		}
	}
	for (int i = 0; i < STRCOUNT; i++) {
		int k = i * str_block;
		int memsize = str_block * sizeof(double);
		if (i == STRCOUNT - 1) memsize = (N - k) * sizeof(double);
		vecAdd << <memsize, 1, 0,
			workerstreams[i] >> >(&dev_C[k], &dev_A[k], &dev_B[k], memsize);
	}
	cudaDeviceSynchronize();
	err = cudaMemcpy(C, dev_C, alloc_size, cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) {
		printf("ERROR: unable to copy h2d!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}

	for (int i = 0; i < N; i++) {
		std::cout << A[i] << " + " << B[i] << " = " << C[i]
			<< std::endl;
	}
	cudaFree(dev_A);
	cudaFree(dev_B);
	cudaFree(dev_C);
}

int main() {
	add();
	return 0;
}