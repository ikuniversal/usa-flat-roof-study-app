# USA Flat Roof Study App

A Next.js + Supabase study application for USA Flat Roof sales reps. The app
delivers structured learning content — chapter material, quizzes, a final exam,
comparison tables, a glossary, and inspection checklists — and tracks each
rep's progress through the curriculum.

## Stack

- [Next.js 14](https://nextjs.org/) (App Router) with TypeScript
- [Tailwind CSS](https://tailwindcss.com/) for styling
- [Supabase](https://supabase.com/) for auth, Postgres, and row-level security
- [`@supabase/ssr`](https://supabase.com/docs/guides/auth/server-side) for
  cookie-based auth in Server Components and Route Handlers
- [`lucide-react`](https://lucide.dev/) for icons
- [`react-markdown`](https://github.com/remarkjs/react-markdown) +
  [`remark-gfm`](https://github.com/remarkjs/remark-gfm) for rendering chapter
  and explanation content
- [`@uiw/react-md-editor`](https://uiwjs.github.io/react-md-editor/) for any
  authoring/admin surfaces
- [`date-fns`](https://date-fns.org/) for date formatting

## Getting Started

1. Install dependencies:

   ```bash
   npm install
   ```

2. Fill in Supabase credentials in `.env.local`:

   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY` (server-only; never expose to the client)

3. Run the dev server:

   ```bash
   npm run dev
   ```

   The app serves on [http://localhost:3000](http://localhost:3000).

## Project Layout

```
.
├── content/                       # Source content for seeding Supabase
│   ├── 01_book_structure.json     # Chapter / section outline
│   ├── 02_final_exam.json         # Final exam item bank
│   ├── 03_chapter_quizzes.json    # Per-chapter quizzes
│   ├── 04_comparison_tables.json  # Product / system comparisons
│   ├── 05_glossary.json           # Terms and definitions
│   ├── 06_inspection_checklists.json
│   └── 07_supabase_seed.sql       # Seed SQL for the Supabase schema
├── src/                           # Application source (App Router)
└── content_package_readme.pdf     # Original notes shipped with the content set
```

## Seeding Supabase

Apply the schema and seed data with the SQL file in `content/`:

```bash
psql "$SUPABASE_DB_URL" -f content/07_supabase_seed.sql
```

Or paste it into the Supabase SQL editor.

## Scripts

- `npm run dev` — local dev server
- `npm run build` — production build
- `npm run start` — run the production build
- `npm run lint` — ESLint
