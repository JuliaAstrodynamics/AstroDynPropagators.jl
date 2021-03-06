using AstroBase
using Parameters

export Kepler

@with_kw struct Kepler <: Propagator
    iterations::Int = 50
    points::Int = 100
    rtol::Float64 = sqrt(eps())
end

function propagate(p::Kepler, s0::State, Δep, points)
    ep1 = epoch(s0) + Δep
    Δt = value(seconds(Δep))
    if points == :none
        r1, v1 = kepler(grav_param(body(s0)), position(s0), velocity(s0), Δt,
            p.iterations, p.rtol)
        s1 = State(ep1, r1, v1, frame(s0), body(s0))
        Trajectory(s0, s1)
    else
        times = collect(range(zero(Δt), stop=Δt, length=p.points))
        vectors = Vector{Vector}(undef, p.points)
        for (i, t) in enumerate(times)
            r, v = kepler(grav_param(body(s0)), position(s0), velocity(s0), t,
                p.iterations, p.rtol)
            vectors[i] = [r; v]
        end
        s1 = State(ep1, vectors[end][1:3], vectors[end][4:6], frame=frame(s0), body=body(s0))
        Trajectory(s0, s1, times, vectors)
    end
end
