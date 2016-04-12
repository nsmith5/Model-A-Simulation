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
    public SimulationBox simbox;
    private TheoryDisplay display;
    private Stack stack;
    private StackSwitcher switcher;

    public Application (int N)
    {
        this.title = "Model A Simulation";              // Title
        this.window_position = WindowPosition.CENTER;   // Position
        this.destroy.connect (Gtk.main_quit);           // Connect exit
        this.set_default_size (N, N);                   // Dim of simulation
        this.set_border_width (12);                     // Make small border

        simbox = new SimulationBox (N);
        display = new TheoryDisplay (
            "file://localhost/home/nsmith/Downloads/Untitled.html");
        stack = new Stack ();
        stack.add_titled (simbox.vbox, "Simulation", "Simulation");
        stack.add_titled (display, "Theory", "Theory");

        switcher = new StackSwitcher ();
        switcher.stack = stack;
        var vbox = new Box (Orientation.VERTICAL, 0);
        var box = new Box (Orientation.HORIZONTAL, 0);
        box.pack_start(switcher, true, false, 0);
        vbox.pack_start (box, true, false, 4);
        vbox.pack_start (stack, true, true, 4);
        vbox.set_homogeneous (false);

        this.add (vbox);
    }
}

void main (string[] args)
{
        Gtk.init (ref args);
        var window = new Application (500);
        window.show_all ();

        var idle = new IdleSource ();
        var draw_timeout = new TimeoutSource (100);

        idle.set_callback( () => {
            window.simbox.time_step ();
            return true;
        });

        draw_timeout.set_callback(() => {
            window.simbox.draw_field ();
            window.queue_draw ();
            return true;
        });

        idle.attach(null);
        draw_timeout.attach(null);

        Gtk.main ();
        return;
}
