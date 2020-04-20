#!/bin/bash

consul intention create -deny "*" "*"
consul intention create hello-client hello-server
consul intention create hello-client world-server