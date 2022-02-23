#!/bin/sh
set -xv
{ ls mierda || exit 1; } | head -1
