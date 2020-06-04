#!/bin/bash

foo=$1

echo "$(tr '[:lower:]' '[:upper:]' <<< ${foo:0:1})${foo:1}"
