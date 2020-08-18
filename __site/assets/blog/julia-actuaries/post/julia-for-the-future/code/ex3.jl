# This file was generated, do not modify it. # hide
function retained(l::Life)
  sum(retained(policy) for policy in life.policies)
end