# This file was generated, do not modify it. # hide
# define retention
function retained(pol::Policy)
  pol.face - sum(cession.ceded for cession in pol.cessions)
end