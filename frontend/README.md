# Shopstream Frontend - Microfrontend Architecture

## Structure

Each frontend app is independently developed and deployed by different teams.

### Applications

#### `shell/` - Host Application
- **Owner**: Platform Team
- **Port**: 3000
- **Responsibilities**:
  - Main app shell and routing
  - Authentication state management
  - Layout (header, footer, navigation)
  - Module federation host configuration
  - Cross-app communication bus

#### `catalog/` - Product Catalog
- **Owner**: Catalog Team  
- **Port**: 3001
- **Responsibilities**:
  - Product listing pages
  - Product detail pages
  - Search and filtering
  - Category navigation
- **Exposes**: `ProductList`, `ProductDetail`, `SearchBar` components

#### `checkout/` - Cart & Checkout
- **Owner**: Checkout Team
- **Port**: 3002  
- **Responsibilities**:
  - Shopping cart
  - Checkout flow
  - Payment integration
  - Order confirmation
- **Exposes**: `CartWidget`, `CheckoutFlow` components

#### `feed/` - Personalized Feed
- **Owner**: Feed Team
- **Port**: 3003
- **Responsibilities**:
  - Infinite scroll feed
  - Real-time updates
  - Social interactions
  - Recommendations
- **Exposes**: `FeedContainer`, `FeedCard` components

#### `admin/` - Admin Dashboard
- **Owner**: Admin Team
- **Port**: 3100
- **Responsibilities**:
  - Product management
  - Order management
  - Analytics dashboards
  - User management
- **Note**: Standalone app, not part of main module federation

#### `shared/` - Shared Libraries
- **Owner**: Platform Team
- **Packages**:
  - `@shopstream/ui` - Design system components
  - `@shopstream/utils` - Common utilities
  - `@shopstream/hooks` - Shared React hooks
  - `@shopstream/types` - TypeScript types

## Module Federation Setup

### Host Configuration (shell)
```javascript
// next.config.js in shell/
const { NextFederationPlugin } = require('@module-federation/nextjs-mf');

module.exports = {
  webpack(config) {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'shell',
        remotes: {
          catalog: 'catalog@http://localhost:3001/_next/static/chunks/remoteEntry.js',
          checkout: 'checkout@http://localhost:3002/_next/static/chunks/remoteEntry.js',
          feed: 'feed@http://localhost:3003/_next/static/chunks/remoteEntry.js',
        },
        shared: {
          react: { singleton: true },
          'react-dom': { singleton: true },
        },
      })
    );
    return config;
  },
};
```

### Remote Configuration (e.g., catalog)
```javascript
// next.config.js in catalog/
module.exports = {
  webpack(config) {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'catalog',
        filename: 'static/chunks/remoteEntry.js',
        exposes: {
          './ProductList': './components/ProductList',
          './ProductDetail': './components/ProductDetail',
          './SearchBar': './components/SearchBar',
        },
        shared: {
          react: { singleton: true },
          'react-dom': { singleton: true },
        },
      })
    );
    return config;
  },
};
```

## Communication Patterns

### 1. Shared State (via Shell)
```typescript
// Shell provides auth context
<AuthProvider>
  <RemoteApp />
</AuthProvider>
```

### 2. Event Bus
```typescript
// Cross-app communication
eventBus.emit('cart:updated', { itemCount: 3 });
eventBus.on('user:login', (user) => { ... });
```

### 3. Route Parameters
```typescript
// Shell handles routing, passes params
<Route path="/product/:id" 
       component={lazy(() => import('catalog/ProductDetail'))} />
```

## Development Workflow

### Local Development
```bash
# Start all apps (from root)
npm run dev:all

# Or start individually
cd frontend/shell && npm run dev
cd frontend/catalog && npm run dev
```

### Independent Deployment
Each app can be deployed independently:
- Shell: Deploys to CloudFront (main domain)
- Remotes: Deploy to separate CloudFront distributions
- Shared: Published to npm registry or GitHub packages

## Testing Strategy

### Unit Tests
Each app maintains its own unit tests:
```bash
cd frontend/catalog
npm test
```

### Integration Tests
Test module federation integration:
```bash
cd frontend
npm run test:integration
```

### E2E Tests
Test complete user journeys across apps:
```bash
npm run test:e2e
```

## Performance Considerations

1. **Lazy Loading**: Remote modules loaded on-demand
2. **Shared Dependencies**: React, common libs shared to reduce bundle size
3. **Fallbacks**: Error boundaries for failed remote loads
4. **Caching**: Remotes cached with proper versioning

## Team Boundaries

| Team | Owns | API Dependencies |
|------|------|------------------|
| Platform | shell, shared | identity-service |
| Catalog | catalog app | catalog-service, search-service |
| Checkout | checkout app | orders-service, payments-service |
| Feed | feed app | feed-service, realtime-service |
| Admin | admin app | analytics-service, all services |

## Migration Path

1. **Phase 1**: Monolith with clear boundaries
2. **Phase 2**: Extract shared components
3. **Phase 3**: Enable module federation
4. **Phase 4**: Deploy independently
5. **Phase 5**: Full team autonomy