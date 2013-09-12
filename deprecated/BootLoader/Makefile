all: ../Build/BootLoader.bin
	@echo "BootLoader has been compiled successful!"

clean:
	@rm -rf ../Build/BootLoader.bin

../Build/BootLoader.bin: $(wildcard *.asm)
	@echo "Compiling Bootloader..."
	@nasm -f bin BootLoader.asm -o ../Build/BootLoader.bin
