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

public class PlotArea : DrawingArea{
    private Cairo.Surface surface;      // Drawing surface for Cairo
    private Gdk.Pixbuf buffer;          // Pixel buffer to create surface
    private Gdk.Colorspace cs;          // Colorspace of pixel buffer

    public PlotArea (int width, int height){
        cs = Gdk.Colorspace.RGB;
        uint8[] data = new uint8[3*width*height];
        for (int i = 0; i<3*width*height; i++){
            data[i] = 100;
        }
        buffer = new Gdk.Pixbuf.from_data (data, cs, false, 8, width, height, 3*width);
        set_size_request (width, height);
    }

    public override bool draw (Cairo.Context cr){
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        double buffer_width = (double)buffer.get_width();
        double buffer_height = (double)buffer.get_height();

        surface = Gdk.cairo_surface_create_from_pixbuf (buffer, 1, null);
        cr.scale (width/buffer_width, height/buffer_height);
        cr.set_source_surface (surface, 0, 0);
        cr.paint ();

        return false;
    }

    public void update_data (double[] field){
        int width = buffer.get_width ();
        int height = buffer.get_height ();
        unowned uint8[] pixels = buffer.get_pixels ();
        for (int i = 0; i<width*height ; i++){
            pixels[3*i + 0] = (uint8)((field[i]+ 10)*255.0/20.0);
            pixels[3*i + 1] = (uint8)((field[i]+ 10)*255.0/20.0);
            pixels[3*i + 2] = (uint8)((field[i]+ 10)*255.0/20.0);
        }
        return;
    }
}

