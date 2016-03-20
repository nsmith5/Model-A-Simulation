all:
	valac --pkg gsl --pkg gtk+-3.0 --pkg cairo ./src/hello.vala

clean:
	rm hello
