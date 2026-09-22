import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { Shield, Clock, Database, Globe, Search } from 'lucide-react';

export const AuditLogsViewer: React.FC = () => {
  const { auditLogs } = useApp();
  const [filterAction, setFilterAction] = useState<string>('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  const filtered = auditLogs.filter((log) => {
    if (filterAction !== 'ALL' && log.action !== filterAction) return false;
    if (searchTerm) {
      const q = searchTerm.toLowerCase();
      return (
        log.recordId.toLowerCase().includes(q) ||
        log.changedByName.toLowerCase().includes(q) ||
        log.tableName.toLowerCase().includes(q)
      );
    }
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Header bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 rounded-xl border border-slate-200">
        <div>
          <div className="flex items-center space-x-2">
            <Shield size={18} className="text-indigo-600" />
            <h2 className="text-base font-bold text-slate-900">Immutable PostgreSQL Audit Logs</h2>
          </div>
          <p className="text-xs text-slate-500 mt-0.5">
            Auto-captured via trigger functions on all transactional status and assignment changes.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search size={14} className="absolute left-3 top-2.5 text-slate-400" />
            <input
              type="text"
              placeholder="Search table, record or user..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="text-xs border border-slate-300 rounded-lg pl-8 pr-3 py-2 w-64 focus:outline-hidden focus:border-indigo-500"
            />
          </div>

          <div className="flex bg-slate-100 p-1 rounded-lg text-xs font-semibold">
            {['ALL', 'INSERT', 'UPDATE'].map((act) => (
              <button
                key={act}
                onClick={() => setFilterAction(act)}
                className={`px-3 py-1 rounded-md transition-colors ${
                  filterAction === act
                    ? 'bg-white text-slate-900 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {act}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Audit Log Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-xs">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50/80 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
              <th className="py-3 px-4">Event Timestamp</th>
              <th className="py-3 px-4">Action</th>
              <th className="py-3 px-4">Target Table & ID</th>
              <th className="py-3 px-4">Author / User</th>
              <th className="py-3 px-4">State Delta / Modification</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-xs">
            {filtered.map((log) => (
              <tr key={log.id} className="hover:bg-slate-50/60 transition-colors">
                <td className="py-3.5 px-4 font-mono text-slate-500 whitespace-nowrap">
                  <div className="flex items-center gap-1.5">
                    <Clock size={12} />
                    {new Date(log.createdAt).toLocaleString()}
                  </div>
                </td>
                <td className="py-3.5 px-4">
                  <span
                    className={`px-2 py-0.5 rounded font-mono font-bold text-[10px] ${
                      log.action === 'INSERT'
                        ? 'bg-emerald-100 text-emerald-800'
                        : log.action === 'UPDATE'
                        ? 'bg-blue-100 text-blue-800'
                        : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {log.action}
                  </span>
                </td>
                <td className="py-3.5 px-4">
                  <div className="font-semibold text-slate-800 flex items-center gap-1">
                    <Database size={12} className="text-slate-400" />
                    {log.tableName}
                  </div>
                  <div className="text-[11px] font-mono text-slate-500">{log.recordId}</div>
                </td>
                <td className="py-3.5 px-4">
                  <div className="font-semibold text-slate-900">{log.changedByName}</div>
                  <div className="text-[11px] text-slate-400 flex items-center gap-1">
                    <Globe size={10} />
                    IP: {log.ipAddress || '103.22.44.10'}
                  </div>
                </td>
                <td className="py-3.5 px-4 font-mono max-w-md">
                  {log.oldData && (
                    <div className="text-rose-700 bg-rose-50/80 p-1.5 rounded border border-rose-200 mb-1 overflow-x-auto text-[11px]">
                      - {JSON.stringify(log.oldData)}
                    </div>
                  )}
                  {log.newData && (
                    <div className="text-emerald-700 bg-emerald-50/80 p-1.5 rounded border border-emerald-200 overflow-x-auto text-[11px]">
                      + {JSON.stringify(log.newData)}
                    </div>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
