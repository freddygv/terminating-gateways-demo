kind = "service-splitter",
name = "world-server"

splits = [
  {
    weight = 50,
    service_subset = "legacy"
  },
  {
    weight = 50,
    service_subset = "cloud"
  }
]