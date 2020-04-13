Kind = "terminating-gateway"
Name = "my-gateway"

Services = [
  {
    Name      = "hello-server"
  },
  {
    Namespace = "international"
    Name      = "*"
  }
]
