# Shell - Host Application

The main container application that orchestrates all microfrontends.

## Responsibilities
- Application shell (header, footer, navigation)
- Authentication and session management  
- Routing between microfrontends
- Module federation host
- Global state management
- Error boundaries for remote failures

## Tech Stack
- Next.js 14 with App Router
- TypeScript
- Tailwind CSS
- shadcn/ui
- Module Federation (to be added when integrating remotes)

## Getting Started
```bash
npm install
npm run dev
# Runs on http://localhost:3000
```

## Environment Variables
```env
NEXT_PUBLIC_CATALOG_URL=http://localhost:3001
NEXT_PUBLIC_CHECKOUT_URL=http://localhost:3002
NEXT_PUBLIC_FEED_URL=http://localhost:3003
NEXT_PUBLIC_API_URL=http://localhost:4000
```