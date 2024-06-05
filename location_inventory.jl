module location_inventory

using JuMP
using Gurobi

function solve_location_inventory()

    #------
    # DATA
    #------

    n = 6; # number of potential facility locations
    m = 25; # number of customers

    f = [378 266 277 316 416 258 ];

    mu = [839	347	118	953	198	981	284	140	189	544	948	266	503	363	170	442	134	612	292	635	691	797	371	280	272 ];
    sigma = [671	208	71	667	119	589	227	70	76	272	474	106	201	145	85	354	54	245	234	381	415	558	148	224	136];

    L = 3;
    K = 850;
    z = 1.64;
    c = 120;
    h = 1.4;

    d = [
        4.59	2.39	2.45	4.48	2.95	6.04
        2.94	1.09	2.82	3.94	2.88	5.39
        2.43	1.21	5.12	5.87	5.11	3.27
        1.92	4.42	6.67	5.7	6.14	6.31
        4.5	5.84	4.85	2.52	4.05	9.65
        5.79	4.89	1.03	2.18	1.1	9.16
        4.99	6.28	9.88	9.68	9.61	4.65
        5.43	2.92	4.5	6.5	5.01	4.82
        1.88	3.53	4.35	3.18	3.73	7.05
        4.87	4.37	1.28	1.2	0.56	8.71
        3.08	3.13	2.36	1.77	1.74	7.37
        3.92	2.2	1.79	3.48	2.07	6.36
        4.04	4.27	2.46	0.67	1.66	8.52
        7.68	5.57	8.16	10.01	8.62	3.9
        4.86	5.07	8.96	9.39	8.89	2.18
        1.21	2.48	4.02	3.51	3.56	6.08
        3.86	3.22	1.34	1.81	0.84	7.56
        3.38	2.43	6.33	7.16	6.37	1.99
        1.27	1.26	4.48	4.75	4.28	4.52
        5.57	5.02	1.51	1.46	1.09	9.35
        4.69	2.22	3.47	5.4	3.93	5.2
        5.36	4.15	7.86	8.99	8.03	0.63
        3.24	5.72	7.17	5.65	6.52	7.97
        4.3	5.17	3.75	1.42	2.95	9.23
        5.58	3.38	2.55	4.89	3.23	6.75
    ];

    #------
    # MODEL
    #------

    model = Model(Gurobi.Optimizer);

    @variable(model, x[1:n] >= 0, Bin);
    @variable(model, y[1:m,1:n] >= 0, Bin);
    @variable(model, t1[1:n] >= 0);
    @variable(model, t2[1:n] >= 0);

    @objective(model, Min,
        sum( f[j]*x[j]
            + sum( mu[i]*(c + d[i,j])*y[i,j] for i = 1:m)
            + sqrt(2*K*h)*t1[j]
            + h*z*sqrt(L)*t2[j]
         for j in 1:n)
    );

    @constraint(model,[i = 1:m], sum(y[i,j] for j in 1:n) == 1);
    @constraint(model,[i = 1:m, j = 1:n], y[i,j] <= x[j]);

    @constraint(model,[j = 1:n], sum(mu[i]*y[i,j]*y[i,j] for i in 1:m) <= t1[j]*t1[j]);
    @constraint(model,[j = 1:n], sum(sigma[i]*sigma[i]*y[i,j]*y[i,j] for i in 1:m) <= t2[j]*t2[j]);

    #-------
    # SOLVE
    #-------

    optimize!(model)

    println();
    for j = 1:n
        if (value(x[j]) == 1)
            print("warehouse ",j," serves customers: ");
            for i = 1:m
                if (value(y[i,j]) == 1)
                    print(i," ");
                end
            end
            println("");
        end
    end

end

solve_location_inventory();

end
