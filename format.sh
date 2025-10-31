#!/usr/bin/env bash

gleam format src
deno fmt web/index.html
deno fmt web/main.js
deno fmt web/styles.css
deno fmt web/theme.css
