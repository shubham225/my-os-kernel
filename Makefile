all:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot/boot.bin