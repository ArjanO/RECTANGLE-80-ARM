CC=cc

all: genroundkey rectange

rectange: rectange.o binaryutil.o main.o
	$(CC) -o $@ $^

genroundkey: rectange.o binaryutil.o genroundkey.o
	$(CC) -o $@ $^

main.o: main.c
	$(CC) -c -o $@ $<

rectange.o: rectange.c
	$(CC) -c -o $@ $<

genroundkey.o: genroundkey.c
	$(CC) -c -o $@ $<

binaryutil.o: binaryutil.c
	$(CC) -c -o $@ $<

clean:
	rm -f *.o genroundkey rectange
