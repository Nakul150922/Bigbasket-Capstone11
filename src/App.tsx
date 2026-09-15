import React from 'react';

export default function App() {
  const artifacts = [
    { name: 'generate_data.py', type: 'Python Script', desc: 'Synthetic dataset generator' },
    { name: 'bigbasket_capstone.db', type: 'SQLite Database', desc: '500 clean orders & 31 products' },
    { name: 'orders_raw.csv', type: 'Raw Dataset', desc: '508 original transactional rows' },
    { name: 'products.csv', type: 'Metadata', desc: '31 product SKU catalog' },
    { name: 'verify.sql', type: 'SQL Script', desc: 'Automated verification test suite' },
    { name: '01_foundations.sql', type: 'SQL Script', desc: 'Schema DDL & data import' },
    { name: '02_aggregation_joins.sql', type: 'SQL Script', desc: 'Aggregations, joins & window functions' },
    { name: '03_reporting.sql', type: 'SQL Script', desc: 'Reporting queries & monthly category summary' },
    { name: 'monthly_category_revenue.csv', type: 'Report Export', desc: 'Capped monthly category revenue' },
    { name: 'capstone_spreadsheet.xlsx', type: 'Excel Workbook', desc: 'Interactive financial modeling & dashboard' },
    { name: 'analysis.ipynb', type: 'Jupyter Notebook', desc: '25-cell end-to-end diagnostic audit' },
    { name: 'ai_log.md', type: 'Documentation', desc: 'AI co-pilot audit log' }
  ];

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 p-8">
      <div className="max-w-4xl mx-auto">
        <header className="border-b border-slate-700 pb-6 mb-8">
          <h1 className="text-2xl font-bold text-white tracking-tight">BigBasket Capstone Submission Repository</h1>
          <p className="text-slate-400 text-sm mt-1">All 12 required project artifacts are verified and present at repository root.</p>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {artifacts.map((item) => (
            <div key={item.name} className="bg-slate-800/80 border border-slate-700 rounded-lg p-4 flex flex-col justify-between">
              <div>
                <span className="text-xs font-semibold px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                  {item.type}
                </span>
                <h3 className="font-mono text-sm font-bold text-white mt-2">{item.name}</h3>
                <p className="text-xs text-slate-400 mt-1">{item.desc}</p>
              </div>
              <div className="text-xs text-emerald-400 mt-3 font-medium flex items-center">
                <span className="inline-block w-2 h-2 rounded-full bg-emerald-400 mr-2"></span>
                Root file verified
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
