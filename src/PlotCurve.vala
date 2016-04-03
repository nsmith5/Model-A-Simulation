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
using Gdk;
using Cairo;

public class PlotCurve : DrawingArea
{
    private double[] data;
    private int N;

    public PlotCurve (int N, double[] Data)
    {
        data = new double[N];
        data = Data;
        this.N = N;
    }

    public override bool draw (Cairo.Context ctx)
    {
        int width = get_allocated_width();
        int height = get_allocated_height();

        double height_scale = (double) height/3.0/2.0;
        double width_scale = (double) width/N;

        ctx.set_source_rgba(0.0, 0.0, 0.0, 0.8);
        ctx.move_to(0, 3*height/4 - data[0]*height_scale);
        for (int i = 0; i<N; i++)
        {
            ctx.line_to (i*width_scale,3*height/4 - data[i]*height_scale);
            ctx.move_to (i*width_scale,3*height/4 - data[i]*height_scale);
        }
        ctx.stroke();
        ctx.set_source_rgba (1.0, 0.0, 0.0, 0.5);
        ctx.move_to (0, 3*height/4);
        ctx.line_to (width, 3*height/4);
        ctx.stroke();
        return false;
    }

    public new void set_data(double[] input_data)
    {
        data = input_data;
        queue_draw();
        return;
    }

}
