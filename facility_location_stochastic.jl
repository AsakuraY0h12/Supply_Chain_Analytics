module facility_location

using JuMP
using Cbc

function solve_facility_location()

    #------
    # DATA
    #------

    n = 10; # number of potential facility locations
    m = 10; # number of customers
    ns = 11; # number of scenarios

    f = [546264 -14311 380910 151376 503871 -12717 570937 446258 249868 195733 ];

    h = [
        52500	63000	52500	52500	52500	52500	52500	52500	52500	52500	52500
        233520	233520	280224	233520	233520	233520	233520	233520	233520	233520	233520
        2160	2160	2160	2592	2160	2160	2160	2160	2160	2160	2160
        30340	30340	30340	30340	36408	30340	30340	30340	30340	30340	30340
        150490	150490	150490	150490	150490	180588	150490	150490	150490	150490	150490
        9690	9690	9690	9690	9690	9690	11628	9690	9690	9690	9690
        12320	12320	12320	12320	12320	12320	12320	14784	12320	12320	12320
        51700	51700	51700	51700	51700	51700	51700	51700	62040	51700	51700
        24780	24780	24780	24780	24780	24780	24780	24780	24780	29736	24780
        65436	65436	65436	65436	65436	65436	65436	65436	65436	65436	78523.2
    ];

    q = [0.5	0.05	0.05	0.05	0.05	0.05	0.05	0.05	0.05	0.05	0.05]

    c = [
        1.22	7.26	6.18	6.1	5.86	4.72	5.54	6.26	5.78	5.98
        7.26	1.74	6.3	5.28	5.4	4.3	3.98	5.5	5.08	4.58
        6.18	6.3	1.22	3.8	3.74	13.16	3.82	19.38	4.02	4.66
        6.1	5.28	3.8	1.29	9.62	4.32	4.72	7.68	6.72	5.52
        5.86	5.4	3.74	9.62	1.09	6.12	5.54	5.32	5.52	5.12
        4.72	4.3	13.16	4.32	6.12	1.61	3.86	3.9	4.34	3.92
        5.54	3.98	3.82	4.72	5.54	3.86	1.88	4.28	4.04	4.16
        6.26	5.5	19.38	7.68	5.32	3.9	4.28	1.78	4.6	5.08
        5.78	5.08	4.02	6.72	5.52	4.34	4.04	4.6	1.56	3.92
        5.98	4.58	4.66	5.52	5.12	3.92	4.16	5.08	3.92	1.09
    ];

    #------
    # MODEL
    #------

    model = Model(Cbc.Optimizer);

    @variable(model, x[1:n] >= 0, Bin);
    @variable(model, y[1:n,1:m,1:ns] >= 0);

    @objective(model, Min, sum( f[j]*x[j] for j in 1:n)
        + sum(
            sum(
                sum(
                    q[s]*h[i,s]*c[i,j]*y[i,j,s]
                for j in 1:n)
            for i = 1:m)
        for s = 1:ns)
    );

    @constraint(model,[i = 1:m, s = 1:ns], sum(y[i,j,s] for j in 1:n) == 1);
    @constraint(model,[i = 1:m, j = 1:n, s = 1:ns], y[i,j,s] <= x[j]);

    #-------
    # SOLVE
    #-------

    optimize!(model)

    println();
    for j = 1:n
        if (value(x[j]) == 1)
            println("facility ",j);
        end
    end

end

solve_facility_location();

end
