#!/bin/test

if ! docker info >/dev/null 2>&1; 
then echo "Error {TypeERROR}"
exit 1
fi

if ! ping 8.8.8.8 >/dev/ping_null;
