#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void flag_function(void)
{
	printf("%s\n", "CAB{This is not the flag. Stop trying to be sneaky.}");
}

int main(int argc, char const *argv[])
{
	printf("%s\n", "You're going to have to try harder than that!");
	printf("%s\n", "How do you see a function you never touch?");
	printf("%s\n", "Flag looks like CAB{FLAG_GOES_HERE}");
	return 0;
}
