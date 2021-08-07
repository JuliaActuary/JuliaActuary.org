using Distributed

function estimate_pi(n)
    n > 0 || throw(ArgumentError("number of iterations must be >0, got $n"))
    num_inside = @distributed (+) for i in 1:n
        x, y = rand(), rand()
        Int(x^2 + y^2 <= 1)
    end
    return 4 * num_inside / n
end

pi_estimate = estimate_pi(1_000_000_000)

@info "Finished computation" pi_estimate