import pandas as pd
import numpy as np
# from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor

from pyoperon.sklearn import SymbolicRegressor
import pyoperon as Operon

import random, time, sys, os #, json
import gzip
# from scipy import stats

# from pyoperon import R2, MSE, InfixFormatter, FitLeastSquares, Interpreter

# from sympy import parse_expr
# import matplotlib.pyplot as plt
# from copy import deepcopy

def main():
    for file in [ "beer.csv", 
                 # "beerlaw.csv",  
                  "nikuradse_1.csv",  
                  "nikuradse_2.csv", 
                  "supernovae.csv",
                  ]:
        for maxlen in [5, 6, 7, 8, 9, 10, 11, 12, 15]:
            filewithoutext = os.path.splitext(os.path.basename(file))[0]
            targetfolder = f'pyoperon_inv/{filewithoutext}_{maxlen}/'
            if not os.path.exists(targetfolder):
                os.makedirs(targetfolder)
            for rep in range(1,50):
                run_operon_via_bindings(f'../datasets/{file}', maxlen, f'{targetfolder}/run_{rep}.txt.gz')

    
# based on https://github.com/heal-research/pyoperon/blob/d5382c3f63f6dc12e872bb7ccffbf63ddc8e5bb7/example/operon-bindings.py
def run_operon_via_bindings(filename, maxlen, outfilename):
    D = pd.read_csv(filename, sep=',').to_numpy()
    X, y = D[:,:-1], D[:,-1]
    
    # estimate sigma error for DL and model selection
    y_pred = RandomForestRegressor(n_estimators=100).fit(X, y).predict(X)
    sErr = np.sqrt(mean_squared_error(y,  y_pred))

    # initialize a dataset from a numpy array
    # print(X.shape, y.shape)
    A = np.column_stack((X, y))
    ds             = Operon.Dataset(np.asfortranarray(A))

    # define the training and test ranges
    training_range = Operon.Range(0, ds.Rows)
    # test_range     = Operon.Range(ds.Rows, ds.Rows)

    # define the regression target
    target         = ds.Variables[-1] # take the last column in the dataset as the target

    # take all other variables as inputs
    inputs         = [ h for h in ds.VariableHashes if h != target.Hash ]

    # initialize a rng
    rng            = Operon.RomuTrio(random.randint(1, 1000000))

    # initialize a problem object which encapsulates the data, input, target and training/test ranges
    problem        = Operon.Problem(ds)
    problem.TrainingRange = training_range
    problem.TestRange = training_range
    problem.Target = target
    problem.InputHashes = inputs

    # initialize an algorithm configuration
    config         = Operon.GeneticAlgorithmConfig(generations=50, 
                                                   max_evaluations=5000000, 
                                                   local_iterations=100, 
                                                   population_size=1000, 
                                                   pool_size=1000, 
                                                   p_crossover=1.0, 
                                                   p_mutation=0.15, 
                                                   epsilon=1e-6)

    # use tournament selection with a group size of 2 for NSGA2
    comparison     = Operon.CrowdedComparison()
    selector       = Operon.TournamentSelector(comparison)
    selector.TournamentSize = 2

    # initialize the primitive set (add, sub, mul, div, exp, log, sin, cos), constants and variables are implicitly added
    problem.ConfigurePrimitiveSet(Operon.NodeType.Constant | Operon.NodeType.Variable | 
                                  Operon.NodeType.Add | Operon.NodeType.Sub | 
                                  Operon.NodeType.Mul | Operon.NodeType.Div | 
                                  Operon.NodeType.Abs | Operon.NodeType.Pow)
    pset = problem.PrimitiveSet
    pset.SetMinMaxArity(Operon.NodeType.Div, 1, 2)

    # define tree length and depth limits
    minL, maxL     = 1, maxlen
    maxD           = maxlen

    # define a tree creator (responsible for producing trees of given lengths)
    btc            = Operon.BalancedTreeCreator(pset, problem.InputHashes, bias=0.0)
    tree_initializer = Operon.UniformLengthTreeInitializer(btc)
    tree_initializer.ParameterizeDistribution(minL, maxL)
    tree_initializer.MaxDepth = maxD

    # define a coefficient initializer (this will initialize the coefficients in the tree)
    coeff_initializer = Operon.NormalCoefficientInitializer()
    coeff_initializer.ParameterizeDistribution(0, 1)

    # define several kinds of mutation
    mut_onepoint   = Operon.NormalOnePointMutation()
    mut_changeVar  = Operon.ChangeVariableMutation(inputs)
    mut_changeFunc = Operon.ChangeFunctionMutation(pset)
    mut_replace    = Operon.ReplaceSubtreeMutation(btc, coeff_initializer, maxD, maxL)

    # use a multi-mutation operator to apply them at random
    mutation       = Operon.MultiMutation()
    mutation.Add(mut_onepoint, 1)
    mutation.Add(mut_changeVar, 1)
    mutation.Add(mut_changeFunc, 1)
    mutation.Add(mut_replace, 1)

    # define crossover
    crossover_internal_probability = 0.9 # probability to pick an internal node as a cut point
    crossover      = Operon.SubtreeCrossover(crossover_internal_probability, maxD, maxL)

    # define fitness evaluation
    dtable         = Operon.DispatchTable()
    error_metric   = Operon.MSE()
    mseevaluator   = Operon.Evaluator(problem, dtable, error_metric, False) # initialize evaluator, use linear scaling = False
    lenevaluator   = Operon.LengthEvaluator(problem) # initialize evaluator, use linear scaling = False
    evaluator      = Operon.MultiEvaluator(problem)
    evaluator.Add(mseevaluator)
    evaluator.Add(lenevaluator)
    evaluator.Budget = config.Evaluations # computational budget

    optimizer      = Operon.LMOptimizer(dtable, problem, max_iter=config.Iterations)
    local_search   = Operon.CoefficientOptimizer(optimizer)

    # define how new offspring are created
    generator      = Operon.BasicOffspringGenerator(evaluator, crossover, mutation, selector, selector, local_search)

    # define how the offspring are merged back into the population - here we replace the worst parents with the best offspring
    reinserter     = Operon.KeepBestReinserter(comparison)
    sorter         = Operon.RankSorter()
    gp             = Operon.NSGA2Algorithm(config, problem, tree_initializer, coeff_initializer, generator, reinserter, sorter)

    # report some progress
    #gen = 0
    #max_ticks = 50
    #interval = 1 if config.Generations < max_ticks else int(np.round(config.Generations / max_ticks, 0))
    t0 = time.time()

    with gzip.open(outfilename, 'wt') as f:
        f.write(f'Generation;MSE;Length;AdjustedLenght;Expr;time_sec\n')
        def report():
            for ind in gp.Individuals[0:config.PopulationSize]:
                f.write(f'{gp.Generation};{ind.GetFitness(0)};{ind.Genotype.Length};{adjusted_length(ind.Genotype)};{Operon.InfixFormatter.Format(ind.Genotype, ds, 12)};{time.time()-t0:.2f}\n')
            
            
            #best = gp.BestModel
            #model_string = Operon.InfixFormatter.Format(best.Genotype, ds, 12)
            #print(f'\n{model_string}')
    
            #bestfit = best.GetFitness(0)
            #sys.stdout.write('\r')
            #cursor = int(np.round(evaluator.TotalEvaluations/config.Evaluations * max_ticks))
            #for i in range(cursor):
            #    sys.stdout.write('\u2588')
            #sys.stdout.write(' ' * (max_ticks-cursor))
            #sys.stdout.write(f'{100 * evaluator.TotalEvaluations/config.Evaluations:.1f}%, train quality: {-bestfit:.6f}, elapsed: {time.time()-t0:.2f}s')
            #sys.stdout.flush()
            #gen += 1
    
    
        # run the algorithm
        gp.Run(rng, report)
    # close file


    # get the best solution and print it
    best = gp.BestModel
    model_string = Operon.InfixFormatter.Format(best.Genotype, ds, 6)
    fit = evaluator(rng, gp.BestModel)
    print(f'{filename} sErr: {sErr} best fitness: {fit} expr: {model_string}')
    # print('Time limit:', config.TimeLimit)
    # print('gen=', gp.Generation, '\nfit=', fit)
    # print(f'\n{model_string}')
    
    
    
# count the number of nodes (not available in the pyoperon wrapper yet)
def adjusted_length(model):
        # return sum(3 if x.IsVariable else 1 for x in model.Nodes)
        # This is not 100% correct as it counts 3 nodes for all |x|^y, x^|y|  and |x|^|y|
        return sum(3 if x.IsVariable else 
                   0 if x.Type == Operon.NodeType.Abs and x.Parent > 0 and model.Nodes[x.Parent].Type == Operon.NodeType.Pow
                   else 1 for x in model.Nodes)

    
# not used....

# def run_dataset(datafile, trainrows, maxlen):
#     df = pd.read_csv(datafile, sep=',')
#     X_train = df.iloc[0:trainrows,:-1]
#     y_train = df.iloc[0:trainrows, -1]
#     
#     # estimate sigma error for DL and model selection
#     y_pred = RandomForestRegressor(n_estimators=100).fit(X_train, y_train).predict(X_train)
#     sErr = np.sqrt(mean_squared_error(y_train,  y_pred))
# 
#     print(f'{datafile} {trainrows} sErr: {sErr}')
# 
#     reg = SymbolicRegressor(
#         allowed_symbols= 'add,sub,mul,div,pow,abs,constant,variable',
#         #comparison_factor= 0,
#         #crossover_internal_probability= 0.9,
#         #crossover_probability= 1.0,
#         # epsilon= 1e-05,
#         female_selector= 'tournament',
#         male_selector= 'tournament',
#         tournament_size= 5,
#         generations= 50,
#         initialization_max_depth= maxlen,
#         initialization_max_length= maxlen,
#         initialization_method= "btc",
#         #irregularity_bias= 0.0,
#         optimizer_iterations= 100,
#         optimizer='lm',
#         max_evaluations= 5000000,
#         max_depth= maxlen,
#         max_length= maxlen,
#         mutation_probability= 0.15,
#         objectives= [ 'mse', 'length' ],
#         #offspring_generator = 'basic',
#         pool_size= 1000,
#         population_size= 1000,
#         #random_state= None,
#         #reinserter= "keep-best",
#         #time_limit= 900,
#         uncertainty= [sErr],
#         model_selection_criterion = 'mean_squared_error',
#         # deactivate linear scaling
#         add_model_intercept_term = False,
#         add_model_scale_term=False
#     )
# 
#     # print(X_train.shape, y_train.shape)
# 
#     reg.fit(X_train, y_train)
#     print(reg)
#     
#     res = [(s['objective_values'], s['mean_squared_error'], s['tree']) for s in reg.pareto_front_]
#     for obj, mdl, expr in res:
#         print(obj, reg.get_model_string(expr, 16)) 
# 
# #     # best model using selection criterion
#     m = reg.model_
#     s = reg.get_model_string(m, 10)
#     print(s)



    
main()