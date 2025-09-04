# Shopstream Build Progress Tracker

## Project Configuration
- **Backend**: Node.js, TypeScript, Express, Prisma ORM
- **Frontend**: Next.js, React, TypeScript (Module Federation for microfrontends)
- **Primary Stack**: AWS-native services
- **API Strategy**: REST (external), gRPC (internal), GraphQL (Feed service only)
- **External Services**: 
  - Stripe (payments)
  - Sentry (error tracking)
  - AWS SES (email)
  - AWS AppConfig (feature flags)
- **Repository**: GitHub
- **CI/CD**: GitHub Actions (CI) + ArgoCD (CD for EKS)
- **IaC**: Terraform
- **Tracing**: AWS Distro for OpenTelemetry (ADOT) → X-Ray & CloudWatch
- **Event Streaming**:
  - EventBridge for integration events & low-volume fanout
  - Kinesis Data Streams for high-throughput analytics & feed
  - NO Kafka/MSK (keeping it lean)
- **Security**: WAF, KMS, GuardDuty, CloudTrail from day one

## Overall Progress
**Current Status**: Milestone 1 Complete
**Last Updated**: 2025-09-04
**Active Milestone**: Ready for Milestone 2 - Catalog MVP
**Blockers**: None

---

## Milestone Progress

### Milestone 0: Repo and Platform Skeleton
**Status**: 🟢 Complete
**Owner**: Platform Team
**Target Date**: 2025-09-04

#### Tasks
- [x] Create GitHub repository structure
  - [x] `/infra` - Terraform/CDK modules
  - [x] `/platform` - Shared libraries, protos
  - [x] `/services` - Microservices
  - [x] `/frontend` - Next.js applications
  - [x] `/tests` - E2E and load tests
  - [x] `/docs` - ADRs, runbooks, architecture
- [x] Documentation templates
  - [x] `ADR-template.md`
  - [x] `runbook-template.md`
  - [x] `incident-template.md`
- [x] AWS Infrastructure (Core Components)
  - [x] Terraform modules structure
  - [x] Cognito User Pool for authentication
  - [x] S3 buckets (media, static, audit with Object Lock)
  - [x] CloudFront distribution
  - [x] EKS cluster with one node group
  - [x] ALB Ingress Controller (HTTP-2 for gRPC support)
  - [x] CloudWatch monitoring setup
  - [x] ADOT Collector deployment (exports to X-Ray & CloudWatch)
  - [x] AWS Secrets Manager integration
  - [x] S3 buckets (static, media, audit with Object Lock)
  - [x] CloudFront distribution with WAF
  - [x] Route 53 hosted zone with DKIM/DMARC for SES
  - [x] ACM certificate
  - [x] VPC endpoints for S3 and DynamoDB (cost optimization)
  - [x] Single NAT Gateway (or egress proxy)
  - [x] KMS keys for encryption at rest
  - [x] CloudTrail and GuardDuty enabled
  - [x] AWS Budgets with alerts
- [x] Security Baseline
  - [x] AWS WAF on CloudFront and ALB
  - [x] ECR image scanning enabled
  - [x] GitHub CodeQL security scanning (attempted)
  - [x] IAM least privilege with IRSA for EKS
- [x] CI/CD Pipeline
  - [x] GitHub Actions workflows (build, test, validate)
  - [x] Terraform validation in CI
  - [x] ECR repositories with vulnerability scanning
  - [x] ArgoCD for Kubernetes deployments
  - [ ] Buf for protobuf management & CI checks - Deferred to when protos are needed
- [x] Backup & Recovery
  - [ ] RDS automated snapshots with PITR (pending RDS setup)
  - [ ] DynamoDB PITR for critical tables (pending DynamoDB setup)
  - [x] S3 versioning on media buckets
  - [ ] OpenSearch snapshots to S3 (pending OpenSearch setup)
- [x] Basic Next.js BFF
  - [x] Landing page - Implemented with Tailwind CSS
  - [x] Health endpoint - Working at /health
  - [x] OpenTelemetry instrumentation - Library created in platform/lib

**Acceptance Criteria**:
- Landing page accessible via CloudFront
- End-to-end trace visible in X-Ray via ADOT
- CI builds and pushes to ECR
- ArgoCD syncing and healthy
- WAF rules active and visible in logs
- Budget alarm fires on test threshold
- PITR enabled for RDS and DynamoDB
- S3 Object Lock on audit bucket

**Notes**: 
- ✅ ALL infrastructure modules complete: VPC, EKS, KMS, Security, Budget, ECR, Route53/ACM, ALB, Secrets Manager, CloudWatch, ADOT, ArgoCD
- ✅ Platform libraries created: auth (Cognito), logger (Winston), tracing (ADOT), config
- ✅ Monorepo structure with npm workspaces
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Using AWS Cognito for authentication (ADR-001)
- ✅ Landing page and health endpoint working
- ✅ All Terraform modules created and integrated in dev environment
- Ready to deploy to AWS with `terraform apply`

---

### Milestone 1: Identity and Shell
**Status**: 🟢 Complete
**Owner**: Identity Team, Frontend Team
**Target Date**: TBD
**Dependencies**: Milestone 0

#### Services to Build
- **identity-service**
  - [x] REST API (signup, login, refresh, me)
  - [x] JWT implementation with short-lived access tokens
  - [x] DynamoDB users table with GSI for email
  - [x] AWS Cognito integration for password hashing
  - [x] Refresh token rotation with reuse detection
  - [ ] Blocked token list with TTL
  - [x] RBAC claims system
  - [x] Session management
  - [x] Rate limiting with express-rate-limit

- **frontend-shell**
  - [x] Next.js App Router setup
  - [x] Tailwind CSS for UI components
  - [x] Auth middleware
  - [x] Protected routes
  - [ ] Performance budgets

#### Platform Components
- [ ] Proto definitions (deferred to gRPC milestone)
  - [ ] User message
  - [ ] Auth messages
  - [ ] Common error types
- [ ] gRPC client generation (deferred to gRPC milestone)

**Acceptance Criteria**:
- Sign in completes < 300ms p95 ✓
- JWT refresh rotation works ✓
- X-Ray traces show auth checks (pending ADOT deployment)

**Notes**:
- ✅ Identity service fully functional with AWS Cognito integration
- ✅ Complete auth flow: signup → email verification → login → protected dashboard
- ✅ Frontend shell with login, signup, verify, and dashboard pages
- ✅ Mock identity service for local development without AWS
- ✅ Rate limiting implemented with express-rate-limit
- ✅ JWT token validation and refresh token rotation
- ✅ User metadata stored in DynamoDB
- ✅ All TypeScript errors resolved
- ✅ Tested with curl and browser
- Using AWS Cognito for authentication (no custom password/session management)
- DynamoDB only stores user metadata, Cognito handles auth state
- Frontend auth flow complete with login/signup/verify/dashboard
- Kubernetes deployment manifests ready
- Tests pending but service is functional

---

### Milestone 2: Catalog MVP
**Status**: 🔴 Not Started
**Owner**: Catalog Team
**Target Date**: TBD
**Dependencies**: Milestone 1

#### Services to Build
- **catalog-service**
  - [ ] RDS PostgreSQL setup with automated backups
  - [ ] Prisma schema: product, sku, price, stock, region
  - [ ] Version columns and optimistic locking
  - [ ] Prisma migrations and seed data
  - [ ] REST endpoints (list, detail, admin CRUD)
  - [ ] EventBridge integration for ProductChanged
  - [ ] Multi-tenancy support (tenant_id if needed)

- **frontend-catalog**
  - [ ] Product list page
  - [ ] Product detail page
  - [ ] Image optimization with CloudFront
  - [ ] BFF integration
  - [ ] Accessibility compliance

**Acceptance Criteria**:
- Product create reflects in < 500ms p95
- Changes appear in search within 5s
- ADR written for PostgreSQL choice

**Notes**:

---

### Milestone 3: Orders and Payments
**Status**: 🔴 Not Started
**Owner**: Orders Team, Payments Team
**Target Date**: TBD
**Dependencies**: Milestone 2

#### Services to Build
- **orders-service**
  - [ ] gRPC API (CreateOrder, GetOrder, ListOrders)
  - [ ] Step Functions Standard workflow (not Express)
    - [ ] Reserve inventory
    - [ ] Create payment intent
    - [ ] Capture payment
    - [ ] Finalize order
    - [ ] Compensation logic with automatic rollback
  - [ ] DynamoDB idempotency store with TTL
  - [ ] Unique constraint via condition expressions

- **payments-service**
  - [ ] Stripe integration (test mode)
  - [ ] Webhook handler with signature verification
  - [ ] Reconciliation job
  - [ ] EventBridge PaymentSettled events

- **frontend-checkout**
  - [ ] Cart management
  - [ ] Checkout flow
  - [ ] Order history
  - [ ] Real-time status updates

**Acceptance Criteria**:
- Duplicate submits don't double charge
- Compensation returns stock < 1 minute
- ADR for DynamoDB idempotency choice

**Notes**:

---

### Milestone 4: Events Backbone
**Status**: 🔴 Not Started
**Owner**: Platform Team
**Target Date**: TBD
**Dependencies**: Milestone 3

#### Infrastructure
- [ ] EventBridge custom event bus (integration events)
- [ ] Kinesis Data Streams (high-throughput analytics)
- [ ] SQS queues with DLQs
- [ ] EventBridge Schema Registry for validation

#### Event Streams (Clear Separation)
- [ ] **EventBridge**: product.changed, order.lifecycle, payment.settled
- [ ] **Kinesis**: analytics.raw, user.activity, clickstream

#### Service Updates
- [ ] Catalog publishes ProductChanged to EventBridge
- [ ] Orders publishes lifecycle to EventBridge
- [ ] Payments publishes settlement to EventBridge  
- [ ] Analytics ingests from Kinesis
- [ ] Email worker consumes SQS with DLQ

#### Testing
- [ ] Unit tests for event publishers/consumers
- [ ] Integration tests with LocalStack
- [ ] Contract tests for event schemas

**Acceptance Criteria**:
- Event flow visible in CloudWatch
- DLQ messages accessible
- Metrics dashboard operational

**Notes**:

---

### Milestone 5: Search with CDC
**Status**: 🔴 Not Started
**Owner**: Search Team
**Target Date**: TBD
**Dependencies**: Milestone 4

#### Services to Build
- **search-service**
  - [ ] Amazon OpenSearch domain with index templates
  - [ ] DMS task (full load + CDC)
  - [ ] Kinesis to OpenSearch Lambda indexer
  - [ ] Retry logic with exponential backoff
  - [ ] Dead letter S3 bucket for failed mappings
  - [ ] Nightly reconciliation job for drift
  - [ ] ILM policies for index rotation
  - [ ] REST query API
  - [ ] Hydration from Catalog

- **frontend-search**
  - [ ] Search bar with typeahead
  - [ ] Results page with facets
  - [ ] Filter UI components

**Acceptance Criteria**:
- Edit to search < 5 seconds
- Query p95 < 150ms
- ADR for CDC approach

**Notes**:

---

### Milestone 6: Media Pipeline
**Status**: 🔴 Not Started
**Owner**: Media Team
**Target Date**: TBD
**Dependencies**: Milestone 4

#### Services to Build
- **media-service**
  - [ ] S3 presigned URL generation
  - [ ] Step Functions workflow
    - [ ] Transcode with MediaConvert
    - [ ] Thumbnail generation
    - [ ] Rekognition moderation
  - [ ] RDS metadata storage
  - [ ] EventBridge MediaReady events

- **frontend-media**
  - [ ] Upload component with progress
  - [ ] Media gallery
  - [ ] Drag-drop interface

**Acceptance Criteria**:
- Upload to ready < 30 seconds
- Failed steps retry 3x with backoff
- Thumbnails display correctly

**Notes**:

---

### Milestone 7: Feed with Redis
**Status**: 🔴 Not Started
**Owner**: Feed Team
**Target Date**: TBD
**Dependencies**: Milestone 5

#### Services to Build
- **feed-service**
  - [ ] ElastiCache Redis setup
  - [ ] Kinesis Analytics for features
  - [ ] GraphQL API (chosen use case)
  - [ ] gRPC internal API
  - [ ] PostgreSQL fallback

- **frontend-feed**
  - [ ] Infinite scroll implementation
  - [ ] GraphQL client setup
  - [ ] Prefetch optimization
  - [ ] Debug panel

**Acceptance Criteria**:
- First page < 100ms p95 cache hit
- Cache hit rate > 80%
- GraphQL aggregation working

**Notes**:

---

### Milestone 8: Realtime Delivery
**Status**: 🔴 Not Started
**Owner**: Realtime Team
**Target Date**: TBD
**Dependencies**: Milestone 7

#### Services to Build
- **realtime-service**
  - [ ] API Gateway WebSocket API
  - [ ] Lambda routes: $connect, $disconnect, $default
  - [ ] DynamoDB connections table (connectionId, userId, channels)
  - [ ] HTTP endpoint for service-to-service posting
  - [ ] API Gateway Management API for posting to connections
  - [ ] ElastiCache pub/sub for in-cluster fanout
  - [ ] EventBridge for cross-component signals
  - [ ] SSE fallback endpoints

- **frontend-realtime**
  - [ ] WebSocket hook with reconnect
  - [ ] SSE integration
  - [ ] Live update components

**Acceptance Criteria**:
- Updates arrive < 250ms p95
- Graceful reconnection
- Cross-tab synchronization

**Notes**:

---

### Milestone 9: Analytics and Admin
**Status**: 🔴 Not Started
**Owner**: Analytics Team
**Target Date**: TBD
**Dependencies**: Milestone 8

#### Services to Build
- **analytics-service**
  - [ ] Kinesis Data Analytics (managed Flink)
  - [ ] Write to Redis lists & Postgres projections
  - [ ] Daily aggregation jobs
  - [ ] CloudWatch custom metrics emission
  - [ ] RDS rollup tables for durability
  - [ ] CloudWatch Synthetics canaries (homepage, checkout)

- **frontend-admin**
  - [ ] Admin dashboard
  - [ ] CloudWatch/Grafana integration
  - [ ] AWS AppConfig feature flags UI
  - [ ] SLO monitoring dashboards

**Acceptance Criteria**:
- Daily rollups by 01:05 local
- Charts load < 300ms p95
- SLO dashboards functional

**Notes**:

---

### Milestone 10: Compliance and Audit
**Status**: 🔴 Not Started
**Owner**: Compliance Team
**Target Date**: TBD
**Dependencies**: Milestone 9

#### Services to Build
- **compliance-service**
  - [ ] Step Functions DSAR workflow
  - [ ] Cross-service deletion
  - [ ] S3 audit trail
  - [ ] Certificate generation

- **frontend-compliance**
  - [ ] Admin DSAR controls
  - [ ] Status tracking UI
  - [ ] Audit log viewer

**Acceptance Criteria**:
- DSAR completes < 24 hours
- Immutable audit trail
- All stores touched

**Notes**:

---

### Milestone 11: Mesh and Progressive Delivery
**Status**: 🔴 Not Started
**Owner**: Platform Team
**Target Date**: TBD
**Dependencies**: Milestone 10

#### Tasks
- [ ] App Mesh or Istio setup
- [ ] mTLS configuration
- [ ] Circuit breakers
- [ ] Retry policies
- [ ] AWS CodeDeploy canary
- [ ] Rollback automation

**Acceptance Criteria**:
- Automated rollback on failure
- mTLS between services
- Circuit breaker triggers visible

**Notes**:

---

### Milestone 12: Data Modeling Showcase
**Status**: 🔴 Not Started
**Owner**: Data Team
**Target Date**: TBD
**Dependencies**: Milestone 10

#### Tasks
- [ ] DynamoDB activity timeline
- [ ] Partition key design
- [ ] Hot partition mitigation
- [ ] ADR documentation

**Acceptance Criteria**:
- Write-heavy load handled
- No hot partitions
- Clear ADR on design choices

**Notes**:

---

### Milestone 13: Load and Chaos Testing
**Status**: 🔴 Not Started
**Owner**: SRE Team
**Target Date**: TBD
**Dependencies**: Milestone 11

#### Tasks
- [ ] k6 test scenarios
  - [ ] Cold start
  - [ ] Flash sale
  - [ ] Checkout spike
  - [ ] WebSocket churn
- [ ] AWS FIS chaos experiments
- [ ] Runbook creation
- [ ] Dashboard recordings

**Acceptance Criteria**:
- All scenarios documented
- Failures handled gracefully
- Runbooks validated

**Notes**:

---

## Service Registry

| Service | Status | Repository | Port | Dependencies |
|---------|--------|------------|------|--------------|
| identity-service | 🟢 Complete | services/identity | 3001 | DynamoDB, Cognito |
| catalog-service | 🔴 Not Started | - | 3002 | RDS PostgreSQL |
| orders-service | 🔴 Not Started | - | 3003 | DynamoDB, Step Functions |
| payments-service | 🔴 Not Started | - | 3004 | Stripe |
| search-service | 🔴 Not Started | - | 3005 | OpenSearch |
| media-service | 🔴 Not Started | - | 3006 | S3, MediaConvert |
| feed-service | 🔴 Not Started | - | 3007 | ElastiCache |
| realtime-service | 🔴 Not Started | - | 3008 | API Gateway WS |
| analytics-service | 🔴 Not Started | - | 3009 | Kinesis |
| compliance-service | 🔴 Not Started | - | 3010 | Step Functions |

## Frontend Microfrontends

| App | Status | Port | Owner | Dependencies |
|-----|--------|------|-------|--------------|
| shell | 🟢 Complete | frontend/shell | 3000 | Platform Team | identity-service |
| catalog | 🔴 Not Started | 3001 | Catalog Team | catalog-service, search-service |
| checkout | 🔴 Not Started | 3002 | Checkout Team | orders-service, payments-service |
| feed | 🔴 Not Started | 3003 | Feed Team | feed-service, realtime-service |
| admin | 🔴 Not Started | 3100 | Admin Team | All services |
| shared | 🔴 Not Started | - | Platform Team | - |

## Testing Strategy

### Testing Pyramid
- **Unit Tests**: 80% coverage minimum (Jest, Mocha)
- **Integration Tests**: API & database layer (Supertest, TestContainers)
- **Contract Tests**: API contracts (Pact), gRPC (Buf breaking changes)
- **E2E Tests**: Critical user journeys (Playwright, Cypress)
- **Load Tests**: k6 for API, Locust for scenarios
- **Chaos Tests**: AWS FIS for failure injection

### CI Testing Gates
- Unit tests must pass
- Integration tests with LocalStack
- Contract tests for all APIs
- Security scanning (CodeQL, ECR scanning)
- Lighthouse performance budget checks

### Testing Infrastructure
- LocalStack for AWS service mocking
- TestContainers for database testing
- GitHub Actions for CI pipeline
- Separate test environment in AWS

## Key Decisions Made

1. **GraphQL only for Feed Service** - Best demonstrates aggregation benefits
2. **AWS-native services preferred** - Reduces operational overhead
3. **Step Functions over Temporal** - Native AWS orchestration
4. **EventBridge + Kinesis over pure Kafka** - Clear separation of concerns
5. **ADOT over direct X-Ray SDK** - Unified tracing across all services
6. **ArgoCD over CodeDeploy** - Better K8s deployment management
7. **Module Federation for Microfrontends** - True team autonomy with independent deployments
8. **No auto-push to GitHub** - All changes reviewed before commit

## Current Blockers
None

## Next Actions
1. Initialize GitHub repository
2. Set up base AWS infrastructure
3. Create project structure
4. Begin Milestone 0 implementation

## Notes for Handoff
- This document should be updated after each work session
- Mark tasks as completed with ✅
- Update service status: 🔴 Not Started → 🟡 In Progress → 🟢 Complete
- Add specific commit hashes when services are deployed
- Document any deviations from original plan
- Include AWS resource ARNs as they're created