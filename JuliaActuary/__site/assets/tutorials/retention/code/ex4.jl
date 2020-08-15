# This file was generated, do not modify it. # hide
struct Life
    id
    name
    policies
    sex
    risk
    smoke
    birthdate
end

struct Policy
    id
    is_joint
    face
    issue_date
    cessions
end

struct Cession
    pol_id
    face
    company
end