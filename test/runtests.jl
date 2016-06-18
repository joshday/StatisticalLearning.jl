module SparseRegressionTests
using SparseRegression; sp = SparseRegression
if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end


info("Show methods")
for obj in [
        NoPenalty(), LassoPenalty(), RidgePenalty(), ElasticNetPenalty(),
        LinearRegression(), L1Regression(), LogisticRegression(), PoissonRegression(),
        QuantileRegression(.5), HuberRegression(3), Fista(), Sweep()
    ]
    show(obj); println()
end
sp.print_header(STDOUT, "print header")
println()

info("Unit Tests")
include("testfiles/penalty_test.jl")
include("testfiles/model_test.jl")
include("testfiles/sanity_test.jl")
include("testfiles/algorithm_test.jl")
end
