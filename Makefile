CC = g++
CFLAGS = -g -Wall -Wextra -pedantic -O3 -std=c++11
NASM = nasm -f elf64
INCLUDE_LIB = -lsfml-graphics -lsfml-window -lsfml-system
LINK_LIB =

all: main.o bezier.o
	$(CC) $(CFLAGS) main.o bezier.o -o Bezier $(INCLUDE_LIB)

main.o: main.cpp Makefile
	$(CC) $(CFLAGS) -c main.cpp -o main.o $(INCLUDE_LIB)

bezier.o:	bezier.s Makefile
	$(NASM) bezier.s

clean:
	rm -f *.o
