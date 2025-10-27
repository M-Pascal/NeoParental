#!/usr/bin/env bash
set -o errexit

# Upgrade pip first
pip install --upgrade pip setuptools wheel

# Install requirements
pip install -r requirements.txt
