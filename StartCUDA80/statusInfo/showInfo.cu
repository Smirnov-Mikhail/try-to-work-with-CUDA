#include <iostream>
#include <cstdlib>
#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
using namespace std;

void DisplayHeader()
{
	const int kb = 1024;
	const int mb = kb * kb;

	wcout << "CUDA version:   v" << CUDART_VERSION << endl;
	int devCount;
	cudaGetDeviceCount(&devCount);

	for (int i = 0; i < devCount; ++i)
	{
		cudaDeviceProp props;
		cudaGetDeviceProperties(&props, i);
		wcout << "Device name: " << props.name << endl;
		wcout << "Compute capability: " << props.major << "." << props.minor << endl;
		wcout << "Global memory:   " << props.totalGlobalMem / mb << "mb" << endl;
		wcout << "Shared memory:   " << props.sharedMemPerBlock / kb << "kb" << endl;
		wcout << "Constant memory: " << props.totalConstMem / kb << "kb" << endl;
		wcout << "Block registers: " << props.regsPerBlock << endl << endl;

		wcout << "Warp size:         " << props.warpSize << endl;
		wcout << "Threads per block: " << props.maxThreadsPerBlock << endl;
		wcout << "Max block dimensions: [ " << props.maxThreadsDim[0] << ", " << props.maxThreadsDim[1] << ", " << props.maxThreadsDim[2] << " ]" << endl;
		wcout << "Max grid dimensions:  [ " << props.maxGridSize[0] << ", " << props.maxGridSize[1] << ", " << props.maxGridSize[2] << " ]" << endl;
		wcout << endl;
	}
}

int main() {
	DisplayHeader();
	return 0;
}