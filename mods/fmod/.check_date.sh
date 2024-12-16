#!/usr/bin/env bash
grep $(date -u -I) mod.conf
exit $?
