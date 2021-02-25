#include "SimpleFIPS202.h"

int main(int argc, char const *argv[])
{
	unsigned char output[32];
	unsigned char input[64] = {97};

	SHAKE256(output, 32, input, 64);

	return 0;
}
