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

# Xeon Gold 6154 L3 cache = 24.75 MiB
# STREAM requires total data size to be >= 4x total LLC
# data type is `double` (8 bytes)
# 24.75 MiB * 4 = 99 MiB = 103809024 bytes / 8 b/elem = 12976128 elems < 16M
stream.omp.16M.exe: stream.c
	$(CC) $(CFLAGS) $(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=16000000 stream.c -o stream.omp.16M.exe

# 16M * 12 sockets = 192M
# 192M elem =~ 1.5 GB... multiple arrays --> >2 GB stack --> mcmodel=medium
stream.omp.192M.exe: stream.c
	$(CC) $(CFLAGS) $(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=192000000 -mcmodel=medium stream.c -o stream.omp.192M.exe

stream.omp.AVX512.16M.exe: stream.c
	$(CC) -march=skylake-avx512 -mtune=skylake-avx512 -ffast-math -O3 \
		$(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=16000000 stream.c -o stream.omp.AVX512.16M.exe

stream.omp.AVX512.192M.exe: stream.c
	$(CC) -march=skylake-avx512 -mtune=skylake-avx512 -ffast-math -O3 \
		$(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=192000000 -mcmodel=medium stream.c -o stream.omp.AVX512.192M.exe

stream.omp.16M.icc: stream.c
	icc $(CFLAGS) -qopenmp -DSTREAM_ARRAY_SIZE=16000000 stream.c -o stream.omp.16M.icc

stream.omp.192M.icc: stream.c
	icc $(CFLAGS) -qopenmp -DSTREAM_ARRAY_SIZE=192000000 -mcmodel=medium stream.c -o stream.omp.192M.icc

stream.omp.AVX512.16M.icc: stream.c
	icc -xCORE-AVX512 -qopt-zmm-usage=high -O3 -vec-threshold0 \
		-qopenmp -DSTREAM_ARRAY_SIZE=16000000 stream.c -o stream.omp.AVX512.16M.icc

stream.omp.AVX512.192M.icc: stream.c
	icc -xCORE-AVX512 -qopt-zmm-usage=high -O3 -vec-threshold0 \
		-qopenmp -DSTREAM_ARRAY_SIZE=192000000 -mcmodel=medium stream.c -o stream.omp.AVX512.192M.icc

stream.omp.AVX512.ss.192M.icc: stream.c
	icc -xCORE-AVX512 -qopt-zmm-usage=high -O3 -vec-threshold0 -qopt-streaming-stores=always \
		-qopenmp -DSTREAM_ARRAY_SIZE=192000000 -mcmodel=medium stream.c -o stream.omp.AVX512.ss.192M.icc

# Xeon Platinum 8168 L3 cache = 33 MiB
# 33 * 4 = 132 MiB = 1.384e+8 bytes / 8 b/elem = 17300000 elems < 24M
stream.omp.24M.exe: stream.c
	$(CC) $(CFLAGS) $(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=24000000 stream.c -o stream.omp.24M.exe

# 24M * 12 sockets = 288M
stream.omp.288M.exe: stream.c
	$(CC) $(CFLAGS) $(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=288000000 -mcmodel=medium stream.c -o stream.omp.288M.exe

stream.omp.AVX512.288M.exe: stream.c
	$(CC) -march=skylake-avx512 -mtune=skylake-avx512 -ffast-math -O3 \
		$(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=288000000 -mcmodel=medium stream.c -o stream.omp.AVX512.288M.exe

stream.omp.1024M.exe: stream.c
	$(CC) $(CFLAGS) $(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=1024000000 -mcmodel=medium stream.c -o stream.omp.1024M.exe

stream.omp.AVX512.1024M.exe: stream.c
	$(CC) -march=skylake-avx512 -mtune=skylake-avx512 -ffast-math -O3 \
		$(CFLAGS_OMP) -DSTREAM_ARRAY_SIZE=1024000000 -mcmodel=medium stream.c -o stream.omp.AVX512.1024M.exe

clean:
	rm -f *.exe *.icc *.o

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xCORE-AVX2 -ffreestanding -qopenmp -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.icc
