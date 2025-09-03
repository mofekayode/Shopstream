# Product-first Build Plan with Teams, gRPC, Events, and Microfrontends

## Milestone 0. Repo and Platform Skeleton

Create GitHub repo with folders: `infra`, `platform`, `services`, `frontend`, `tests`, `docs`.

Add docs templates: `ADR.md`, `runbook.md`, `incident.md`.

Stand up EKS with one small node group. Add:
- Ingress controller
- Prometheus and Grafana
- Jaeger
- External Secrets wired to AWS Secrets Manager

Provision S3 for static and media, CloudFront, Route 53, ACM cert.

CI in GitHub Actions builds images and pushes to ECR. CD with Argo CD.

**Deliverable:** Landing page served by Next.js through CloudFront to ALB to a simple BFF. One trace visible end to end.

## Milestone 1. Identity and Shell

**Goal:** Authenticated users can land, browse a static catalog, and see a real session.

### Service Identity
- REST endpoints: signup, login, refresh, me
- JWT with short access token and rotating refresh tokens
- RBAC claims

### Frontend Shell Team
- Next.js app router
- shadcn UI kit
- Auth cookie storage and route guards
- Perf and accessibility budget in CI

### gRPC Shared Platform
- `platform/proto` with common messages: User, Money, ProductRef, Error
- Generate client stubs for Node services

**Deliverable:** Sign in works, header shows user, traces include auth checks.

## Milestone 2. Catalog MVP

**Goal:** Real products and inventory with relational truth.

### Service Catalog
- Postgres schema: product, sku, price, stock, region
- REST endpoints: list, detail, admin create
- Emits ProductChanged event on Kafka later, for now a simple SQS notification

### Frontend Catalog Team
- Product list and detail pages
- Image display from S3
- Accessibility checks for cards and filters
- BFF calls Catalog via gRPC for internal hops, exposes REST to the web

**Deliverable:** Users can browse products. One ADR: why Postgres is the source of truth.

## Milestone 3. Orders and Payments with Orchestration

**Goal:** Money flows with retries, idempotency, and compensation.

Bring in Temporal server

### Service Orders
- gRPC service Orders with CreateOrder, GetOrder, ListOrders
- Temporal workflow steps: reserve inventory, create PaymentIntent, capture on confirmation, finalize, compensate on failure
- Idempotency store in DynamoDB with TTL

### Service Payments
- Stripe test mode, webhook handler, reconciler job
- Emits PaymentSettled event

### Frontend Checkout Team
- Cart and checkout pages with optimistic UI and failure states
- Order history page with live status

**Deliverable:** A full checkout that you can break and recover on purpose. One ADR: DynamoDB vs Postgres for idempotency.

## Milestone 4. Events Backbone and Work Queues

**Goal:** Split streams from tasks and set the pattern for fanout.

Stand up MSK or a small EC2 Kafka for short windows

### Define Topics
- `product.events`
- `order.lifecycle`
- `payment.events`
- `analytics.raw`

### SQS Queues
- `email.outbound` queue with DLQ

### Update Services
- Catalog publishes ProductChanged to `product.events`
- Orders publishes state changes to `order.lifecycle`
- Payments publishes PaymentSettled
- Notifications consumes email queue

**Deliverable:** One screen that shows live event flow counts in Grafana.

## Milestone 5. Search with CDC Projection

**Goal:** Searchable catalog without double writes.

Stand up OpenSearch smallest possible, single AZ, short-lived

- Debezium for Postgres tables product and sku
- Kafka Connect sinks to OpenSearch

### Service Search
- REST query with filters and sorts
- Hydrates missing data from Catalog to avoid duplication

### Frontend Search Team
- Typeahead with latency budget
- Search results page with facets

**Deliverable:** Edit a product, see it in search seconds later. One ADR: why CDC beats app double writes.

## Milestone 6. Media Pipeline

**Goal:** Uploads, transcodes, thumbnails, and ready events.

- Client does presigned uploads to S3
- S3 event triggers Lambda that enqueues a `media.work` item

### Service Media
- Temporal workflow: transcode, thumbnail, moderate, mark ready
- Writes metadata in Postgres and emits MediaReady on Kafka

### Frontend Media Team
- Upload UI with progress and final preview
- Accessibility for drag and drop and focus states

**Deliverable:** Upload a clip, thumbnails appear, listing shows ready asset.

## Milestone 7. Feed with Streaming Features and Redis

**Goal:** Infinite scroll done right.

Stand up Redis on ElastiCache

Add Flink as a small cluster for feature generation

### Flink Jobs
- Consume `analytics.raw` and `order.lifecycle`
- Compute engagement and recency features
- Write user feed slices into Redis lists

### Service Feed
- gRPC Feed with GetPage and PublishActivity
- Falls back to Postgres when Redis misses

### Frontend Feed Team
- Infinite scroll with prefetch and graceful skeletons
- A debug panel that shows feature weights per card

**Deliverable:** Fast feed, measurable cache hit rate, clean backfill story.

## Milestone 8. Realtime Delivery

**Goal:** WebSockets for chat and likes, SSE for simple status, long polling as fallback.

- WebSocket gateway service behind NLB
- Redis pub sub for local region fanout, Kafka for cross region fanout later

### Service Notifications
- Consumes product, order, payment events and user actions
- Pushes to WebSocket channels and SSE streams

### Frontend Realtime Team
- WebSocket hook with backoff
- SSE for order status streams

**Deliverable:** Two browsers show the same page, likes and order status update live.

## Milestone 9. Analytics and Admin

**Goal:** Simple rollups and dashboards that feel like real ops.

### Service Analytics
- Consumes `analytics.raw` and payment events
- Writes daily sales, conversion, and p95 latency snapshots to Postgres

### Frontend Admin Team
- Admin dashboard pages with charts
- Feature flag toggles stored in DynamoDB
- SLO dashboards in Grafana for login, search, add to cart, checkout

**Deliverable:** Credible admin that answers what happened today.

## Milestone 10. Compliance and Audit

**Goal:** GDPR delete and export that touches every store.

### Service Compliance
- Temporal workflow starts DSAR delete or export
- Deletes or tombstones in Postgres, Redis, S3, OpenSearch, Cassandra later
- Writes immutable audit record to S3 and returns a signed certificate

### Frontend Compliance Panel
- Admin only controls to trigger DSARs
- Status with history link

**Deliverable:** One user deleted across the system with a certificate to prove it.

## Milestone 11. Mesh and Progressive Delivery

**Goal:** Reliability features without app changes.

- Install Istio or Linkerd
- Turn on mTLS, sane timeouts, retry budgets, simple circuit breakers
- Add Argo Rollouts
- Canary the Feed service, inject a failure, watch rollback

**Deliverable:** A rollback that happens while you sip coffee.

## Milestone 12. Cassandra and DynamoDB Where They Shine

**Goal:** Show real data model choices beyond Postgres.

- Stand up Cassandra for a single write heavy timeline table
- Move raw activity append into Cassandra with a careful partition and clustering key design
- Use DynamoDB for idempotency and feature flags if you have not already
- Add one ADR that explains the partition key design and hot partition avoidance

**Deliverable:** Data model talk that sounds like someone who has been on call.

## Milestone 13. Optional GraphQL

You can skip GraphQL. If you want a sharp demo without owning it everywhere, do this.

- Add a tiny GraphQL BFF that composes Feed plus Profile plus Availability
- One query on the web app calls this BFF
- Everything behind it stays gRPC

**Deliverable:** Single clear GraphQL win, no sprawl.

## Milestone 14. Load and Chaos

**Goal:** Proof it does not fall over instantly.

- k6 scenarios for cold start, flash sale, checkout spikes, and WebSocket churn
- Litmus chaos tests for pod kill and packet loss
- Grafana dashboard recordings for each scenario
- One runbook per failure that lists symptoms, graphs, and fix

**Deliverable:** Spicy graphs with a calm operator story.

## Team Map, Contracts, and Comms at a Glance

### Microfrontends

- **Shell and Auth team** owns layout, routing, auth state, top nav, and feature flag controls
- **Catalog team** owns product listing and detail. Exposes a remote module for the shell
- **Feed team** owns feed routes and components. Exposes a remote module
- **Checkout team** owns cart and checkout. Exposes a remote module
- **Admin team** owns admin routes and charts. Can live as a separate Next app mounted via module federation

### gRPC Surface Summary

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

Keep Protobuf messages in `platform/proto`. Version fields with reserved tags when you change them. Regenerate stubs in CI.

### Event Topics and Key Payload Fields

- **product.events** - product_id, sku_id, price, stock, region, version
- **order.lifecycle** - order_id, user_id, state, total, ts
- **payment.events** - payment_id, order_id, status, amount, ts
- **media.events** - asset_id, owner_id, status, variants, ts
- **analytics.raw** - user_id, action, object_id, ts, device, referrer

Use consistent keys and monotonic timestamps. Add a trace id in headers for cross system correlation.