# Terminating Gateways in Consul Connect

### Prerequisites
- consul repo
- envoy

### Instructions
#### Setup
* Build from master then start a Consul server in dev mode with Connect enabled.
`$ make dev'`
`$ consul agent -dev -hcl 'connect = { enabled = true }'`

* Register the client and server.

`$ curl -X PUT \
    --data @consul.d/client.json \
    "http://localhost:8500/v1/agent/service/register"`

`$ curl -X PUT \
    --data @consul.d/hello-server.json \
    "http://localhost:8500/v1/agent/service/register"`
    
`$ curl -X PUT \
    --data @consul.d/world-server.json \
    "http://localhost:8500/v1/agent/service/register"`

* Start the Envoy sidecar for the client.
`$ consul connect envoy -sidecar-for hello-client -- -l trace`

* Register and start the gateway proxy

`$ consul connect envoy -register -gateway=terminating -service=my-gateway -admin-bind=localhost:19001 -- -l trace`

* Configure the gateway

`$ consul config write consul.d/my-gateway.hcl`

* Create default deny intention and then service-specific intentions that allow the connection

`$ consul intention create -deny "*" "*"`
`$ consul intention create hello-client hello-server`
`$ consul intention create hello-client world-server`

* Build then start the client and servers.

`$ make`
`$ hello-server/bin/hello`
`$ world-server/bin/world`
`$ hello-world-client/bin/client`