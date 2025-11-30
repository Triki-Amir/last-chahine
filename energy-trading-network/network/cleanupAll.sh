#!/bin/bash

echo "=========================================="
echo "   Complete Network Cleanup"
echo "=========================================="
echo ""

# Stop all running containers
echo "Stopping all containers..."
cd ../../fabric-samples/test-network
./network.sh down

# Remove Docker containers, networks, volumes
echo "Cleaning Docker resources..."
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null
docker volume prune -f
docker network prune -f

# Clean up fabric-samples artifacts
echo "Cleaning fabric-samples artifacts..."
cd ../../fabric-samples/test-network
rm -rf channel-artifacts/*
rm -rf system-genesis-block/*
rm -rf organizations/fabric-ca/org1/msp
rm -rf organizations/fabric-ca/org1/tls-cert.pem
rm -rf organizations/fabric-ca/org1/ca-cert.pem
rm -rf organizations/fabric-ca/org1/IssuerPublicKey
rm -rf organizations/fabric-ca/org1/IssuerRevocationPublicKey
rm -rf organizations/fabric-ca/org1/fabric-ca-server.db
rm -rf organizations/fabric-ca/org2/msp
rm -rf organizations/fabric-ca/org2/tls-cert.pem
rm -rf organizations/fabric-ca/org2/ca-cert.pem
rm -rf organizations/fabric-ca/org2/IssuerPublicKey
rm -rf organizations/fabric-ca/org2/IssuerRevocationPublicKey
rm -rf organizations/fabric-ca/org2/fabric-ca-server.db
rm -rf organizations/fabric-ca/ordererOrg/msp
rm -rf organizations/fabric-ca/ordererOrg/tls-cert.pem
rm -rf organizations/fabric-ca/ordererOrg/ca-cert.pem
rm -rf organizations/fabric-ca/ordererOrg/IssuerPublicKey
rm -rf organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey
rm -rf organizations/fabric-ca/ordererOrg/fabric-ca-server.db
rm -rf organizations/ordererOrganizations
rm -rf organizations/peerOrganizations

# Clean up energy-trading-network artifacts
echo "Cleaning energy-trading-network artifacts..."
cd ../../last-chance/energy-trading-network/network
rm -rf channel-artifacts/*

# Clean up application wallet
echo "Cleaning application wallet..."
cd ../application
rm -rf wallet/*
rm -rf node_modules
rm -f package-lock.json

echo ""
echo "=========================================="
echo "   Cleanup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. cd network"
echo "2. ./startNetwork.sh"
echo "3. ./deployChaincode.sh"
echo "4. cd ../application"
echo "5. npm install"
echo "6. node enrollAdmin.js"
echo "7. npm start"
echo ""#!/bin/bash

# Complete Cleanup Script
# This script stops all networks and removes all containers, volumes, and artifacts

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printMessage() {
  echo -e "${BLUE}"
  echo "=========================================="
  echo "$1"
  echo "=========================================="
  echo -e "${NC}"
}

printSuccess() {
  echo -e "${GREEN}✓ $1${NC}"
}

printMessage "Complete Network Cleanup"

# Stop custom energy network
echo "Stopping custom energy trading network..."
cd "$(dirname "$0")"
docker-compose -f docker-compose.yml down --volumes --remove-orphans 2>/dev/null
printSuccess "Custom network stopped"

# Stop fabric-samples test-network
echo "Stopping fabric-samples test-network..."
cd ../../fabric-samples/test-network
./network.sh down 2>/dev/null
printSuccess "Test network stopped"

# Remove all Hyperledger containers
echo "Removing all Hyperledger containers..."
docker rm -f $(docker ps -aq -f "name=peer*" -f "name=orderer*" -f "name=ca_*" -f "name=cli" -f "name=couchdb") 2>/dev/null
printSuccess "Containers removed"

# Prune volumes
echo "Removing volumes..."
docker volume prune -f
printSuccess "Volumes removed"

# Remove chaincode packages
cd ../../energy-trading-network/network
rm -f *.tar.gz 2>/dev/null
printSuccess "Chaincode packages removed"

# Remove channel artifacts from test-network
cd ../../fabric-samples/test-network
rm -rf channel-artifacts/*.block 2>/dev/null
rm -rf system-genesis-block/*.block 2>/dev/null
printSuccess "Channel artifacts cleaned"

printMessage "Cleanup Complete!"
echo ""
echo "You can now start fresh with:"
echo "  ./startNetwork.sh"
