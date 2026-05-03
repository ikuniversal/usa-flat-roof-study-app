'use client';

import { useMemo, useState } from 'react';
import type { GlossaryTerm } from '@/types/database';

export function GlossarySearch({ terms }: { terms: GlossaryTerm[] }) {
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return terms;
    return terms.filter(
      (t) =>
        t.term.toLowerCase().includes(q) ||
        t.definition.toLowerCase().includes(q),
    );
  }, [query, terms]);

  return (
    <div className="space-y-4">
      <input
        type="search"
        placeholder="Search terms or definitions…"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-slate-500 focus:outline-none focus:ring-1 focus:ring-slate-500"
      />
      {filtered.length === 0 ? (
        <p className="text-sm italic text-slate-500">
          No terms match &ldquo;{query}&rdquo;.
        </p>
      ) : (
        <dl className="space-y-4">
          {filtered.map((term) => (
            <div
              key={term.id}
              className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm"
            >
              <dt className="text-base font-semibold text-slate-900">
                {term.term}
              </dt>
              <dd className="mt-1 text-sm text-slate-700">
                {term.definition}
              </dd>
              {term.references_json.length > 0 ? (
                <p className="mt-2 text-xs text-slate-500">
                  See: {term.references_json.join(', ')}
                </p>
              ) : null}
            </div>
          ))}
        </dl>
      )}
    </div>
  );
}
