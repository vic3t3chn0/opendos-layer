all:
	cc run.c -o userland

clean: 
		rm -rf *.o userland
		