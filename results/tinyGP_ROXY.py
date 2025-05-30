# tiny genetic programming by © moshe sipper, www.moshesipper.com
# modified by fabricio olivetti:
# - supports parameter optimization
# - supports unary functions
# - easier to add new functions with different arity
# - maximum number of nodes during initialization and during cx/mut (we repeat the operator until finding a child that respects the max size)
# - uses numpy instead of list
# - print_expr method that prints as a math expression
# - support to multiple variables
# - support to autodiff
# TODO: two variables, roxy
from copy import deepcopy
import numpy as np
from scipy.optimize import minimize
import pandas as pd
from collections import defaultdict
#import numba
import sys

POP_SIZE        = 100   # population size
MIN_DEPTH       = 2    # minimal initial random tree depth
MAX_DEPTH       = 4    # maximal initial random tree depth
GENERATIONS     = 250  # maximal number of generations to run evolution
TOURNAMENT_SIZE = 2    # size of tournament for tournament selection
XO_RATE         = 1.0  # crossover rate
PROB_MUTATION   = 0.25  # per-node mutation probability
MAX_SIZE        = int(sys.argv[1])
rng = np.random.default_rng()

def add(x, y): return x + y
def sub(x, y): return x - y
def mul(x, y): return x * y
def div(x, y): return x / y
def pow(x, y): return np.abs(x)**y
def log(x): return np.log(x)
def abs(x): return np.abs(x)
def inv(x): return np.reciprocal(x)

## ATTENTION: WE CANNOT USE A FUNCTION WITH A NAME STARTING WITH 'x'
FUNCTIONS = [add, sub, mul, div, pow, inv]
ARITY = defaultdict(int)
ARITY.update({'add' : 2, 'sub' : 2, 'mul' : 2, 'div' : 2, 'pow' : 2, 'log' : 1, 'inv' : 1})
INLINE = {'add' : ' + ', 'sub' : ' - ', 'mul' : ' * ', 'div' : ' / ', 'pow' : '**', 'inv' : '1/'}
TERMINALS = ['x0', 'p']

#derivative = {'log' : lambda x: 1/x, 'exp' : lambda x: np.exp(x), 'abs' : lambda x: x/np.abs(x)}
derivative = {'log' : lambda x: 1/x, 'exp' : lambda x: np.exp(x), 'inv' : lambda x: -1/(x**2)}
def deriveOP(op, l, diffL, r, diffR):
    if op == 'add':
        return diffL + diffR
    elif op == 'sub':
        return diffL - diffR
    elif op == 'mul':
        return diffL * r + diffR * l
    elif op == 'div':
        return (diffL * r - l * diffR) / (r**2)
    elif op == 'pow':
        #return l ** (r-1) * (r * diffL + l * np.log(l) * diffR)
        return np.abs(l) ** r * (diffR * np.log(np.abs(l)) + (r * diffL)/l)

class GPTree:
    def __init__(self, data = None, left = None, right = None, val = None):
        self.data  = data
        self.val   = rng.uniform(-1, 1) if val is None else val
        self.left  = left
        self.right = right

    def node_label(self): # string label
        if (self.data in FUNCTIONS):
            return self.data.__name__
        else:
            return str(self.data)

    def print_expr(self, prefix = "", suffix = ""):
        arity = ARITY[self.node_label()]
        if arity == 2:
            print(prefix, end="")
            if self.node_label() == "pow":
                self.left.print_expr("abs(", ")")
            else:
                self.left.print_expr("(", ")")
            print(f"{INLINE[self.node_label()]}", end="")
            self.right.print_expr("(", ")")
            print(suffix, end="")
        elif arity == 1:
            print(prefix, end="")
            if self.node_label() == "inv":
                self.left.print_expr("1/(", ")")
            else:
                print(f"{self.node_label()}", end="")
                self.left.print_expr("(",")")
            print(suffix, end="")
        else:
            if self.node_label()[0] == 'x':
                print(f"{prefix}{self.node_label()}{suffix}", end="")
            else:
                print(f"{prefix}{self.val}{suffix}", end="")

    def num_params(self):
        if self.data == 'p': return 1
        elif self.node_label()[0] == 'x': return 0
        else:
            c = self.left.num_params()
            if ARITY[self.node_label()] == 2:
                c = c + self.right.num_params()
            return c

    def get_params(self):
        if self.data == 'p': return [self.val]
        elif self.node_label()[0] == 'x': return []
        else:
            c = self.left.get_params()
            if ARITY[self.node_label()] == 2:
                c = c + self.right.get_params()
            return c

    def set_params(self, t):
        if self.data == 'p':
            self.val = t[0]
            return t[1:]
        elif self.node_label()[0] == 'x': return t
        else:
            t = self.left.set_params(t)
            if ARITY[self.node_label()] == 2:
                t= self.right.set_params(t)
            return t

    def compute_tree(self, x, p):
        arity = ARITY[self.node_label()]
        if arity == 2:
            l, p = self.left.compute_tree(x, p)
            r, p = self.right.compute_tree(x, p)
            return self.data(l, r), p
        elif arity == 1:
            l, p = self.left.compute_tree(x, p)
            return self.data(l), p
        elif self.node_label()[0] == 'x':
            if len(x.shape) == 1:
                return x, p
            else:
                return x[int(self.node_label()[1:])], p
        elif self.data == 'p': return (p[0], p[1:])
        else: return (self.data, p)

    def compute_tree_diff(self, x, p): # TODO: autodiff
        arity = ARITY[self.node_label()]
        if arity == 2:
            l, p, diffL = self.left.compute_tree_diff(x, p)
            r, p, diffR = self.right.compute_tree_diff(x, p)
            return self.data(l, r), p, deriveOP(self.node_label(), l, diffL, r, diffR)
        elif arity == 1:
            l, p, diff = self.left.compute_tree_diff(x, p)
            return self.data(l), p, diff * derivative[self.node_label()](l)
        elif self.data[0] == 'x':
            if len(x.shape) == 1:
                return x, p, np.ones(x.shape[0])
            else:
                ix = int(self.node_label()[1:])
                diff = np.zeros(x.shape)
                diff[:, ix] = np.ones(x.shape[0])
                return x[ix], p, diff
        elif self.data == 'p':
            if len(x.shape) == 1:
                return (p[0], p[1:], np.zeros(x.shape[0]))
            else:
                return (p[0], p[1:], np.zeros(x.shape))
        else: return (self.data, p, np.zeros(x.shape))

    def random_tree(self, grow, max_depth, depth = 0, size = 0): # create random tree using either grow or full method
        if (depth < MIN_DEPTH or (depth < max_depth and not grow)) and (size < MAX_SIZE - 3):
            self.data = FUNCTIONS[rng.integers(0, len(FUNCTIONS))]
        elif depth >= max_depth or size >= MAX_SIZE:
            self.data = TERMINALS[rng.integers(0, len(TERMINALS))]
        else: # intermediate depth, grow
            if rng.uniform() > 0.5:
                self.data = TERMINALS[rng.integers(0, len(TERMINALS))]
            else:
                self.data = FUNCTIONS[rng.integers(0, len(FUNCTIONS))]
        if self.data in FUNCTIONS:
            self.left = GPTree()
            self.left.random_tree(grow, max_depth, depth = depth + 1, size = size + 1)
            sz_lft = self.left.size()
            if ARITY[self.node_label()] == 2:
                self.right = GPTree()
                self.right.random_tree(grow, max_depth, depth = depth + 1, size = size + sz_lft + 1)

    def mutation(self):
        if rng.random() < PROB_MUTATION: # mutate at this node
            self.random_tree(grow = True, max_depth = 2)
        elif self.left:
            if rng.random() < 0.5 or not self.right:
                self.left: self.left.mutation()
            elif self.right: self.right.mutation()

    def size(self): # tree size in nodes
        if self.data in TERMINALS: return 1
        l = self.left.size()  if self.left  else 0
        r = self.right.size() if self.right else 0
        return 1 + l + r

    def build_subtree(self): # count is list in order to pass "by reference"
        t = GPTree()
        t.data = self.data
        if self.left:  t.left  = self.left.build_subtree()
        if self.right: t.right = self.right.build_subtree()
        return t

    def scan_tree(self, count, second): # note: count is list, so it's passed "by reference"
        count[0] -= 1
        if count[0] <= 1:
            if not second: # return subtree rooted here
                return self.build_subtree()
            else: # glue subtree here
                self.data  = second.data
                self.left  = second.left
                self.right = second.right
        else:
            ret = None
            if self.left  and count[0] > 1: ret = self.left.scan_tree(count, second)
            if self.right and count[0] > 1: ret = self.right.scan_tree(count, second)
            return ret

    def crossover(self, other): # xo 2 trees at random nodes
        if rng.random() < XO_RATE:
            second = other.scan_tree([rng.integers(1, other.size()+1)], None) # 2nd random subtree
            self.scan_tree([rng.integers(1, self.size()+1)], second) # 2nd subtree "glued" inside 1st tree

# end class GPTree

def init_population(rar): # ramped half-and-half
    pop = []
    fits = []
    for md in range(3, MAX_DEPTH + 1):
        grow = True
        for _ in range(int(POP_SIZE/(MAX_DEPTH - 3 + 1))):
            f = -np.inf
            while f == -np.inf:
                t = GPTree()
                t.random_tree(grow = True, max_depth = md)
                f = fitness(t, rar)
            pop.append(t)
            fits.append(f)
            grow = not grow
    return pop, fits

#@numba.jit(nopython=True)
def negloglike_mnr(xobs, yobs, xerr2, yerr2, f, fprime, sig, mu_gauss, w_gauss):
    N = len(xobs)

    w_gaus2 = np.square(w_gauss)
    s2 = yerr2 + np.square(sig)
    den = np.square(fprime) * w_gaus2 * xerr2 + s2 * (w_gaus2 + xerr2)

    neglogP = 0.5 * np.sum(
          np.log(2 * np.pi)
        + np.log(den)
        + (w_gaus2 * np.square(f - yobs)
        + xerr2 * np.square(fprime * (mu_gauss - xobs) + f - yobs)
        + s2 * np.square(xobs - mu_gauss)) / den
    )
    return neglogP

def optimize(individual, rar):
    t0 = individual.get_params() + list(rng.uniform(-1, 1, 3))

    def fun(theta):
        # 3 additional parameters
        f, leftovers, fprime = individual.compute_tree_diff(rar['gbar'].values, theta)
        f_w = np.log10(np.abs(f))
        fprime_w = fprime / (np.log(10)*f) * rar['gbar'].values * np.log(10)

        return negloglike_mnr(rar['gbar_log'].values, rar['gobs_log'].values, rar['e_gbar_log_2'].values, rar['e_gobs_log_2'].values, f_w, fprime_w, *leftovers)

    #print(t0, fun(t0))
    #sol = minimize(fun, t0, options = {'maxiter' : 10}, method='L-BFGS-B')
    sol = minimize(fun, t0, options = {'maxiter' : 10}) 
    individual.set_params(sol.x)
    #print(sol.x, fun(sol.x))
    return sol.x

def fitness(individual, rar):
    if individual.size() > MAX_SIZE:
        return -np.inf
    t = optimize(individual, rar)

    f, leftovers, fprime = individual.compute_tree_diff(rar['gbar'].values, t)
    f_w = np.log10(np.abs(f))
    fprime_w = fprime / (np.log(10)*f) * rar['gbar'].values * np.log(10)
    neg_nll = -negloglike_mnr(rar['gbar_log'].values, rar['gobs_log'].values, rar['e_gbar_log_2'].values, rar['e_gobs_log_2'].values, f_w, fprime_w, *leftovers)

    if np.isnan(neg_nll):
        return -np.inf
    else:
        return neg_nll

def selection(population, fitnesses): # select one individual using tournament selection
    tournament = [rng.integers(0, len(population))
                  for i in range(TOURNAMENT_SIZE)]
    tournament_fitnesses = [fitnesses[tournament[i]]
                            for i in range(TOURNAMENT_SIZE)
                            ]
    maxfit = max(tournament_fitnesses)
    champions = [tournament[i]
                 for i in range(TOURNAMENT_SIZE)
                 if tournament_fitnesses[i] == maxfit]
    if len(champions) == 1:
        return deepcopy(population[champions[0]])
    else:
        return deepcopy(population[champions[rng.integers(0, len(champions))]])

def evolve(population, fitnesses, gen):
    parent1 = selection(population, fitnesses)
    parent2 = selection(population, fitnesses)
    parent1.crossover(parent2)
    parent1.mutation()

    if parent1.size() > MAX_SIZE:
        return evolve(population, fitnesses, gen)
    return parent1

def report(population, fitnesses, gen):
    for i, ind in enumerate(population):
        print(f"{gen},{i},", end="")
        ind.print_expr()
        print(f",{fitnesses[i]},{ind.size()}")

def main():
    rar = pd.read_csv(sys.argv[2])
    #dataset = rar[['gbar','gobs']].values # [:5,:]
    #errors = rar[['e_gbar', 'e_gobs']].values # [:5,:]
    rar['gbar_log'] = rar['logX']
    rar['gobs_log'] = rar['logY']
    rar['e_gbar_log_2'] = rar['logXErr']
    rar['e_gobs_log_2'] = rar['logYErr']

    population, fitnesses = init_population(rar)
    best_of_run_f = max(fitnesses)
    best_of_run = deepcopy(population[fitnesses.index(max(fitnesses))])
    best_of_run_gen = 0

    print("generation,individual_index,expression,fitness,nodes")

    # go evolution!
    for gen in range(GENERATIONS):
        report(population, fitnesses, gen)
        population = [evolve(population, fitnesses, gen) for _ in range(POP_SIZE)]
        fitnesses = [fitness(individual, rar) for individual in population]
        # elitism implement
        if max(fitnesses) > best_of_run_f:
            best_of_run_f = max(fitnesses)
            best_of_run_gen = gen
            best_of_run = deepcopy(population[fitnesses.index(max(fitnesses))])
        else:
            worst = min(enumerate(fitnesses), key = lambda x: x[1])[0]
            population[worst] = deepcopy(best_of_run)
            fitnesses[worst] = best_of_run_f

    report(population, fitnesses, gen)

if __name__== "__main__":
  main()
