#include <thrust/host_vector.h>	
#include <thrust/device_vector.h>
#include <thrust/fill.h>
#include <stdio.h>

using namespace thrust;
using namespace std;

int main() {	// Использование некоторых возможностей Thrust. Сложение всех элементов двух векторов
	const int N = 1000;
	device_vector<int> a_dev(N);			// Создание вектора на ГПУ
	thrust::fill(a_dev.begin(), a_dev.end(), 1);	// Заполнение вектора значениями 1
	device_vector<int> b_dev(N);
	thrust::fill(b_dev.begin(), b_dev.end(), 2);

	device_vector<int> c_dev(N); 	// Создание вектора на ГПУ для записи результата
	for (int i = 0; i < c_dev.size(); i++)
	{
		c_dev[i] = a_dev[i] + b_dev[i];  	// Сложение двух ГПУ-векторов и запись результата в третий ГПУ-вектор
	}
	host_vector<int> c_host = c_dev;	// Создание вектора на ЦПУ и копирование результата в него из ГПУ-вектора
	int sum = reduce(c_host.begin(), c_host.end());  // Сложение всех элементов массива
	cout << sum << endl;		// Вывод результата
	return 0;
}
