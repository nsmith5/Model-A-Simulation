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

using Gtk;          // Gui Implimentation
using Cairo;        // Drawing from a Pixel Buffer

public class Application : Window
{
    private Scale r_slider;         // r adjustment value
    private Label r_label;          // Label for sliders
    private Scale T_slider;         // Noise adjustment value
    private Label T_label;          // Label for noise value
    private Scale W_slider;         // Interface energy scale
    private Label W_label;          // Label for W
    private PlotImage plotarea;     // Plotting area for Simulation
    private PlotCurve plotter;      // Correlation function plotter
    private Image image;            // Image of equations
    private Simulation simulation;  // Simulation Object

    public Application (int N)
    {
        this.title = "Model A Simulation";              // Title
        this.window_position = WindowPosition.CENTER;   // Position
        this.destroy.connect (Gtk.main_quit);           // Connect exit
        this.set_default_size (N, N);                   // Dim of simulation
        this.set_border_width(10);                      // Make small border

        simulation = new Simulation (N);
        plotter = new PlotCurve (N>>1, simulation.calculate_correlation());
        plotarea = new PlotImage (N, N);
        image = new Gtk.Image.from_file ("./img/math_img.svg");

        var vbox = new Gtk.Box (Orientation.VERTICAL, 0);
        var rbox = make_slider("r", -1, 1, 0.01, out r_slider, out r_label);
        var noisebox = make_slider("\u03BE", 0, 5, 0.01, out T_slider, out T_label);
        var wbox = make_slider("W", 0.0, 2.0, 0.01, out W_slider, out W_label);

        vbox.homogeneous = false;
	    vbox.pack_start (rbox, false, false, 4);
        vbox.pack_start (noisebox, false, false, 4);
        vbox.pack_start (wbox, false, false, 4);
        vbox.pack_start (plotarea, true, true, 14);
        vbox.pack_start (plotter, true, true, 14);
        vbox.pack_start (image, false, false, 4);
        this.add (vbox);

        connect_sliders();
        timestep();
        draw_field();
        do_correlation();
    }

    public void timestep ()
    {
        simulation.time_step ();
    }

    public void draw_field ()
    {
        // Draw the field
        plotarea.update_data (simulation.get_field());
        queue_draw();
    }

    public void do_correlation ()
    {
        // Calcuate and plot correlation
        plotter.set_data (simulation.calculate_correlation ());
        queue_draw();
    }

    private void connect_sliders ()
    {
        /* Connect sliders to simulation adjustments */
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

    private Box make_slider (string label, double min,
                             double max, double step,
                             out Scale s,out Label l)
    {
        /* Make generic slider box */
        s = new Scale.with_range (Orientation.HORIZONTAL, min, max, step);
        l = new Label (label);
        s.set_value_pos (PositionType.LEFT);
        s.adjustment.value = min;

        var box = new Box (Orientation.HORIZONTAL, 0);
        box.pack_start (l, false, false, 5);
        box.pack_start (s, true, true, 5);
        return box;
    }
}

void main (string[] args)
{
        Gtk.init (ref args);
        var window = new Application (500);
        window.show_all ();

        var idle = new IdleSource ();
        var corr_timeout = new TimeoutSource (5000);
        var draw_timeout = new TimeoutSource (100);

        idle.set_callback( () => {
            window.timestep ();
            return true;
        });

        corr_timeout.set_callback( () => {
            window.do_correlation ();
            return true;
        });

        draw_timeout.set_callback(() => {
            window.draw_field ();
            return true;
        });

        idle.attach(null);
        corr_timeout.attach(null);
        draw_timeout.attach(null);

        Gtk.main ();
        return;
}
