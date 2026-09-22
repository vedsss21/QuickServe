import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { RequestPriority, ServiceRequest } from '../../types';
import {
  Smartphone,
  Plus,
  ArrowLeft,
  Calendar,
  MapPin,
  Clock,
  CheckCircle2,
  AlertTriangle,
  Send,
  X,
  User,
  Wrench,
  Shield,
} from 'lucide-react';

export const CustomerSimulator: React.FC = () => {
  const { requests, services, users, createRequest, cancelRequest } = useApp();
  const currentCustomer = users.find((u) => u.email === 'customer@quickserve.com') || users[3];

  const [screen, setScreen] = useState<'home' | 'create' | 'detail'>('home');
  const [selectedReq, setSelectedReq] = useState<ServiceRequest | null>(null);

  // Form states
  const [selectedServiceId, setSelectedServiceId] = useState(services[0]?.id || 'srv-001');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<RequestPriority>('medium');
  const [preferredDate, setPreferredDate] = useState('2026-09-24T10:00');
  const [address, setAddress] = useState('742 Evergreen Terrace, Sector 4, Nagpur');
  const [cancellationReason, setCancellationReason] = useState('');
  const [showCancelPrompt, setShowCancelPrompt] = useState(false);
  const [notification, setNotification] = useState<string | null>(null);

  // Filter requests belonging to this customer (RLS enforcement simulation)
  const customerRequests = requests.filter((r) => r.customerId === currentCustomer.id);

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !description || !address) return;

    const newReq = createRequest({
      customerId: currentCustomer.id,
      serviceId: selectedServiceId,
      title,
      description,
      priority,
      preferredDateTime: new Date(preferredDate).toISOString(),
      serviceAddress: address,
    });

    setTitle('');
    setDescription('');
    setNotification(`Service ticket ${newReq.requestNumber} booked successfully!`);
    setTimeout(() => setNotification(null), 4000);
    setScreen('home');
  };

  const handleCancel = () => {
    if (!selectedReq || !cancellationReason.trim()) return;
    cancelRequest(selectedReq.id, cancellationReason.trim());
    setShowCancelPrompt(false);
    setCancellationReason('');
    // refresh detail reference
    const updated = requests.find((r) => r.id === selectedReq.id);
    if (updated) setSelectedReq(updated);
    setNotification('Service request cancelled.');
    setTimeout(() => setNotification(null), 3000);
  };

  return (
    <div className="flex flex-col lg:flex-row items-center justify-center gap-8 py-4">
      {/* Informative side panel */}
      <div className="max-w-md space-y-4 text-sm text-slate-600">
        <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-5 text-indigo-900">
          <div className="flex items-center gap-2 font-bold text-base mb-1">
            <Smartphone size={20} className="text-indigo-600" />
            Flutter Customer App Simulation
          </div>
          <p className="text-xs text-indigo-800 leading-relaxed">
            Direct interactive demonstration of the Flutter codebase built in <code className="font-mono bg-indigo-100 px-1 py-0.5 rounded">flutter_app/lib/screens/customer/</code>.
          </p>
          <div className="mt-3 text-xs space-y-1.5 border-t border-indigo-200 pt-3">
            <div className="flex items-center gap-1.5">
              <Shield size={13} className="text-indigo-600" />
              <span><strong>Logged In:</strong> {currentCustomer.fullName} ({currentCustomer.email})</span>
            </div>
            <div className="flex items-center gap-1.5">
              <CheckCircle2 size={13} className="text-indigo-600" />
              <span><strong>RLS Scope:</strong> Restricted to <code>customer_id = auth.uid()</code></span>
            </div>
            <div className="flex items-center gap-1.5">
              <Wrench size={13} className="text-indigo-600" />
              <span><strong>Actions:</strong> Book new request, track dispatch status, cancel pending tickets</span>
            </div>
          </div>
        </div>

        <div className="p-4 bg-white rounded-xl border border-slate-200 shadow-2xs space-y-2">
          <h4 className="font-bold text-slate-800 text-xs uppercase tracking-wider">Try This Flow:</h4>
          <ol className="list-decimal list-inside text-xs text-slate-600 space-y-1">
            <li>Click <strong>New Request</strong> inside the phone simulator.</li>
            <li>Fill the form with issue details and submit.</li>
            <li>Note the auto-assigned ID (e.g. <code>REQ-2026-XXXXXX</code>).</li>
            <li>Switch to the <strong>Admin Portal</strong> or <strong>Agent App</strong> to see it appear in real-time!</li>
          </ol>
        </div>
      </div>

      {/* Phone Mockup Frame */}
      <div className="w-[360px] h-[700px] bg-slate-900 rounded-[44px] p-3 shadow-2xl border-4 border-slate-800 relative flex flex-col">
        {/* Speaker / Notch */}
        <div className="w-32 h-4 bg-slate-900 rounded-full mx-auto absolute left-0 right-0 top-5 z-30 flex items-center justify-center">
          <div className="w-10 h-1 bg-slate-700 rounded-full"></div>
        </div>

        {/* Screen container */}
        <div className="w-full h-full bg-slate-50 rounded-[34px] overflow-hidden flex flex-col relative pt-7">
          {/* Mobile Top Bar */}
          <div className="px-5 py-3 bg-white border-b border-slate-200 flex items-center justify-between z-20">
            <div className="flex items-center space-x-2">
              {screen !== 'home' ? (
                <button
                  onClick={() => setScreen('home')}
                  className="p-1 text-slate-600 hover:text-slate-900"
                >
                  <ArrowLeft size={18} />
                </button>
              ) : (
                <div className="w-6 h-6 rounded-md bg-indigo-600 flex items-center justify-center text-white font-bold text-xs">
                  QS
                </div>
              )}
              <span className="font-bold text-slate-900 text-sm">
                {screen === 'home'
                  ? 'QuickServe'
                  : screen === 'create'
                  ? 'Book Service'
                  : selectedReq?.requestNumber}
              </span>
            </div>

            {screen === 'home' && (
              <button
                onClick={() => setScreen('create')}
                className="w-7 h-7 rounded-full bg-indigo-600 text-white flex items-center justify-center hover:bg-indigo-700"
                title="Book New Request"
              >
                <Plus size={16} />
              </button>
            )}
          </div>

          {/* Toast Notification */}
          {notification && (
            <div className="absolute top-16 left-4 right-4 z-30 bg-emerald-600 text-white p-2.5 rounded-lg text-xs font-semibold shadow-lg text-center animate-in fade-in slide-in-from-top-2">
              {notification}
            </div>
          )}

          {/* Screen 1: Home / My Requests */}
          {screen === 'home' && (
            <div className="flex-1 overflow-y-auto p-4 space-y-4">
              {/* User greeting */}
              <div className="bg-gradient-to-r from-indigo-700 to-indigo-600 rounded-xl p-4 text-white">
                <div className="text-xs text-indigo-200">Welcome back,</div>
                <div className="text-base font-bold">{currentCustomer.fullName}</div>
                <div className="text-[11px] text-indigo-100 mt-1">
                  Need a home technician? Fast dispatch within 2 hours.
                </div>
              </div>

              {/* Book Request CTA */}
              <button
                onClick={() => setScreen('create')}
                className="w-full py-3 px-4 bg-white border border-dashed border-indigo-300 rounded-xl text-indigo-600 font-bold text-xs flex items-center justify-center gap-2 hover:bg-indigo-50/50 shadow-2xs"
              >
                <Plus size={15} />
                Book a New Service Request
              </button>

              {/* Customer's Tickets */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <h4 className="text-xs font-bold text-slate-600 uppercase tracking-wider">
                    My Service Orders ({customerRequests.length})
                  </h4>
                </div>

                <div className="space-y-2.5">
                  {customerRequests.map((req) => (
                    <div
                      key={req.id}
                      onClick={() => {
                        setSelectedReq(req);
                        setScreen('detail');
                      }}
                      className="bg-white p-3 rounded-xl border border-slate-200 shadow-2xs hover:border-indigo-300 transition-all cursor-pointer"
                    >
                      <div className="flex items-center justify-between text-xs mb-1">
                        <span className="font-mono font-bold text-indigo-600">{req.requestNumber}</span>
                        <span
                          className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase ${
                            req.status === 'COMPLETED'
                              ? 'bg-emerald-100 text-emerald-800'
                              : req.status === 'CANCELLED'
                              ? 'bg-rose-100 text-rose-800'
                              : 'bg-indigo-100 text-indigo-800'
                          }`}
                        >
                          {req.status.replace('_', ' ')}
                        </span>
                      </div>
                      <div className="font-semibold text-slate-900 text-xs line-clamp-1">{req.title}</div>
                      <div className="text-[11px] text-slate-500 mt-0.5">{req.serviceName}</div>
                      <div className="flex items-center justify-between text-[10px] text-slate-400 mt-2 pt-2 border-t border-slate-100">
                        <span className="flex items-center gap-1">
                          <Calendar size={10} />
                          {new Date(req.preferredDateTime).toLocaleDateString()}
                        </span>
                        {req.agentName && (
                          <span className="text-emerald-600 font-medium">Technician: {req.agentName}</span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Screen 2: Create Request Form */}
          {screen === 'create' && (
            <div className="flex-1 overflow-y-auto p-4">
              <form onSubmit={handleCreate} className="space-y-3.5 text-xs">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Service Type</label>
                  <select
                    value={selectedServiceId}
                    onChange={(e) => setSelectedServiceId(e.target.value)}
                    className="w-full p-2 bg-white border border-slate-300 rounded-lg text-xs"
                  >
                    {services.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.name} (${s.basePrice})
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Issue Title</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Master bathroom tap leaking continuously"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full p-2 bg-white border border-slate-300 rounded-lg text-xs"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Description of Issue</label>
                  <textarea
                    required
                    rows={3}
                    placeholder="Provide details about symptoms, leak rate, or electrical tripping..."
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="w-full p-2 bg-white border border-slate-300 rounded-lg text-xs"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Priority</label>
                  <div className="grid grid-cols-3 gap-2">
                    {(['low', 'medium', 'high'] as const).map((p) => (
                      <button
                        type="button"
                        key={p}
                        onClick={() => setPriority(p)}
                        className={`py-1.5 rounded-lg font-bold uppercase text-[10px] border transition-colors ${
                          priority === p
                            ? 'bg-indigo-600 text-white border-indigo-600'
                            : 'bg-white text-slate-600 border-slate-200'
                        }`}
                      >
                        {p}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Preferred Appointment</label>
                  <input
                    type="datetime-local"
                    value={preferredDate}
                    onChange={(e) => setPreferredDate(e.target.value)}
                    className="w-full p-2 bg-white border border-slate-300 rounded-lg text-xs"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Service Address</label>
                  <input
                    type="text"
                    required
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    className="w-full p-2 bg-white border border-slate-300 rounded-lg text-xs"
                  />
                </div>

                <div className="pt-2">
                  <button
                    type="submit"
                    className="w-full py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg shadow-sm flex items-center justify-center gap-1.5 text-xs"
                  >
                    <Send size={13} />
                    Confirm & Submit Request
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Screen 3: Request Detail View */}
          {screen === 'detail' && selectedReq && (
            <div className="flex-1 overflow-y-auto p-4 space-y-3.5 text-xs">
              <div className="bg-white p-3.5 rounded-xl border border-slate-200 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-mono font-bold text-indigo-600">{selectedReq.requestNumber}</span>
                  <span className="font-bold uppercase text-[10px] px-2 py-0.5 rounded bg-indigo-50 text-indigo-700">
                    {selectedReq.status.replace('_', ' ')}
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm">{selectedReq.title}</h3>
                <p className="text-slate-600 text-[11px] leading-relaxed">{selectedReq.description}</p>
              </div>

              {/* Assigned Agent */}
              <div className="bg-white p-3.5 rounded-xl border border-slate-200">
                <div className="font-bold text-slate-700 mb-1 text-[11px] uppercase tracking-wider">
                  Assigned Technician
                </div>
                {selectedReq.agentName ? (
                  <div className="flex items-center space-x-2 text-slate-800">
                    <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center font-bold text-xs">
                      {selectedReq.agentName.charAt(0)}
                    </div>
                    <div>
                      <div className="font-bold text-xs">{selectedReq.agentName}</div>
                      <div className="text-[10px] text-slate-500">{selectedReq.agentPhone || 'Certified Specialist'}</div>
                    </div>
                  </div>
                ) : (
                  <div className="text-slate-400 italic text-xs">Dispatch team is assigning an agent.</div>
                )}
              </div>

              {/* Technician Notes */}
              {selectedReq.agentNotes && (
                <div className="bg-emerald-50 border border-emerald-200 p-3 rounded-xl text-emerald-900">
                  <div className="font-bold text-[11px] uppercase tracking-wider mb-1">
                    Technician Work Notes
                  </div>
                  <p className="text-[11px] leading-relaxed">{selectedReq.agentNotes}</p>
                </div>
              )}

              {/* Cancellation */}
              {selectedReq.status === 'CREATED' || selectedReq.status === 'ASSIGNED' ? (
                <button
                  onClick={() => setShowCancelPrompt(true)}
                  className="w-full py-2 border border-rose-300 text-rose-600 hover:bg-rose-50 font-bold rounded-lg text-xs"
                >
                  Cancel Service Request
                </button>
              ) : selectedReq.status === 'CANCELLED' ? (
                <div className="bg-rose-50 border border-rose-200 p-3 rounded-xl text-rose-800 text-xs">
                  <strong>Cancellation Reason:</strong> {selectedReq.cancellationReason || 'Cancelled by user'}
                </div>
              ) : null}
            </div>
          )}

          {/* Cancellation Dialog inside Phone */}
          {showCancelPrompt && (
            <div className="absolute inset-0 bg-slate-900/60 z-40 flex items-center justify-center p-4">
              <div className="bg-white rounded-xl p-4 w-full text-xs space-y-3 shadow-xl">
                <h4 className="font-bold text-slate-900">Cancel Request?</h4>
                <p className="text-slate-600 text-[11px]">
                  Please specify why you wish to cancel this ticket.
                </p>
                <textarea
                  value={cancellationReason}
                  onChange={(e) => setCancellationReason(e.target.value)}
                  placeholder="e.g. Problem resolved, change of plan..."
                  rows={2}
                  className="w-full p-2 border border-slate-300 rounded-lg text-xs"
                />
                <div className="flex justify-end space-x-2">
                  <button
                    onClick={() => setShowCancelPrompt(false)}
                    className="px-3 py-1 text-slate-600 hover:bg-slate-100 rounded"
                  >
                    Back
                  </button>
                  <button
                    onClick={handleCancel}
                    disabled={!cancellationReason.trim()}
                    className="px-3 py-1 bg-rose-600 text-white font-bold rounded disabled:opacity-50"
                  >
                    Confirm Cancel
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
