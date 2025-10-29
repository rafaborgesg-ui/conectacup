# conectacup

Frontend for Conecta Cup built with Vite + React + TypeScript, deployed on Vercel.

## Getting started

- Install dependencies: `npm i`
- Start dev server: `npm run dev`

## Build and deploy

- Production build: `npm run build` (outputs to `build/`)
- Vercel uses `vercel.json` with `outputDirectory: "build"`

## Authentication

- Supabase Auth with Google OAuth. The app handles INITIAL_SESSION correctly after OAuth redirect.
