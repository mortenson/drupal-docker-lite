#!/bin/bash
cd "${0%/*}"

read -p "This will permanently remove unused Docker volumes and images. Are you sure? [y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

echo "Pruning volumes..."
docker volume prune --force

echo

echo "Pruning images..."
docker image prune --force

echo
echo "Pruned!"
