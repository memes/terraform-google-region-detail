#
# Module under test outputs
#
output "results_json" {
  value = jsonencode(module.test.results)
}

output "expected_json" {
  value = jsonencode(var.expected)
}
