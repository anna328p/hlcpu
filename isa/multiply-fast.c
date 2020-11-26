#include <stdio.h>
#include <stdlib.h>

short multiply_fast(short, short);

int main(int argc, char **argv) {
	short num1 = atoi(argv[1]);
	short num2 = atoi(argv[2]);

	short res = multiply_fast(num1, num2);
	printf("%d\n", res);

	return 0;
}

void swap(short *a, short *b) {
	short temp = *a;
	*a = *b;
	*b = temp;
}

short multiply_fast(short b, short c) {
	short temp = 0;

	if (b > c) swap(&b, &c);

	while (b != 0) {
		if (b & 1) temp += c;
		b >>= 1;
		c <<= 1;
	}

	return temp;
}
