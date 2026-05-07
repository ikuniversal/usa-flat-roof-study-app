'use client';

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

// Renders study-content markdown. Raw HTML is stripped by react-markdown
// by default — we deliberately do NOT enable rehype-raw, so authored
// content cannot inject scripts or arbitrary HTML.
export function MarkdownRenderer({ source }: { source: string }) {
  if (!source.trim()) {
    return (
      <p className="text-sm italic text-slate-500">This section is empty.</p>
    );
  }
  return (
    <div className="space-y-4 text-slate-800 leading-relaxed">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          h1: (props) => (
            <h1
              className="mt-8 text-2xl font-semibold tracking-tight text-slate-900"
              {...props}
            />
          ),
          h2: (props) => (
            <h2
              className="mt-6 text-xl font-semibold tracking-tight text-slate-900"
              {...props}
            />
          ),
          h3: (props) => (
            <h3
              className="mt-4 text-lg font-semibold text-slate-900"
              {...props}
            />
          ),
          p: (props) => <p className="text-base text-slate-800" {...props} />,
          ul: (props) => (
            <ul
              className="ml-5 list-disc space-y-1 text-base text-slate-800"
              {...props}
            />
          ),
          ol: (props) => (
            <ol
              className="ml-5 list-decimal space-y-1 text-base text-slate-800"
              {...props}
            />
          ),
          li: (props) => <li className="pl-1" {...props} />,
          blockquote: (props) => (
            <blockquote
              className="border-l-4 border-slate-300 pl-4 italic text-slate-700"
              {...props}
            />
          ),
          a: (props) => (
            <a
              className="text-blue-700 underline underline-offset-2 hover:text-blue-900"
              {...props}
            />
          ),
          code: ({ children, ...props }) => (
            <code
              className="rounded bg-slate-100 px-1 py-0.5 font-mono text-sm text-slate-900"
              {...props}
            >
              {children}
            </code>
          ),
          pre: (props) => (
            <pre
              className="overflow-x-auto rounded-lg bg-slate-900 p-4 font-mono text-sm text-slate-100"
              {...props}
            />
          ),
          table: (props) => (
            <div className="overflow-x-auto">
              <table
                className="min-w-full border-collapse text-sm"
                {...props}
              />
            </div>
          ),
          thead: (props) => <thead className="bg-slate-100" {...props} />,
          th: (props) => (
            <th
              className="border border-slate-300 px-3 py-2 text-left font-semibold text-slate-900"
              {...props}
            />
          ),
          td: (props) => (
            <td
              className="border border-slate-300 px-3 py-2 align-top text-slate-800"
              {...props}
            />
          ),
          hr: () => <hr className="my-6 border-slate-200" />,
          strong: (props) => (
            <strong className="font-semibold text-slate-900" {...props} />
          ),
        }}
      >
        {source}
      </ReactMarkdown>
    </div>
  );
}
