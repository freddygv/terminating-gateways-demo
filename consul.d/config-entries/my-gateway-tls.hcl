Kind = "terminating-gateway"
Name = "my-gateway"

Services = [
  {
    Name      = "hello-server"
    CAFile    = "certs/ca-chain.cert.pem"
  },
  {
    Name      = "world-server"
  }
]
