using ExhaustiveSymbolicRegression

function generate_expressions(maxlen, vars)
    
    assertions = Dict{Symbol,ExhaustiveSymbolicRegression.Domain}()
    foreach(vars) do v
        assertions[v] = ExhaustiveSymbolicRegression.domain_common
    end
    dbname = "esr_expressions_nvar$(length(vars))_len$(maxlen).bin"
    ExhaustiveSymbolicRegression.generate_expressions(maxlen,
        [:p, vars...],
        Symbol[:inv], # unary functions
        Symbol[:+, :-, :/, :*, :powabs], # binary funcs
        # varnames are keys in assertions
        assertions, dbname=dbname)
    dbname
end

function fit_expressions(X, y, db::ExhaustiveSymbolicRegression.ExprDatabase, allvars, outfilename)
    data = [X y]
    dim = size(X, 2)
    @show outfilename,size(X)
    likelihood_func(model) = ExhaustiveSymbolicRegression.create_mse_loss(model, data)
    ExhaustiveSymbolicRegression.fit_expressions(db, likelihood_func, allvars, outfilename, dim=dim, distributed=true)
end

function fit_expressions(X, y, exprfilename::String, outfilename)
    data = [X y]
    likelihood_func(model) = ExhaustiveSymbolicRegression.create_mse_loss(model, data)
    ExhaustiveSymbolicRegression.fit_expressions(exprfilename, likelihood_func, skip_rows=0, outfilename=outfilename, distributed=false)
end

######################################
# main entry point
# (with generation of expr database)
######################################
function run_esr_withdb()
    # generate all expressions in two variables and up to given maximum length (has to be done only once)
    maxlen = 10
    maxdim = 2
    allvars = [Symbol("x",i) for i in 1:maxdim] # generate anonymous variables up to maximum dimensionalty that is needed
    
    dbname = generate_expressions(maxlen, allvars)
    # dbname = "esr_expressions_nvar2_len5.bin"
    
    db = ExhaustiveSymbolicRegression.ExprDatabase(dbname)
    for file in [#"beer.csv", "supernovae.csv", 
                # "nikuradse_1.csv", 
                "nikuradse_2.csv"
                #, "beerlaw.csv"
                ]
        X, y, _ = ExhaustiveSymbolicRegression.load_csv_data("../datasets/$file")

        filenamewithoutext = replace(file, ".csv" => "")
        outfolder = "esr/$(filenamewithoutext)_$(maxlen)"
        mkpath(outfolder)
        outfilename = outfolder * "/" * replace(dbname, ".bin" => "_fitted.txt.gz")
    
        fit_expressions(X, y, db, allvars, outfilename)
    end
    ExhaustiveSymbolicRegression.close!(db)
end

#####################################
# main entry point
# (for pre-generated expression files)
#####################################
function run_esr(exprfilenames, datafile)
    X, y, _ = ExhaustiveSymbolicRegression.load_csv_data("../datasets/$datafile")
    filenamewithoutext = replace(datafile, ".csv" => "")
    outfolder = "esr/$(filenamewithoutext)"
    mkpath(outfolder)

    for exprfilename in exprfilenames
        outfilename = outfolder * "/" * replace(basename(exprfilename), ".txt.gz" => "_fitted.txt.gz")
        fit_expressions(X, y, exprfilename, outfilename)
    end
end

# requires pre-generated expression files
# run_esr(["database_nvar1_len13_$len.txt.gz" for len in 1:12], "beer.csv")