all:
	valac --pkg gsl --pkg gtk+-3.0 --pkg cairo ./src/ModelA.vala

clean:
	rm ModelA
