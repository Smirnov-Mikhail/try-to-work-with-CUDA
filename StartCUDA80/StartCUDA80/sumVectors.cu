#include <device_launch_parameters.h>
#include <cuda_runtime.h>
#include <stdio.h>
#include <iostream>

using namespace std;

__global__ void addKernel(int *c, int *a, int *b) {
	int i = threadIdx.x;
	c[i] = a[i] + b[i];		// Сложение двух векторов на ГПУ
}
int main() {
	const int N = 100; 
	int size = N * sizeof(int);
	int *a_dev; 
	int *b_dev; 
	int *c_dev;	// Объявление указателей для ГПУ

	int *c_host = (int*)malloc(size); 	
	int *a_host = (int*)malloc(size); 	
	int *b_host = (int*)malloc(size); // Выделение памяти ЦПУ

	cudaMalloc(&a_dev, size); 	
	cudaMalloc(&b_dev, size); 	
	cudaMalloc(&c_dev, size); // Выделение памяти ГПУ
	cudaDeviceSynchronize();
	for (int i = 0; i < N; i++) 
	{ a_host[i] = 1; b_host[i] = 2; } 		// Инициализация векторов на хосте

	cudaMemcpy(a_dev, a_host, size, cudaMemcpyHostToDevice);	// Копирование значений на ГПУ
	cudaMemcpy(b_dev, b_host, size, cudaMemcpyHostToDevice);
	addKernel << <1, N >> >(c_dev, a_dev, b_dev);			// Вызов функции на ГПУ
	cudaDeviceSynchronize();
	cudaMemcpy(c_host, c_dev, size, cudaMemcpyDeviceToHost);	// Копирование результата на хост
	int res = 0;
	for (int i = 0; i < N; i++) { res += c_host[i]; }			// Сложение всех значений
	cout << "result: " << res << endl;
	return 0;
}
