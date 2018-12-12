#!/bin/sh

git filter-branch --force --index-filter "git rm -rf --cached --ignore-unmatch $@" --tag-name-filter cat -- --all
