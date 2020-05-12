# Terminating Gateways in Consul Connect

## Goals
- Represent two backend services (`hello-server` and `world-server`) with a terminating gateway
- Use intentions to allow connection from a client in the mesh to backend services outside the mesh
- Migrate `world-server` to the service mesh with traffic splitting
- Upgrade `hello-server` to require mTLS and re-configure terminating-gateway with certificates

## Prerequisites
- consul git repo
- envoy in PATH

## Instructions
### Setup
* Build `consul` from master then start a Consul server in dev mode with Connect enabled.

`$ make dev` (and ensure binary is in PATH)

`$ consul agent -dev -log-level trace`

* Register and start the gateway proxy

`$ curl -X PUT -d @consul.d/services/my-gateway.json \
    "http://localhost:8500/v1/agent/service/register"`

`$ consul connect envoy -gateway=terminating -admin-bind=localhost:19001 -- -l trace`

**Note**: We register the gateway separately in order to add a tag to it. For traffic splitting to work the tags/meta must be present on the gateway itself rather than the linked service. I'm thining of a solution for this, but don't have one ready yet. Also, the CLI does support auto-registration, as with Mesh Gateways. 

* Configure the gateway

`$ consul config write consul.d/config-entries/my-gateway.hcl`

* Create default deny intention

`$ consul intention create -deny "*" "*"`

* Register the services.

`$ curl -X PUT -d @consul.d/services/hello-server.json \
    "http://localhost:8500/v1/agent/service/register"`
    
`$ curl -X PUT -d @consul.d/services/world-server-legacy.json \
    "http://localhost:8500/v1/agent/service/register"`

`$ curl -X PUT -d @consul.d/services/client.json \
    "http://localhost:8500/v1/agent/service/register"`

or

`./register-services.sh`

* Start the Envoy sidecar for the client.

`$ consul connect envoy -sidecar-for hello-client -- -l trace`

* Build then start the servers.

`$ make`

`$ hello-server/bin/hello`

`$ world-server-legacy/bin/world`

* Run the client

`$ hello-world-client/bin/client -loop=false`

There should be an error, due to the lack of intentions allowing the connection.

* Create intentions that allow the connection:

`$ consul intention create hello-client hello-server`

`$ consul intention create hello-client world-server`

Expected output is: `Hello ...world`

Traffic flows through client's sidecar and terminating gateway to both backing services.

### L7 Routing: Traffic splitting for world-server

* Set up http service default and service resolver

`$ consul config write consul.d/config-entries/world-defaults.hcl`

`$ consul config write consul.d/config-entries/world-resolver.hcl`

* Register then start cloud version of `world-server`:

`$ curl -X PUT -d @consul.d/services/world-server.json \
    "http://localhost:8500/v1/agent/service/register"`

`$ world-server/bin/world`

`$ consul connect envoy -sidecar-for world-server-v1 -admin-bind localhost:19002 -- -l trace` 

* Enable traffic splitting

`$ consul config write consul.d/config-entries/world-splitter.hcl`

Expected output is split between: `Hello ...world` and `Hello World`

Traffic is split between terminating gateway and cloud world-server's sidecar.

* Dial split up to 100/0

`$ consul config write consul.d/config-entries/world-splitter-100.hcl`

Expected output is: `Hello World`

### TLS Origination for hello-server

* Re-register the service with the new port (8443):

`$ curl -X PUT -d @consul.d/services/hello-server-tls.json \
    "http://localhost:8500/v1/agent/service/register"`

* Restart `hello-server` with mTLS enabled:

`$ hello-server/bin/hello -mtls -addr="localhost:8443"`

* Add full TLS config to the gateway

`$ consul config write consul.d/config-entries/my-gateway-mtls.hcl`

Running the client app should work as expected.

Note that the client makes HTTP requests and Envoy upgrades them to HTTPS.
