kind = "service-resolver"
name = "world-server"

default_subset = "legacy"

subsets = {
  legacy = {
    filter = "legacy in Service.Tags"
  }
  cloud = {
    filter = "cloud in Service.Tags"
  }
}