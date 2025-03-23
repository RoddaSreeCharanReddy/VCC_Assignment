#!/bin/bash

sudo apt update && sudo apt install -y stress

stress --cpu 4 --timeout 300
