#!/usr/bin/env bash

http-server -S -C ./secrets/cert.pem -K ./secrets/key.pem -p 8000 web
