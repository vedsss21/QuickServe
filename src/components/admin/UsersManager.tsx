import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { UserRole } from '../../types';
import { Users, Shield, User, Wrench, Mail, Phone, Calendar } from 'lucide-react';

export const UsersManager: React.FC = () => {
  const { users } = useApp();
  const [roleFilter, setRoleFilter] = useState<'ALL' | UserRole>('ALL');
  const [search, setSearch] = useState('');

  const filtered = users.filter((u) => {
    if (roleFilter !== 'ALL' && u.role !== roleFilter) return false;
    if (search && !u.fullName.toLowerCase().includes(search.toLowerCase()) && !u.email.toLowerCase().includes(search.toLowerCase())) {
      return false;
    }
    return true;
  });

  const getRoleBadge = (role: UserRole) => {
    switch (role) {
      case 'admin':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold bg-purple-100 text-purple-800 border border-purple-200">
            <Shield size={12} />
            Administrator
          </span>
        );
      case 'agent':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-200">
            <Wrench size={12} />
            Service Specialist
          </span>
        );
      case 'customer':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold bg-blue-100 text-blue-800 border border-blue-200">
            <User size={12} />
            Customer
          </span>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 rounded-xl border border-slate-200">
        <div>
          <h2 className="text-base font-bold text-slate-900">User Profiles & Role Directory</h2>
          <p className="text-xs text-slate-500">
            Governed by PostgreSQL profiles schema and Row-Level Security checks.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <input
            type="text"
            placeholder="Search users..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="text-xs border border-slate-300 rounded-lg px-3 py-2 w-52 focus:outline-hidden focus:border-indigo-500"
          />

          <div className="flex bg-slate-100 p-1 rounded-lg text-xs font-semibold">
            {(['ALL', 'admin', 'agent', 'customer'] as const).map((r) => (
              <button
                key={r}
                onClick={() => setRoleFilter(r)}
                className={`px-3 py-1 rounded-md capitalize transition-colors ${
                  roleFilter === r
                    ? 'bg-white text-slate-900 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {r === 'ALL' ? 'All Roles' : `${r}s`}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Users table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-xs">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50/80 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
              <th className="py-3 px-4">User</th>
              <th className="py-3 px-4">System Role</th>
              <th className="py-3 px-4">Contact Info</th>
              <th className="py-3 px-4">RLS Boundary</th>
              <th className="py-3 px-4">Joined Date</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {filtered.map((user) => (
              <tr key={user.id} className="hover:bg-slate-50/60 transition-colors">
                <td className="py-3.5 px-4">
                  <div className="flex items-center space-x-3">
                    <div className="w-8 h-8 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center font-bold text-xs text-slate-700">
                      {user.fullName.charAt(0)}
                    </div>
                    <div>
                      <div className="font-semibold text-slate-900">{user.fullName}</div>
                      <div className="text-xs text-slate-500 font-mono">{user.id.substring(0, 18)}...</div>
                    </div>
                  </div>
                </td>
                <td className="py-3.5 px-4">{getRoleBadge(user.role)}</td>
                <td className="py-3.5 px-4 text-xs text-slate-600">
                  <div className="flex items-center gap-1.5">
                    <Mail size={13} className="text-slate-400" />
                    <span>{user.email}</span>
                  </div>
                  {user.phone && (
                    <div className="flex items-center gap-1.5 mt-0.5 text-slate-500">
                      <Phone size={13} className="text-slate-400" />
                      <span>{user.phone}</span>
                    </div>
                  )}
                </td>
                <td className="py-3.5 px-4 text-xs">
                  {user.role === 'admin' && (
                    <span className="text-purple-700 font-medium">Bypass RLS (Universal Super-Admin)</span>
                  )}
                  {user.role === 'agent' && (
                    <span className="text-emerald-700 font-medium">agent_id = auth.uid()</span>
                  )}
                  {user.role === 'customer' && (
                    <span className="text-blue-700 font-medium">customer_id = auth.uid()</span>
                  )}
                </td>
                <td className="py-3.5 px-4 text-xs text-slate-500">
                  <div className="flex items-center gap-1">
                    <Calendar size={13} />
                    {new Date(user.createdAt).toLocaleDateString()}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
