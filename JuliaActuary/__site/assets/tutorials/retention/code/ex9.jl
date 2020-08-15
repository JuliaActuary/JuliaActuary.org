# This file was generated, do not modify it. # hide
function retained(life::Life)
    return sum(retained.(life.policies))
end