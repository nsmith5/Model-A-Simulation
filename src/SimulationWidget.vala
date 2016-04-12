/* Copyright 2016 Nathan Smith
 *
 * This file is part of Model A Simulation.
 *
 * Model A Simulation is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * Model A Simulation is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with Model A Simulation. If not, see http://www.gnu.org/licenses/.
 */

using Gtk;

public class SimulationBox
{
    private Scale r_slider;         // r adjustment value
    private Scale T_slider;         // Noise adjustment value
    private Scale W_slider;         // Interface energy scale

    private PlotImage plotarea;     // Plotting area for Simulation
    //private PlotCurve plotter;      // Correlation function plotter
    private Simulation simulation;  // Simulation Object

    public Box vbox {get; set;}

    public SimulationBox (int N)
    {
        simulation = new Simulation (N);
        //plotter = new PlotCurve (N>>1, simulation.calculate_correlation());
        plotarea = new PlotImage (N, N);

        pack_box();
        connect_sliders ();
        draw_field ();
    }

    public void time_step ()
    {
        simulation.time_step ();
    }

    public void draw_field ()
    {
        plotarea.update_data (simulation.get_field ());
    }

    private void pack_box ()
    {
        this.vbox = new Gtk.Box (Orientation.VERTICAL, 0);
        var rbox = make_slider ("r", -1, 1, 0.01, out r_slider);
        var noisebox = make_slider ("\u03BE", 0, 5, 0.01, out T_slider);
        var wbox = make_slider ("W", 0.0, 2.0, 0.01, out W_slider);

        vbox.homogeneous = false;
        vbox.pack_start (plotarea, true, true, 2);
	    vbox.pack_start (rbox, false, false, 6);
        vbox.pack_start (noisebox, false, false, 2);
        vbox.pack_start (wbox, false, false, 2);

        //vbox.pack_start (plotter, true, true, 14);
    }

    private Box make_slider (string label, double min,
                             double max, double step,
                             out Scale s)
    {
        s = new Scale.with_range (Orientation.HORIZONTAL, min, max, step);
        var l = new Label (label);
        s.set_value_pos (PositionType.LEFT);
        s.adjustment.value = min;

        var box = new Box (Orientation.HORIZONTAL, 0);
        box.pack_start (l, false, false, 5);
        box.pack_start (s, true, true, 5);
        return box;
    }

    private void connect_sliders ()
    {
        r_slider.adjustment.value_changed.connect(() => {
            simulation.set_r (r_slider.adjustment.value);
        });
        T_slider.adjustment.value_changed.connect(() => {
            simulation.set_T (T_slider.adjustment.value);
        });
        W_slider.adjustment.value_changed.connect(() => {
            simulation.set_W (W_slider.adjustment.value);
        });
        r_slider.adjustment.set_value(0.0);
        W_slider.adjustment.set_value(1.0);
        T_slider.adjustment.set_value(0.1);
    }
}
