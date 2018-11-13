// testc++.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <ctime>

using namespace std;

#define N (1024*128)
#define M (100000)
int main()
{
	float data[N];
	unsigned int start_time = clock();
	for (int i = 0; i < N; i++)
	{
		data[i] = 1.0001f * i / (float)N + 0.0002f;
		for (int j = 0; j < M; j++)
		{
			data[i] = data[i] * data[i] - 0.25f;
		}
		data[i] += (float)i / (float)N;
	}
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