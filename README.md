# Terminating Gateways in Consul Connect

## Prerequisites
- consul repo
- envoy

## Instructions
### Panes
1. Hello server
2. World server
3. Client
4. Consul
5. Client sidecar
6. Gateway

### OSS Setup
* Build `consul` from master then start a Consul server in dev mode with Connect enabled.
`$ make dev'`
`$ consul agent -dev -hcl 'connect = { enabled = true }'`

* Register and start the gateway proxy

`$ consul connect envoy -register -gateway=terminating -service=my-gateway -admin-bind=localhost:19001 -- -l trace`\

* Configure the gateway

`$ consul config write consul.d/my-gateway.hcl`

* Create default deny intention and then service-specific intentions that allow the connection

`$ consul intention create -deny "*" "*"`
`$ consul intention create hello-client hello-server`
`$ consul intention create hello-client world-server`

* Register the servers.

`$ curl -X PUT -d @consul.d/hello-server.json \
    "http://localhost:8500/v1/agent/service/register"`
    
`$ curl -X PUT -d @consul.d/world-server.json \
    "http://localhost:8500/v1/agent/service/register"`

`$ curl -X PUT -d @consul.d/client.json \
    "http://localhost:8500/v1/agent/service/register"`

* Start the Envoy sidecar for the client.
`$ consul connect envoy -sidecar-for hello-client -- -l trace`

* Build then start the client and servers.

`$ make`
`$ hello-server/bin/hello`
`$ world-server/bin/world`
`$ hello-world-client/bin/client`

### Ent Setup (Once OSS has been merged into Enterprise)
* Build `consul-enterprise` from master then start a Consul server in dev mode with Connect enabled

`$ make dev-build GOTAGS='consulent'`
`$ consul agent -dev -hcl 'connect = { enabled = true }'`

* Create the `international` namespace
 
 `$ curl  -X PUT -d '{"Name": "international"}' http://localhost:8500/v1/namespace`

* Register and start the gateway proxy

`$ consul connect envoy -register -gateway=terminating -service=my-gateway -admin-bind=localhost:19001 -- -l trace`\

* Configure the gateway

`$ consul config write consul.d/my-gateway-ent.hcl`

* Create default deny intention and then service-specific intentions that allow the connection

`$ consul intention create -deny "*" "*"`
`$ consul intention create hello-client hello-server`
`$ consul intention create hello-client international/world-server`

* Register the servers.

`$ curl -X PUT -d @consul.d/hello-server.json \
    "http://localhost:8500/v1/agent/service/register"`
    
`$ curl -X PUT -d @consul.d/world-server.json \
    "http://localhost:8500/v1/agent/service/register?ns=international"`

`$ curl -X PUT -d @consul.d/client-ent.json \
    "http://localhost:8500/v1/agent/service/register"`

* Start the Envoy sidecar for the client.
`$ consul connect envoy -sidecar-for hello-client -- -l trace`

* Build then start the client and servers.

`$ make`
`$ hello-server/bin/hello`
`$ world-server/bin/world`
`$ hello-world-client/bin/client`