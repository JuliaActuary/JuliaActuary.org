# This file was generated, do not modify it. # hide
# define retention
function retained(pol::Policy)
  pol.face - sum(cession.ceded for cession in pol.cessions)
end

function retained(l::Life)
  sum(retained(policy) for policy in life.policies)
end