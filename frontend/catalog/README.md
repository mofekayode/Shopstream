# Catalog - Product Browsing Microfrontend

Product browsing and search experience.

## Responsibilities
- Product listing with filters
- Product detail pages
- Search functionality
- Category navigation
- Recently viewed products

## Exposed Components
- `ProductList` - Grid/list view of products
- `ProductDetail` - Full product information
- `SearchBar` - Typeahead search component

## Tech Stack
- Next.js 14
- Module Federation (remote)
- TypeScript
- GraphQL client for search
- Tailwind CSS

## Getting Started
```bash
npm install
npm run dev
# Runs on http://localhost:3001
```

## API Dependencies
- `catalog-service` - Product data
- `search-service` - Full-text search
- `media-service` - Product images