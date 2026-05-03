'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';

export function SearchInput({ initialQuery }: { initialQuery: string }) {
  const [value, setValue] = useState(initialQuery);
  const [pending, startTransition] = useTransition();
  const router = useRouter();

  function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const q = value.trim();
    startTransition(() => {
      router.push(q ? `/learn/search?q=${encodeURIComponent(q)}` : '/learn/search');
    });
  }

  return (
    <form onSubmit={onSubmit} className="flex gap-2">
      <input
        type="search"
        placeholder="Search the field guide…"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        className="block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-slate-500 focus:outline-none focus:ring-1 focus:ring-slate-500"
      />
      <button
        type="submit"
        disabled={pending}
        className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
      >
        {pending ? 'Searching…' : 'Search'}
      </button>
    </form>
  );
}
