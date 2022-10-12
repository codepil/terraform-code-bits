locals {
  static_labels = {
    lifecycle          = "development"
    dataclassification = "dc3-p3"
  }
  labels = merge(var.labels, local.static_labels)
}
