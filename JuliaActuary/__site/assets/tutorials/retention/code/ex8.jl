# This file was generated, do not modify it. # hide
function retained(pol::Policy)
    if ~isnothing(pol.cessions)
        pol.face - sum(cession.face for cession in pol.cessions)
    else
        pol.face
    end
end