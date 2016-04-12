all:
	valac --pkg gsl --pkg gtk+-3.0 --pkg cairo --pkg webkit2gtk-4.0 \
	./src/TheoryDisplay.vala \
	./src/SimulationWidget.vala \
	./src/Simulation.vala \
	./src/PlotImage.vala \
	./src/MainWindow.vala \
	./src/PlotCurve.vala \
	 -o 'Model A Simulation'

clean:
	rm 'Model A Simulation'
