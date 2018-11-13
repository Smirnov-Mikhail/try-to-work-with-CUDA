#include <device_launch_parameters.h>
#include <cuda_runtime.h>
#include <stdio.h>
__global__ void addKernel(int *c, int *a, int *b) {
	int i = threadIdx.x;
	c[i] = a[i] + b[i];		// Сложение двух векторов на ГПУ
}
int main() {
	const int N = 100;
	int *a_dev; int *b_dev; int *c_dev;	// Объявление указателей (единых для ГПУ и ЦПУ)

	cudaMallocManaged(&a_dev, N * sizeof(int));		// Выделение Unified Memory для векторов
	cudaMallocManaged(&b_dev, N * sizeof(int));
	cudaMallocManaged(&c_dev, N * sizeof(int));
	cudaDeviceSynchronize();
	for (int i = 0; i < N; i++) { a_dev[i] = 1; b_dev[i] = 2; }	// Присваивание значений на ЦПУ

	addKernel << <1, N >> >(c_dev, a_dev, b_dev);	// Вызов функции сложения на ГПУ
	cudaDeviceSynchronize();
	int res = 0;
	for (int i = 0; i < N; i++) { res += c_dev[i]; }		// Суммирование результируещего вектора на ЦПУ
	return 0;
}
