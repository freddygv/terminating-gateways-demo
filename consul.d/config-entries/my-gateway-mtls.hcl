Kind = "terminating-gateway"
Name = "my-gateway"

Services = [
  {
    Name      = "hello-server"
    CAFile    = "certs/ca-chain.cert.pem"
	CertFile  = "certs/localhost.cert.pem"
	KeyFile   = "certs/localhost.key.pem"
  },
  {
    Name      = "world-server"
  }
]
