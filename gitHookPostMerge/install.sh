#!/usr/bin/env bash

# place at #githubRepository#/hooks

mkdir -p .git/hooks
cp -R hooks/* .git/hooks/
chmod +x .git/hooks/*
