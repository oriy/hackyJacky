#!/usr/bin/env bash

hg log | grep user: | sort | uniq | sed 's/user: *//'
