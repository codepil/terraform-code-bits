locals {
  iam_additive_pairs = flatten([
    for role in keys(var.iam_role_members) : [
      for member in lookup(var.iam_role_members, role, []) :
      { role = role, member = member }
    ]
  ])
  iam_additive = {
    for pair in local.iam_additive_pairs :
    "${pair.role}-${pair.member}" => pair
  }
}