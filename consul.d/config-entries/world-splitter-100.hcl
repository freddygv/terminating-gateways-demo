kind = "service-splitter",
name = "world-server"

splits = [
  {
    weight = 0,
    service_subset = "legacy"
  },
  {
    weight = 100,
    service_subset = "cloud"
  }
]