#!/bin/bash

# exit immediately if rustup is already in $PATH
type rustup >/dev/null 2>&1 && exit

# install rustup without a toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y

# install the minimal toolchain we want
rustup toolchain install stable --profile minimal --component rustc
