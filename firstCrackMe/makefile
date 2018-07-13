all:
	nasm -f elf32 -g crackme_SOURCE.asm
	ld -m elf_i386 -o firstCrackMe crackme_SOURCE.o
clean:
	rm -f crackme_SOURCE.o
	rm -f firstCrackMe
