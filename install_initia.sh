#!/bin/bash

# Update package list
sudo apt update

# Download Go
wget https://dl.google.com/go/go1.22.3.linux-amd64.tar.gz

# Extract Go
sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz

# Set Go environment variables
echo 'export GOROOT=/usr/local/go' >> ~/.profile
echo 'export GOPATH=$HOME/go' >> ~/.profile
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.profile
source ~/.profile

# Check Go version
go_version=$(go version)
echo "Go version: $go_version"
if [[ "$go_version" < "go version go1.21" ]]; then
  echo "Go version is below 1.21, installation failed."
  exit 1
fi

# Install Make
sudo apt update && sudo apt install -y make

# Check Make version
make_version=$(make --version | head -n 1)
echo "Make version: $make_version"
if [[ "$make_version" < "GNU Make 3.8" ]]; then
  echo "Make version is below 3.8, installation failed."
  exit 1
fi

# Clone Initia repository
git clone https://github.com/initia-labs/initia
cd initia

# Checkout the specified version
git checkout v0.2.12

# Install Initia
make install

# Check Initia version
initiad_version=$(initiad version)
echo "Initia version: $initiad_version"

echo "Installation complete."
