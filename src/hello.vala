/*
 *  Simple Application with GtkDrawingArea and Slider
 *
 *  Compile as: >> valac --pkg gtk+-3.0 --pkg cairo hello.vala
 *
 */

using Gtk;          // Gui Implimentation
using Gdk;          // Pixel Buffer
using Cairo;        // Drawing from a Pixel Buffer
using Gsl;          // Gnu scientific library for random numbers

public class PlotArea : DrawingArea
{
    private Cairo.Surface surface;      // Drawing surface for Cairo
    private Gdk.Pixbuf buffer;          // Pixel buffer to create surface
    private Gdk.Colorspace cs;          // Colorspace of pixel buffer

    public PlotArea (int width, int height)
    {
        cs = Gdk.Colorspace.RGB;
        uint8[] data = new uint8[3*width*height];
        for (int i = 0; i<3*width*height; i++)
        {
            data[i] = 100;
        }
        buffer = new Gdk.Pixbuf.from_data(data, cs, false, 8, width, height, 3*width);
        set_size_request(width, height);
    }

    public override bool draw (Cairo.Context cr)
    {
        int width = get_allocated_width();
        int height = get_allocated_height();

        double buffer_width = (double)buffer.get_width();
        double buffer_height = (double)buffer.get_height();

        surface = Gdk.cairo_surface_create_from_pixbuf (buffer, 1, null);
        cr.scale (width/buffer_width, height/buffer_height);
        cr.set_source_surface(surface, 0, 0);
        cr.paint();

        return false;
    }

    public void update_data (double[] field)
    {
        int width = buffer.get_width ();
        int height = buffer.get_height ();
        unowned uint8[] pixels = buffer.get_pixels ();
        for (int i = 0; i<width*height ; i++)
        {
            pixels[3*i + 0] = (uint8)((field[i]+ 10)*255.0/20.0);
            pixels[3*i + 1] = (uint8)((field[i]+ 10)*255.0/20.0);
            pixels[3*i + 2] = (uint8)((field[i]+ 10)*255.0/20.0);
        }
        return;
    }
}

public class Application : Gtk.Window
{
    private Gtk.Scale r_slider;
    private Gtk.Label r_label;
    private Gtk.Scale T_slider;
    private Gtk.Label T_label;
    private PlotArea plot;

    private Simulation simul;

    public Application (int N)
    {
        this.title = "Simulation Box";
        this.window_position = WindowPosition.CENTER;
        this.destroy.connect (Gtk.main_quit);
        this.set_default_size (N, N);

        simul = new Simulation (N);

        plot = new PlotArea (N, N);

        var vbox = new Gtk.Box (Orientation.VERTICAL, 0);
        vbox.homogeneous = false;
        vbox.pack_start (plot, true, true, 0);
        vbox.pack_start (make_r_slider (), false, false, 0);
        vbox.pack_start (make_T_slider (), false, false, 0);
        this.add (vbox);
    }

    private Gtk.Box make_r_slider()
    {
        r_slider = new Gtk.Scale.with_range (Orientation.HORIZONTAL, -1, 1, 0.01);
        r_slider.adjustment.value = 0.0;
        r_slider.adjustment.value_changed.connect ( ()=>{
            simul.set_r(r_slider.adjustment.value);
            simul.time_step();
            plot.update_data(simul.get_field());
            queue_draw();
        });

        r_label = new Label("r");
        var r_box = new Gtk.Box (Orientation.HORIZONTAL, 0);
        r_box.pack_start (r_label, false, false, 5);
        r_box.pack_start (r_slider, true, true, 0);
        return r_box;
    }

    private Box make_T_slider ()
    {
        T_slider = new Gtk.Scale.with_range (Orientation.HORIZONTAL, 0.1, 3, 0.01);
        T_slider.adjustment.value = 0.1;
        T_slider.adjustment.value_changed.connect ( ()=>{
            simul.set_T(T_slider.adjustment.value);
            simul.time_step();
            plot.update_data(simul.get_field());
            queue_draw();
        });

        T_label = new Label("Noise Temperature");
        var T_box = new Gtk.Box (Orientation.HORIZONTAL, 0);
        T_box.pack_start (T_label, false, false, 5);
        T_box.pack_start (T_slider, true, true, 0);
        return T_box;
    }

    public static int main (string[] args)
    {

        Gtk.init (ref args);
        var window = new Application (600);
        window.show_all ();

        Gtk.main ();
        return 0;
    }

}

public class Simulation
{
    /*
     *      Phi^4 Simulation Object
     *  contains field data and time step methods
     */

    private double[] phi;      // Field
    private double[] eta;      // Noise
    private double[] temp;     // temporary array for calculations
    private double D;          // Diffusion constant
    private double r;
    private double u;
    private double KbT;
    private double W;
    private double dx;         // Lattice size
    private double dt;         // Time step size
    private int N;
    private Gsl.RNG rng;       // Random number generator
    private RNGType* T;        // Type of RNG


    public Simulation (int N)
    {
        this.phi = new double[N*N];
        this.eta = new double[N*N];
        this.temp = new double[N*N];
        this.D = 1.0;
        this.dx = 1.0;
        this.dt = 0.1;
        this.r = 0.0;
        this.u = 1.0;
        this.W = 0.5;
        this.KbT = 0.1;
        this.N = N;

        T = (RNGType*)RNGTypes.default;
        RNG.env_setup ();
        rng = new RNG (T);

        for (int i = 0; i<N*N; i++)
        {
            phi[i] = Randist.gaussian(rng, 0.0001);
            eta[i] = 0.0;
        }
        return;
    }

    public void time_step()
    {
        laplacian();                // temp -> nabla^2 (phi)
        make_noise();               // fill eta
        nonlinear_term();
        for (int i = 0; i<N*N; i++)
        {
            phi[i] += temp[i];
        }
        return;
    }

    public double[] get_field()
    {
        return phi;
    }

    public void set_r(double new_r)
    {
        r = new_r;
        return;
    }

    public void set_T(double new_T)
    {
        KbT = new_T;
        return;
    }

    private void laplacian()
    {
        for (int i = 0; i<N; i++)
        {
            for (int j = 0; j<N; j++)
            {
                temp[i*N + j] = -4*phi[i*N+j] + phi[((i+1+N)%N)*N+j]
                            + phi[((i-1+N)%N)*N+j]
                            + phi[i*N+((j-1+N)%N)]
                            + phi[i*N+((j+1+N)%N)];
                temp[i*N + j] /= dx*dx;
            }
        }
        return;
    }

    private void make_noise()
    {
        for (int i = 0; i<N*N; i++)
        {
            eta[i] = Randist.gaussian(rng, KbT);
        }
        return;
    }

    private void nonlinear_term ()
    {
        for (int i = 0; i<N; i++)
        {
            for (int j = 0; j<N; j++)
            {
                temp[i*N+j]  = dt*D*(W*temp[i*N+j] - r*phi[i*N+j] -
                                0.166666*u*phi[i*N+j]*phi[i*N+j]*phi[i*N+j]) +
                                dt*eta[i*N+j];
            }
        }
        return;
    }


}
