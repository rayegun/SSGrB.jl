#This will capture broadcasts. Inelegant but reasonable.
@capture(ex, f_(a_,b_)) && startswith(string(f), '.')

#This will capture indexing:
@capture(ex, A_[ijk__])

#This will capture indexed assignment
@capture(ex, A_[ijk__] = body_)

# Correct formatting/help from Michael Abbott on Slack