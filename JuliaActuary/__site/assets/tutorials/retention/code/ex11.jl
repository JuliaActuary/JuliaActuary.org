# This file was generated, do not modify it. # hide
function retention_limit(life::Life)
    first_issue_date = minimum(pol.issue_date for pol in life.policies)
    issue_age = length(life.birthdate:Year(1):first_issue_date) - 1 # Count of Years between the two dates minus 1

    if any(pol.is_joint for pol in life.policies)  # if any of the policies are joint
        if issue_age > 60
            return 8.0e5  # scientific notation
        else
            return 1_000_000.0 # the underscores are just for readability
        end
    else # not joint
        if issue_age > 60
            return 4.0e5
        else
            return 7.5e5
        end
    end
end