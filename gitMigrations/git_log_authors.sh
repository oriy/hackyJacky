#!/usr/bin/env bash

git log | grep Author: | sort | uniq | sed 's/Author: *//'
