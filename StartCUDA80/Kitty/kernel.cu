#include "cuda.h"
#include "cuProc.h"
#define BLOCKSIZE 16
#define GridSize(size) (size/BLOCKSIZE + 1)

__global__ void addContours(int* out_gray, int* out_alpha, int* graylvl, int* alpha, /* from original image */
	int height, int width,  /* size of original image */
	int deviation /* the width of liminiscence strip */
) {
	int x = blockDim.x*blockIdx.x + threadIdx.x;
	int y = blockDim.y*blockIdx.y + threadIdx.y;
	if (alpha[x + y * width] == 0 /* if pixel is transparent */) {
		int mindev = 2 * deviation;
		for (int i = -deviation; i <= deviation; i++) {
			for (int j = -deviation; j <= deviation; j++) {
				if (x + i >= 0 && x + i < width && y + j >= 0 && y + j < height) {
					if (graylvl[x + i + (y + j) * width] < 128 && alpha[x + i + (y + j) * width] != 0 && mindev > min(abs(i), abs(j))) {
						mindev = min(abs(i), abs(j));
					}
				}
			}
		}
		if (mindev < 2 * deviation) {
			out_alpha[x + y * width] = 255 / mindev;
			out_gray[x + y * width] = 255;
		}
	}
	else {
		out_alpha[x + y * width] = alpha[x + y * width];
		out_gray[x + y * width] = graylvl[x + y * width];
	}
}

void process(int* img, int* alpha, int height, int width, int dev) {
	//	cudaSetDevice(0);
	cudaError_t err;
	int* img_dev;
	int* out_img_dev;
	int* alpha_dev;
	int* out_alpha_dev;
	int alloc_size = height*width * sizeof(int);

	err = cudaMalloc((void**)&img_dev, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}
	err = cudaMalloc((void**)&alpha_dev, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}
	err = cudaMalloc((void**)&out_img_dev, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}
	err = cudaMalloc((void**)&out_alpha_dev, alloc_size);
	if (err != cudaSuccess) {
		printf("ERROR: unable to  allocate!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}

	err = cudaMemcpy(img_dev, img, alloc_size, cudaMemcpyHostToDevice);
	if (err != cudaSuccess) {
		printf("ERROR: unable to copy h2d!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}
	err = cudaMemcpy(alpha_dev, alpha, alloc_size, cudaMemcpyHostToDevice);
	if (err != cudaSuccess) {
		printf("ERROR: unable to copy h2d!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}

	addContours << < dim3(width / BLOCKSIZE, height / BLOCKSIZE), dim3(BLOCKSIZE, BLOCKSIZE) >> >(out_img_dev, out_alpha_dev, img_dev, alpha_dev, height, width, dev);
	cudaDeviceSynchronize();
	err = cudaMemcpy(img, out_img_dev, alloc_size, cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) {
		printf("ERROR: unable to copy d2h!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}
	err = cudaMemcpy(alpha, out_alpha_dev, alloc_size, cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) {
		printf("ERROR: unable to copy d2h!\n");
		std::cerr << "Err is " << cudaGetErrorString(err) << std::endl;
	}
	cudaFree(alpha_dev);
	cudaFree(img_dev);
	cudaFree(out_img_dev);
	cudaFree(out_alpha_dev);
	//	cudaDeviceReset();
}