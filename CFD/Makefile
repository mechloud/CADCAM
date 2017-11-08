# Simple Makefile

# Compiler
CC = g++

# Compiler Flags
CFLAGS = -std=c++14 -O3 -DNDEBUG -I/usr/include/eigen3

euler:	euler.cpp splitTime.cpp compute_edges.cpp n_hat_and_length.cpp
	$(CC) $(CFLAGS) euler.cpp splitTime.cpp compute_edges.cpp n_hat_and_length.cpp -o euler
