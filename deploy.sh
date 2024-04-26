#!/bin/bash
set -e

packer build -var-file=environment/env_vars.json template/ec2.json
