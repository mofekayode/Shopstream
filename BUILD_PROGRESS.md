# Shopstream Build Progress Tracker

## Project Configuration
- **Primary Stack**: AWS-native services
- **API Strategy**: REST (external), gRPC (internal), GraphQL (Feed service only)
- **External Services**: Stripe (payments), Sentry (error tracking)
- **Repository**: GitHub
- **CI/CD**: GitHub Actions + AWS CodeDeploy/ECR
- **IaC**: Terraform/CDK

## Overall Progress
**Current Status**: Not Started
**Last Updated**: 2025-09-03
**Active Milestone**: None
**Blockers**: None

---

## Milestone Progress

### Milestone 0: Repo and Platform Skeleton
**Status**: 🔴 Not Started
**Owner**: Platform Team
**Target Date**: TBD

#### Tasks
- [ ] Create GitHub repository structure
  - [ ] `/infra` - Terraform/CDK modules
  - [ ] `/platform` - Shared libraries, protos
  - [ ] `/services` - Microservices
  - [ ] `/frontend` - Next.js applications
  - [ ] `/tests` - E2E and load tests
  - [ ] `/docs` - ADRs, runbooks, architecture
- [ ] Documentation templates
  - [ ] `ADR-template.md`
  - [ ] `runbook-template.md`
  - [ ] `incident-template.md`
- [ ] AWS Infrastructure
  - [ ] EKS cluster with one node group
  - [ ] ALB Ingress Controller
  - [ ] CloudWatch monitoring setup
  - [ ] X-Ray tracing setup
  - [ ] AWS Secrets Manager integration
  - [ ] S3 buckets (static, media)
  - [ ] CloudFront distribution
  - [ ] Route 53 hosted zone
  - [ ] ACM certificate
- [ ] CI/CD Pipeline
  - [ ] GitHub Actions workflows
  - [ ] ECR repositories
  - [ ] ArgoCD or AWS CodeDeploy setup
- [ ] Basic Next.js BFF
  - [ ] Landing page
  - [ ] Health endpoint
  - [ ] X-Ray instrumentation

**Acceptance Criteria**:
- Landing page accessible via CloudFront
- End-to-end trace visible in X-Ray
- CI builds and pushes to ECR

**Notes**: 

---

### Milestone 1: Identity and Shell
**Status**: 🔴 Not Started
**Owner**: Identity Team, Frontend Team
**Target Date**: TBD
**Dependencies**: Milestone 0

#### Services to Build
- **identity-service**
  - [ ] REST API (signup, login, refresh, me)
  - [ ] JWT implementation
  - [ ] DynamoDB users table
  - [ ] RBAC claims system
  - [ ] Session management

- **frontend-shell**
  - [ ] Next.js App Router setup
  - [ ] shadcn UI components
  - [ ] Auth middleware
  - [ ] Protected routes
  - [ ] Performance budgets

#### Platform Components
- [ ] Proto definitions
  - [ ] User message
  - [ ] Auth messages
  - [ ] Common error types
- [ ] gRPC client generation

**Acceptance Criteria**:
- Sign in completes < 300ms p95
- JWT refresh rotation works
- X-Ray traces show auth checks

**Notes**:

---

### Milestone 2: Catalog MVP
**Status**: 🔴 Not Started
**Owner**: Catalog Team
**Target Date**: TBD
**Dependencies**: Milestone 1

#### Services to Build
- **catalog-service**
  - [ ] RDS PostgreSQL setup
  - [ ] Schema: product, sku, price, stock, region
  - [ ] REST endpoints (list, detail, admin CRUD)
  - [ ] EventBridge integration for ProductChanged
  - [ ] Versioning system

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
  - [ ] Step Functions workflow
    - [ ] Reserve inventory
    - [ ] Create payment intent
    - [ ] Capture payment
    - [ ] Finalize order
    - [ ] Compensation logic
  - [ ] DynamoDB idempotency store

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
- [ ] Amazon MSK or Kinesis setup
- [ ] EventBridge event bus
- [ ] SQS queues with DLQs

#### Event Topics/Streams
- [ ] product.events
- [ ] order.lifecycle
- [ ] payment.events
- [ ] analytics.raw

#### Service Updates
- [ ] Catalog publishes to EventBridge
- [ ] Orders publishes lifecycle events
- [ ] Payments publishes settlement events
- [ ] Email worker consumes SQS

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
  - [ ] Amazon OpenSearch domain
  - [ ] DMS CDC from RDS
  - [ ] Kinesis to OpenSearch pipeline
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
  - [ ] Lambda WebSocket handlers
  - [ ] ElastiCache pub/sub
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
  - [ ] Kinesis consumer
  - [ ] Daily aggregation jobs
  - [ ] CloudWatch custom metrics
  - [ ] RDS rollup tables

- **frontend-admin**
  - [ ] Admin dashboard
  - [ ] CloudWatch integration
  - [ ] Feature flags UI
  - [ ] SLO monitoring

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
| identity-service | 🔴 Not Started | - | 3001 | DynamoDB |
| catalog-service | 🔴 Not Started | - | 3002 | RDS PostgreSQL |
| orders-service | 🔴 Not Started | - | 3003 | DynamoDB, Step Functions |
| payments-service | 🔴 Not Started | - | 3004 | Stripe |
| search-service | 🔴 Not Started | - | 3005 | OpenSearch |
| media-service | 🔴 Not Started | - | 3006 | S3, MediaConvert |
| feed-service | 🔴 Not Started | - | 3007 | ElastiCache |
| realtime-service | 🔴 Not Started | - | 3008 | API Gateway WS |
| analytics-service | 🔴 Not Started | - | 3009 | Kinesis |
| compliance-service | 🔴 Not Started | - | 3010 | Step Functions |

## Frontend Modules

| Module | Status | Port | Dependencies |
|--------|--------|------|--------------|
| frontend-shell | 🔴 Not Started | 3000 | identity-service |
| frontend-catalog | 🔴 Not Started | - | catalog-service |
| frontend-checkout | 🔴 Not Started | - | orders-service |
| frontend-feed | 🔴 Not Started | - | feed-service |
| frontend-admin | 🔴 Not Started | 3100 | analytics-service |

## Key Decisions Made

1. **GraphQL only for Feed Service** - Best demonstrates aggregation benefits
2. **AWS-native services preferred** - Reduces operational overhead
3. **Step Functions over Temporal** - Native AWS orchestration
4. **EventBridge + Kinesis over pure Kafka** - Better AWS integration
5. **X-Ray over Jaeger** - Native tracing solution

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