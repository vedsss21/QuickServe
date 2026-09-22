import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { ServiceItem } from '../../types';
import { Wrench, CheckCircle2, XCircle, Clock, DollarSign, Plus, Power } from 'lucide-react';

export const ServicesManager: React.FC = () => {
  const { services, toggleServiceStatus } = useApp();
  const [searchTerm, setSearchTerm] = useState('');

  const filtered = services.filter(
    (s) =>
      s.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      s.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 rounded-xl border border-slate-200">
        <div>
          <h2 className="text-base font-bold text-slate-900">Services Catalog</h2>
          <p className="text-xs text-slate-500">
            Manage offered technician categories, standard base pricing, and customer availability.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <input
            type="text"
            placeholder="Search services..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="text-xs border border-slate-300 rounded-lg px-3 py-2 w-64 focus:outline-hidden focus:border-indigo-500"
          />
        </div>
      </div>

      {/* Grid of services */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filtered.map((service) => (
          <div
            key={service.id}
            className={`bg-white rounded-xl border p-5 transition-all shadow-xs ${
              service.isActive ? 'border-slate-200 hover:border-slate-300' : 'border-slate-200 bg-slate-50/60 opacity-75'
            }`}
          >
            <div className="flex items-start justify-between">
              <div className="flex items-center space-x-3">
                <div
                  className={`w-11 h-11 rounded-xl flex items-center justify-center ${
                    service.isActive
                      ? 'bg-indigo-50 text-indigo-600'
                      : 'bg-slate-100 text-slate-400'
                  }`}
                >
                  <Wrench size={22} />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-base">{service.name}</h3>
                  <span className="font-mono text-xs text-slate-500">{service.code}</span>
                </div>
              </div>

              <button
                onClick={() => toggleServiceStatus(service.id)}
                className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold transition-all ${
                  service.isActive
                    ? 'bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100'
                    : 'bg-slate-200 text-slate-600 hover:bg-slate-300'
                }`}
                title="Toggle Active/Inactive"
              >
                <Power size={13} />
                {service.isActive ? 'Active' : 'Inactive'}
              </button>
            </div>

            <p className="text-xs text-slate-600 mt-3 line-clamp-2 leading-relaxed">
              {service.description}
            </p>

            <div className="mt-4 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-600">
              <div className="flex items-center gap-1 font-semibold text-slate-900">
                <DollarSign size={14} className="text-emerald-600" />
                Base: ${service.basePrice.toFixed(2)}
              </div>
              <div className="flex items-center gap-1 text-slate-500">
                <Clock size={14} />
                Est. Turnaround: ~{service.estimatedHours} hrs
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
