#!/bin/bash

echo "Installing dependencies..."
npm install

echo "Checking TypeScript compilation..."
npm run typecheck

echo "Running linter..."
npm run lint

echo "Build platform library..."
cd platform/lib && npm run build && cd ../..

echo "✅ All checks passed!"