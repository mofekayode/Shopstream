# Shopstream Product Requirements Document

## 1. Product Name and One Line

**Shopstream** - A multi-tenant commerce plus social reference app that shows how to design, build, ship, observe, and scale a real cloud system end to end. It is an open source learning product that feels production grade.

## 2. Problem and Why This Exists

Engineers want staff level depth but most samples are toy apps.

Teams need a concrete blueprint that ties microservices, streams, workflows, and a fast accessible frontend into one coherent product.

Recruiters and clients want proof of practical tradeoffs. This repo is that proof.

## 3. Target Users and Personas

- **Learner engineer** who wants real world patterns
- **Hiring manager** who wants a credible systems portfolio
- **Contractor** who needs a battle tested template for new client builds
- **Educator** who needs labs and demos

## 4. Product Pillars

- **Real workloads not hello world** - Infinite feed, media pipeline, checkout, search, notifications
- **Clear service ownership** - Each service owns its data and contracts
- **Observability first** - Logs, metrics, traces, SLOs, synthetic tests
- **Frontend excellence** - Fast, safe, accessible Next.js with shadcn
- **Compliance story** - DSAR delete or export with audit

## 5. High Level Features by Surface

### Identity
- Email sign up, sign in, sign out, refresh
- RBAC with claims in short lived JWT
- Session cookies with HttpOnly and SameSite set
- Admin flag for back office

**Acceptance**
- Sign in completes in under 300 ms p95 on warm cache
- Refresh rotates tokens and detects reuse

### Catalog
- Product, SKU, price, stock, region ownership in Postgres
- Admin create and edit with validation and versioning
- Emits ProductChanged events

**Acceptance**
- Product create reflects in read APIs in under 500 ms p95
- Edits appear in search within 5 seconds

### Search
- CDC from Postgres via Debezium to Kafka to OpenSearch
- Full text with facets and filters
- Typeahead with prefix queries
- Hydration from Catalog to avoid duplication

**Acceptance**
- Edit to index latency under 5 seconds p95
- Query p95 under 150 ms for top 100 results

### Media
- Client uploads to S3 with presigned URLs
- Temporal workflow for transcode, thumbnail, moderation
- Asset metadata in Postgres. Ready events on Kafka

**Acceptance**
- Upload to ready within 30 seconds for a short clip
- Failed step retries three times with exponential backoff

### Feed
- Flink computes scores from events and writes Redis lists per user
- Feed service paginates from Redis with Postgres fallback
- Backfill on signup to avoid empty feeds

**Acceptance**
- First page p95 under 100 ms on cache hit
- Cache hit rate above 80 percent under steady traffic

### Orders
- Temporal workflow coordinates reserve inventory, create payment intent, capture, finalize, compensate
- Idempotency store in DynamoDB with TTL
- Order state machine emits lifecycle events

**Acceptance**
- Duplicate submits do not double charge
- Compensating path returns stock within one minute

### Payments
- Stripe in test mode with webhook verification
- Reconciler heals missed webhooks
- Refund API for admin

**Acceptance**
- Payment status consistent across Stripe, Orders, and Analytics within one minute

### Notifications
- WebSocket fanout for chat, likes, and feed pings
- SSE streams for order status
- SQS email worker with DLQ

**Acceptance**
- Live updates arrive in under 250 ms p95 within a region
- Email retries visible in DLQ with reason

### Analytics
- Kafka ingestion of clickstream and lifecycle events
- Flink creates daily aggregates
- Admin dashboard reads Postgres rollups

**Acceptance**
- Daily rollups available by 01:05 local time
- Admin charts load in under 300 ms p95

### Compliance
- DSAR delete and export via Temporal workflow
- Deletes or tombstones across Postgres, Redis, S3, OpenSearch, Cassandra where used
- Immutable audit record to S3 and a signed certificate

**Acceptance**
- DSAR completes in under 24 hours in demo settings
- Audit entry is immutable and linked to the request

## 6. Frontend Features and Quality Bar

- Next.js with App Router and server components used for data heavy routes
- shadcn based design system with tokens and dark mode
- Route level error boundaries and loading states
- Realtime hook with WebSocket and backoff plus SSE fallback
- Accessibility checks in CI using Axe and keyboard nav smoke tests
- Lighthouse CI budgets for LCP, CLS, INP with hard fail thresholds
- Strict CSP, CSP nonce for inline scripts, no eval
- Image component with proper sizes and priority set only where it helps LCP

**Acceptance**
- Home and Catalog LCP under 2 seconds on a mid range laptop over Fast 3G profile in CI
- All pages pass Axe critical checks
- No mixed content or CSP violations in dev tools console

## 7. System Contracts and Communications

### gRPC API Summary
- **Identity** - GetUser, ValidateToken
- **Catalog** - GetProduct, ListProducts, UpdateStock
- **Orders** - CreateOrder, GetOrder, ListOrders
- **Payments** - CreateIntent, Capture, Refund
- **Media** - StartIngest, GetAsset
- **Feed** - GetPage, PublishActivity
- **Search** - Query
- **Notifications** - RegisterChannel, PushTest
- **Analytics** - GetDailyStats
- **Compliance** - StartDSAR, GetDSAR

**Rules**
- Protobuf source of truth in platform proto
- Backward compatible fields with reserved tags for removals
- Deadline and retry policy defined per method

### Event Topics
- **product.events** with product id, sku id, price, stock, region, version
- **order.lifecycle** with order id, user id, state, total, ts
- **payment.events** with payment id, order id, status, amount, ts
- **media.events** with asset id, owner id, status, variants, ts
- **analytics.raw** with user id, action, object id, ts, device, referrer

**Rules**
- At least once delivery. Consumers must be idempotent
- Trace id propagated in headers for end to end correlation

## 8. Data Stores and Why

- **Postgres** for money and strong constraints
- **Redis** for hot reads, rate limits, and locks
- **DynamoDB** for idempotency and feature flags with TTL
- **S3** for media and audit archives
- **OpenSearch** for textual search via CDC projections
- **Cassandra** for a single write heavy timeline to show wide column modeling

## 9. Observability and Reliability Features

- Logs via Fluent Bit to OpenSearch with Kibana for drill down
- Metrics via Prometheus and dashboards in Grafana
- Tracing via OpenTelemetry to Jaeger with service to service context propagation
- Alerting via Alertmanager to email or PagerDuty
- Synthetic tests via k6 and Locust
- Chaos tests via Litmus for pod kill and packet loss
- Mesh with mTLS, timeouts, retries, and circuit breakers

### SLO Examples
- Login success rate above 99.9 percent
- Checkout p95 under 800 ms on steady load
- Feed first page p95 under 200 ms on warm cache

## 10. Release Plan at a Glance

- **v0.1** - Identity and catalog visible
- **v0.2** - Checkout with Temporal and Stripe
- **v0.3** - Events plus SQS workers
- **v0.4** - CDC search
- **v0.5** - Media ingest and thumbnails
- **v0.6** - Feed with Redis and Flink features
- **v0.7** - Realtime websockets and SSE
- **v0.8** - Analytics dashboard and SLOs
- **v0.9** - DSAR delete and audit
- **v1.0** - Mesh and canary plus a small live demo

## 11. Success Metrics for the Project

- A new engineer can run the stack locally in under 15 minutes
- Three demo videos show checkout with compensation, CDC search, and realtime feed
- One blog overview plus a deep dive series index
- At least five ADRs that show clear reasoning and tradeoffs
- Recruiter or client can understand the value in under two minutes from the readme and demos

## 12. Out of Scope for v1

- Mobile apps
- Multi region failover
- Advanced search ranking models
- Full fraud engine
- Third party identity providers beyond email and password

## 13. Primary Risks and Hedges

- **Cost creep** - Hedge with smallest managed tiers and strict teardown scripts
- **Scope creep** - Hedge with the release plan and ADR discipline
- **Demo rot** - Hedge with CI that runs smoke tests and regenerates diagrams

## 14. What You Will Show in the Launch Blog

- System diagram with a short trace from click to charge to event fanout
- Three short clips: Feed load storm, Checkout with a forced failure and compensation, DSAR delete across stores
- Links to Grafana, Jaeger, and Kibana recordings
- One paragraph per pillar that explains the tradeoff you made