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

using Gsl;

public class Simulation
{
    private double[] phi;
    private double[] eta;
    private double[] temp;
    private const double D = 1.0;       // Diffusion Constant
    private const double u = 1.0;       // Quartic coupling
    private const double dx = 1.0;      // Lattice spacing
    private const double dt = 0.1;      // Time step size
    private double r;               // Quadratic coupling
    private double KbT;             // Noise temperature
    private double W;               // Interface energy
    private int N;                  // Number of grid points
    private Gsl.RNG rng;            // Random number generator
    private RNGType* T;             // RNG type

    public Simulation (int N)
    {
        // Initialize parameters and fields
        phi = new double[N*N];
        eta = new double[N*N];
        temp = new double[N*N];
        r = 0.0;
        W = 1.0;
        KbT = 0.1;
        this.N = N;
        // Initialize random number generator
        T = (RNGType*)RNGTypes.default;
        RNG.env_setup ();
        rng = new RNG (T);
        // Fill up fields with initial conditions
        for (int i = 0; i<N*N; i++){
            phi[i] = Randist.gaussian(rng, 0.01);
            eta[i] = 0.0;
        }
        return;
    }

    public void time_step ()
    {
        // Perform one Euler time step
        laplacian ();
        make_noise ();
        nonlinear_term ();
        for (int i = 0; i<N*N; i++){
            phi[i] += temp[i];
        }
    }

    public double[] calculate_correlation ()
    {
        double[] correlation = new double[N>>1];

        return correlation;
    }

    public double[] get_field ()
    {
        return phi;
    }

    public void set_r (double new_r)
    {
        r = new_r;
        return;
    }

    public void set_T (double new_T)
    {
        KbT = new_T;
        return;
    }

    public void set_W (double new_W)
    {
        W = new_W;
        return;
    }

    private void laplacian ()
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

    private void make_noise ()
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
