#----------------------------------------------------------------------# SparseReg
immutable SparseReg{L <: Loss, P <: Penalty} <: AbstractSparseReg
    β::VecF
    loss::L
    penalty::P
    λ::Float64
    factor::VecF
end
function Base.show(io::IO, o::SparseReg)
    header(io, "SparseReg")
    print_item(io, "β",             o.β)
    print_item(io, "Loss",          o.loss)
    print_item(io, "Penalty",       o.penalty)
    print_item(io, "λ",             o.λ)
    print_item(io, "λ scaling",     o.factor, false)
end

#---------------# Constructors: type-stable with arbitrary number/order of arguments
_d(p) = zeros(p), LinearRegression(), NoPenalty(), 0.1, ones(p)  # defaults
_a(t::Tuple, argu::Loss)      = t[1], argu, t[3], t[4], t[5]     # replace loss
_a(t::Tuple, argu::Penalty)   = t[1], t[2], argu, t[4], t[5]     # replace penalty
_a(t::Tuple, argu::Float64)   = t[1], t[2], t[3], argu, t[5]     # replace λ
_a(t::Tuple, argu::VecF)      = t[1], t[2], t[3], t[4], argu     # replace factor

SparseReg(t::Tuple)                 = SparseReg(t...)
SparseReg(p::Integer)               = SparseReg(_d(p))
SparseReg(p::Integer,a)             = SparseReg(_a(_d(p),a))
SparseReg(p::Integer,a,b)           = SparseReg(_a(_a(_d(p),a),b))
SparseReg(p::Integer,a,b,c)         = SparseReg(_a(_a(_a(_d(p),a),b),c))
SparseReg(p::Integer,a,b,c,d)       = SparseReg(_a(_a(_a(_a(_d(p),a),b),c),d))

#------------------------------------------------------------# SparseReg methods
# scary names so that nobody uses them
predict_from_xβ(l::Loss, xβ::Real) = xβ
predict_from_xβ(l::LogitMarginLoss, xβ::Real) = 1.0 / (1.0 + exp(-xβ))
predict_from_xβ(l::PoissonLoss, xβ::Real) = exp(xβ)

function xβ_to_ŷ!(l::Union{LogitMarginLoss, PoissonLoss}, xβ::AVec)
    for i in eachindex(xβ)
        @inbounds xβ[i] = predict_from_xβ(l, xβ[i])
    end
    xβ
end
xβ_to_ŷ!(l::Loss, xβ::AVec) = xβ;  # no-op if linear predictor == ŷ

# coef, predict, classify
coef(o::SparseReg) = o.β
xβ(o::SparseReg, x::AMat) = x * o.β
xβ(o::SparseReg, x::AVec) = dot(x, o.β)
predict(o::SparseReg, x::AVec) = predict_from_xβ(o.loss, xβ(o, x))
predict(o::SparseReg, x::AMat) = predict_from_xβ.(o.loss, xβ(o, x))
classify{L<:MarginLoss}(o::SparseReg{L}, x::AVec) = sign(xβ(o, x))
classify{L<:MarginLoss}(o::SparseReg{L}, x::AMat) = sign.(xβ(o, x))
