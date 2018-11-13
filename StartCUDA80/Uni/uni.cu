#include <device_launch_parameters.h>
#include <cuda_runtime.h>
#include <stdio.h>
__global__ void addKernel(int *c, int *a, int *b) {
	int i = threadIdx.x;
	c[i] = a[i] + b[i];		// �������� ���� �������� �� ���
}
int main() {
	const int N = 100;
	int *a_dev; int *b_dev; int *c_dev;	// ���������� ���������� (������ ��� ��� � ���)

	cudaMallocManaged(&a_dev, N * sizeof(int));		// ��������� Unified Memory ��� ��������
	cudaMallocManaged(&b_dev, N * sizeof(int));
	cudaMallocManaged(&c_dev, N * sizeof(int));
	cudaDeviceSynchronize();
	for (int i = 0; i < N; i++) { a_dev[i] = 1; b_dev[i] = 2; }	// ������������ �������� �� ���

	addKernel << <1, N >> >(c_dev, a_dev, b_dev);	// ����� ������� �������� �� ���
	cudaDeviceSynchronize();
	int res = 0;
	for (int i = 0; i < N; i++) { res += c_dev[i]; }		// ������������ ��������������� ������� �� ���
	return 0;
}
