#!/bin/bash

# A10D Setup Script
# This script sets up the development environment

set -e

echo "========================================"
echo "   A10D Event Ticketing Setup"
echo "========================================"
echo ""

# Check if Foundry is installed
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry not found. Installing Foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc || source ~/.bash_profile || source ~/.zshrc
    foundryup
    echo "✅ Foundry installed successfully!"
else
    echo "✅ Foundry is already installed"
    forge --version
fi

echo ""
echo "Installing dependencies..."

# Initialize git if not already initialized
if [ ! -d .git ]; then
    git init
    echo "✅ Git initialized"
fi

# Install OpenZeppelin contracts
if [ ! -d "lib/openzeppelin-contracts" ]; then
    echo "Installing OpenZeppelin contracts..."
    forge install OpenZeppelin/openzeppelin-contracts
    echo "✅ OpenZeppelin contracts installed"
else
    echo "✅ OpenZeppelin contracts already installed"
fi

# Install Forge Standard Library
if [ ! -d "lib/forge-std" ]; then
    echo "Installing Forge Standard Library..."
    forge install foundry-rs/forge-std 
    echo "✅ Forge Standard Library installed"
else
    echo "✅ Forge Standard Library already installed"
fi

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
    echo "⚠️  Please edit .env with your configuration"
else
    echo "✅ .env file already exists"
fi

echo ""
echo "Compiling contracts..."
forge build

echo ""
echo "Running tests..."
forge test

echo ""
echo "========================================"
echo "   Setup Complete! 🎉"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Edit .env with your private keys and RPC URLs"
echo "2. Get test ETH from faucets"
echo "3. Run: ./deploy.sh"
echo ""
echo "For more information, see:"
echo "- README.md"
echo "- QUICKSTART.md"
echo ""
