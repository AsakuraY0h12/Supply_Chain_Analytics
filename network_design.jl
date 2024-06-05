module facility_location

using JuMP
using Gurobi
using DelimitedFiles

function solve_facility_location()

    #------
    # DATA
    #------

    nI = 88;
    nJ = 88;
    nK = 10;
    nL = 5;

    f = readdlm("dc_fixed.csv");
    c = readdlm("dist_DC_cust.csv",',');
    d = readdlm("dist_plant_DC.csv",',');
    h = readdlm("demand.csv",',');

    g = 1000000;
    v = 2000
    b = 10000

    #------
    # MODEL
    #------

    model = Model(Gurobi.Optimizer);

    @variable(model, x[1:nJ] >= 0, Bin);
    @variable(model, z[1:nK] >= 0, Bin);
    @variable(model, y[1:nI,1:nJ,1:nL] >= 0);
    @variable(model, w[1:nJ,1:nK,1:nL] >= 0);

    @objective(model, Min,
        sum( f[j]*x[j] for j in 1:nJ)
        + sum( g*z[k] for k in 1:nK)
        + sum(
            + sum( sum( 0.5*c[i,j]*y[i,j,l] for i in 1:nI) for j = 1:nJ)
            + sum( sum( 0.25*d[j,k]*w[j,k,l] for j in 1:nJ) for k = 1:nK)
        for l = 1:nL)
    );

    @constraint(model,[i = 1:nI,l = 1:nL], sum(y[i,j,l] for j in 1:nJ) == h[i,l]);
    @constraint(model,[j = 1:nJ], sum(sum(y[i,j,l] for l = 1:nL) for i in 1:nI) <= v*x[j]);
    @constraint(model,[j = 1:nJ,l = 1:nL], sum(w[j,k,l] for k in 1:nK) == sum(y[i,j,l] for i in 1:nI));
    @constraint(model,[k = 1:nK], sum(sum(w[j,k,l] for l = 1:nL) for j in 1:nJ) <= b*z[k]);

    #-------
    # SOLVE
    #-------

    optimize!(model)
    println(objective_value(model))

end

solve_facility_location();

end