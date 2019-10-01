CC = gcc
CFLAGS = -O2
CFLAGS_OMP = -fopenmp

FF = gfortran
FFLAGS = -O2

all: stream_f.exe stream_c.exe stream.omp.exe

stream_f.exe: stream.f mysecond.o
	$(CC) $(CFLAGS) -c mysecond.c
	$(FF) $(FFLAGS) -c stream.f
	$(FF) $(FFLAGS) stream.o mysecond.o -o stream_f.exe

stream_c.exe: stream.c
	$(CC) $(CFLAGS) stream.c -o stream_c.exe

stream.omp.exe: stream.c
	$(CC) $(CFLAGS) $(CFLAGS_OMP) stream.c -o stream.omp.exe

clean:
	rm -f *.exe *.o

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xCORE-AVX2 -ffreestanding -qopenmp -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.icc
