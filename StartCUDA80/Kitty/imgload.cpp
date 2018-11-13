#include <stdlib.h>
#include <stdio.h>
#include <png.h>
#include "cuProc.h"
#include <iostream>
#include <chrono>
#include <ctime>

int width, height;
png_byte color_type;
png_byte bit_depth;
png_bytep *row_pointers;


void processCPU(int* graylvl, int* alpha, int height, int width, int deviation) {
	int* out_alpha = new int[height*width];
	int* out_gray = new int[height*width];
	for (int x = 0; x < width; x++) {
		for (int y = 0; y < height; y++) {
			if (alpha[x + y * width] == 0 /* if pixel is transparent */) {
				int mindev = 2 * deviation;
				for (int i = -deviation; i <= deviation; i++) {
					for (int j = -deviation; j <= deviation;
						j++) {
						if (x + i >= 0 && x + i < width &&
							y + j >= 0 && y + j < height) {
							if (graylvl[x + i + (y + j) *width] < 128 &&
								alpha[x + i + (y + j) *  width] != 0 && mindev > std::min(abs(i), abs(j))) {
								mindev = std::min(abs(i), abs(j));
							}
						}
					}
				}
				if (mindev < 2 * deviation) {
					out_alpha[x + y * width] = (int)(255 / (mindev + 1));
					out_gray[x + y * width] = 255;
				}
			}
			else {
				out_alpha[x + y * width] = alpha[x + y * width];
				out_gray[x + y * width] =
					graylvl[x + y * width];
			}
		}
	}
	memcpy(graylvl, out_gray, height * width * sizeof(int));
	memcpy(alpha, out_alpha, height * width * sizeof(int));
}




void read_png_file(char *filename) {
	FILE *fp = fopen(filename, "rb");

	png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (!png) abort();

	png_infop info = png_create_info_struct(png);
	if (!info) abort();

	if (setjmp(png_jmpbuf(png))) abort();

	png_init_io(png, fp);

	png_read_info(png, info);

	width = png_get_image_width(png, info);
	height = png_get_image_height(png, info);
	color_type = png_get_color_type(png, info);
	bit_depth = png_get_bit_depth(png, info);

	// Read any color_type into 8bit depth, RGBA format.
	// See http://www.libpng.org/pub/png/libpng-manual.txt

	if (bit_depth == 16)
		png_set_strip_16(png);

	if (color_type == PNG_COLOR_TYPE_PALETTE)
		png_set_palette_to_rgb(png);

	// PNG_COLOR_TYPE_GRAY_ALPHA is always 8 or 16bit depth.
	if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
		png_set_expand_gray_1_2_4_to_8(png);

	if (png_get_valid(png, info, PNG_INFO_tRNS))
		png_set_tRNS_to_alpha(png);

	// These color_type don't have an alpha channel then fill it with 0xff.
	if (color_type == PNG_COLOR_TYPE_RGB ||
		color_type == PNG_COLOR_TYPE_GRAY ||
		color_type == PNG_COLOR_TYPE_PALETTE)
		png_set_filler(png, 0xFF, PNG_FILLER_AFTER);

	if (color_type == PNG_COLOR_TYPE_GRAY ||
		color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
		png_set_gray_to_rgb(png);

	png_read_update_info(png, info);

	row_pointers = (png_bytep*)malloc(sizeof(png_bytep) * height);
	for (int y = 0; y < height; y++) {
		row_pointers[y] = (png_byte*)malloc(png_get_rowbytes(png, info));
	}

	png_read_image(png, row_pointers);

	fclose(fp);
}

void write_png_file(char *filename) {
	int y;

	FILE *fp = fopen(filename, "wb");
	if (!fp) abort();

	png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (!png) abort();

	png_infop info = png_create_info_struct(png);
	if (!info) abort();

	if (setjmp(png_jmpbuf(png))) abort();

	png_init_io(png, fp);

	// Output is 8bit depth, RGBA format.
	png_set_IHDR(
		png,
		info,
		width, height,
		8,
		PNG_COLOR_TYPE_RGBA,
		PNG_INTERLACE_NONE,
		PNG_COMPRESSION_TYPE_DEFAULT,
		PNG_FILTER_TYPE_DEFAULT
	);
	png_write_info(png, info);

	// To remove the alpha channel for PNG_COLOR_TYPE_RGB format,
	// Use png_set_filler().
	//png_set_filler(png, 0, PNG_FILLER_AFTER);

	png_write_image(png, row_pointers);
	png_write_end(png, NULL);

	for (int y = 0; y < height; y++) {
		free(row_pointers[y]);
	}
	free(row_pointers);

	fclose(fp);
}

void process_png_file(int dev) {
	int *img = new int[width * height];
	int *alpha = new int[width * height];
	for (int y = 0; y < height; y++) {
		png_bytep row = row_pointers[y];
		for (int x = 0; x < width; x++) {
			png_bytep px = &(row[x * 4]);
			// Do something awesome for each pixel here...
			//      printf("%4d, %4d = RGBA(%3d, %3d, %3d, %3d)\n", x, y, px[0], px[1], px[2], px[3]);
			img[y*width + x] = px[0];
			alpha[y*width + x] = px[3];
		}
	}

	std::chrono::time_point<std::chrono::system_clock> start, end;
	start = std::chrono::system_clock::now();

	process(img, alpha, height, width, dev);
	// processCPU(img, alpha, height, width, dev);


	end = std::chrono::system_clock::now();
	std::chrono::duration<double> diff = end - start;
	std::cout << std::endl << "Time " << diff.count() << " s\n";

	for (int y = 0; y < height; y++) {
		//png_bytep row = row_pointers[y];
		for (int x = 0; x < width; x++) {
			//png_bytep px = &(row[x * 4]);
			// Do something awesome for each pixel here...
			// printf("%4d, %4d = RGBA(%3d, %3d, %3d, %3d)\n", x, y, px[0], px[1], px[2], px[3]);
			row_pointers[y][4 * x] = img[y*width + x];
			row_pointers[y][4 * x + 1] = img[y*width + x];
			row_pointers[y][4 * x + 2] = img[y*width + x];
			row_pointers[y][4 * x + 3] = alpha[y*width + x];

		}
	}

	std::cout << "copied res" << std::endl;
}

int main(int argc, char *argv[]) {
	if (argc != 4) abort();

	read_png_file(argv[1]);
	process_png_file(atoi(argv[3]));
	write_png_file(argv[2]);

	return 0;
}