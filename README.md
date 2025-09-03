# Shopstream

A multi-tenant commerce plus social reference app that shows how to design, build, ship, observe, and scale a real cloud system end to end.

## Overview

Shopstream is an open source learning product that demonstrates production-grade patterns for building modern cloud applications. It combines e-commerce functionality with social features to create a comprehensive reference architecture.

## Key Features

- **Identity & Auth**: JWT-based authentication with RBAC
- **Product Catalog**: Full catalog management with inventory tracking  
- **Search**: CDC-powered search with OpenSearch
- **Orders & Payments**: Orchestrated checkout with compensation flows
- **Media Pipeline**: Upload, transcode, and moderate user content
- **Real-time Feed**: Personalized feeds with WebSocket updates
- **Analytics**: Event streaming and aggregated dashboards
- **Compliance**: GDPR-compliant data deletion and export

## Tech Stack

- **Frontend**: Next.js, React, shadcn/ui
- **APIs**: REST (external), gRPC (internal), GraphQL (feed aggregation)
- **Infrastructure**: AWS (EKS, RDS, DynamoDB, S3, CloudFront, etc.)
- **Orchestration**: AWS Step Functions
- **Events**: EventBridge, Kinesis, SQS
- **Observability**: CloudWatch, X-Ray
- **External**: Stripe (payments), Sentry (errors)

## Documentation

- [Product Requirements](PRD.md)
- [Engineering Plan](Engineering_Doc.md)
- [Build Progress](BUILD_PROGRESS.md)

## Getting Started

Coming soon - setup instructions will be added as services are built.

## Architecture

The system follows a microservices architecture with clear service boundaries:

- Each service owns its data and API contracts
- Event-driven integration for loose coupling
- CDC projections for specialized data stores
- Orchestrated workflows for complex operations

## Project Status

Currently in initial development. See [BUILD_PROGRESS.md](BUILD_PROGRESS.md) for detailed status.

## License

MIT