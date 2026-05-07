import { createClient } from '@/lib/supabase/server';
import type { ComparisonTable } from '@/types/database';

export default async function ComparisonsPage() {
  const supabase = createClient();
  const { data: tables } = await supabase
    .from('comparison_tables')
    .select('*')
    .order('display_order', { ascending: true })
    .returns<ComparisonTable[]>();

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Comparison tables
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          {tables?.length ?? 0} table{tables?.length === 1 ? '' : 's'}.
        </p>
      </div>

      {!tables || tables.length === 0 ? (
        <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
          No comparison tables have been loaded yet.
        </p>
      ) : (
        <div className="space-y-8">
          {tables.map((t) => (
            <section
              key={t.id}
              className="rounded-lg border border-slate-200 bg-white shadow-sm"
            >
              <header className="border-b border-slate-200 px-5 py-3">
                <h2 className="text-base font-semibold text-slate-900">
                  Table {t.table_number}: {t.title}
                </h2>
                {t.description ? (
                  <p className="mt-1 text-sm text-slate-600">{t.description}</p>
                ) : null}
              </header>
              <div className="overflow-x-auto px-5 py-4">
                <table className="min-w-full border-collapse text-sm">
                  <thead className="bg-slate-100">
                    <tr>
                      {t.columns_json.map((col) => (
                        <th
                          key={col.key}
                          className="border border-slate-300 px-3 py-2 text-left font-semibold text-slate-900"
                        >
                          {col.label}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {t.rows_json.map((row, rowIdx) => (
                      <tr key={rowIdx} className="even:bg-slate-50">
                        {t.columns_json.map((col) => (
                          <td
                            key={col.key}
                            className="border border-slate-300 px-3 py-2 align-top text-slate-800"
                          >
                            {row[col.key] ?? ''}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              {t.footnote ? (
                <p className="border-t border-slate-200 px-5 py-3 text-xs italic text-slate-500">
                  {t.footnote}
                </p>
              ) : null}
            </section>
          ))}
        </div>
      )}
    </div>
  );
}
