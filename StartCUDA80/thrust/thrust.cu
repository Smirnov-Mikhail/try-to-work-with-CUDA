#include <thrust/host_vector.h>	
#include <thrust/device_vector.h>
#include <thrust/fill.h>
#include <stdio.h>

using namespace thrust;
using namespace std;

int main() {	// ������������� ��������� ������������ Thrust. �������� ���� ��������� ���� ��������
	const int N = 1000;
	device_vector<int> a_dev(N);			// �������� ������� �� ���
	thrust::fill(a_dev.begin(), a_dev.end(), 1);	// ���������� ������� ���������� 1
	device_vector<int> b_dev(N);
	thrust::fill(b_dev.begin(), b_dev.end(), 2);

	device_vector<int> c_dev(N); 	// �������� ������� �� ��� ��� ������ ����������
	for (int i = 0; i < c_dev.size(); i++)
	{
		c_dev[i] = a_dev[i] + b_dev[i];  	// �������� ���� ���-�������� � ������ ���������� � ������ ���-������
	}
	host_vector<int> c_host = c_dev;	// �������� ������� �� ��� � ����������� ���������� � ���� �� ���-�������
	int sum = reduce(c_host.begin(), c_host.end());  // �������� ���� ��������� �������
	cout << sum << endl;		// ����� ����������
	return 0;
}
