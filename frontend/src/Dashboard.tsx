import React, { useState, useEffect } from 'react';
import { Zap, Target, ShoppingCart, BarChart3, Smartphone, RotateCcw, Activity, CheckCircle2, Copy, Trash2, Settings } from 'lucide-react';

interface DashboardEvent {
    timestamp: string;
    type: 'success' | 'error' | 'warning' | 'info';
    description: string;
}

const Dashboard = () => {
    const [earnings, setEarnings] = useState(0);
    const [messagesSent, setMessagesSent] = useState(0);
    const [cartsDetected, setCartsDetected] = useState(0);
    const [waStatus, setWaStatus] = useState('disconnected');
    const [events, setEvents] = useState<DashboardEvent[]>([]);
    const [copiedUrl, setCopiedUrl] = useState(false);
    const [isGrowthActive, setIsGrowthActive] = useState(false);
    const [leads, setLeads] = useState<any[]>([]);
    const [newLeadName, setNewLeadName] = useState('');
    const [newLeadPhone, setNewLeadPhone] = useState('');
    const [templates, setTemplates] = useState<any>({
        sales: {
            es: ["Hola {{name}}, vi tu interés en nuestros productos. ¿Te puedo ayudar?"],
            en: ["Hi {{name}}, saw you were interested. Can I help?"],
            pt: ["Olá {{name}}, vi seu interesse. Posso ajudar?"]
        },
        recovery: {
            es: "Hola {{name}}, notamos que dejaste compras pendientes. Retómalo aquí: {{link}}",
            en: "Hi {{name}}, you left items behind. Resume here: {{link}}",
            pt: "Olá {{name}}, você deixou itens para trás. Retome aqui: {{link}}"
        }
    });
    const [activeTab, setActiveTab] = useState<'home' | 'connections' | 'sales' | 'recovery' | 'settings'>('home');
    const [parsedTick, setParsedTick] = useState(0);
    const [pairingPhone, setPairingPhone] = useState('');
    const [pairingCode, setPairingCode] = useState('');
    const [isPairing, setIsPairing] = useState(false);

    // URL del Backend (Cerebro) en Render
    const API_BASE = 'https://recoverai-bot.onrender.com/api';

    // Fetch stats and status from backend
    useEffect(() => {
        const fetchData = async () => {
            try {
                // Fetch Stats & Events
                const statsResponse = await fetch(`${API_BASE}/stats`);
                const statsData = await statsResponse.json();
                setEarnings(statsData.earnings);
                setMessagesSent(statsData.messagesSent);
                setCartsDetected(statsData.cartsDetected);
                setEvents(statsData.events || []);

                // Fetch Global Status
                const statusResponse = await fetch(`${API_BASE}/whatsapp-status`);
                const statusData = await statusResponse.json();
                setWaStatus(statusData.status || 'disconnected');

                // Fetch Growth Status
                const growthResponse = await fetch(`${API_BASE}/growth/status`);
                const growthData = await growthResponse.json();
                setIsGrowthActive(growthData.active);
                setLeads(growthData.leads || []);

                // Fetch Templates
                const templatesRes = await fetch(`${API_BASE}/templates`);
                const templatesData = await templatesRes.json();
                setTemplates(templatesData);
            } catch (error) {
                console.error('Error fetching dashboard data:', error);
            }
        };

        fetchData();
        fetchData();
        const interval = setInterval(() => {
            fetchData();
            setParsedTick(prev => prev + 1);
        }, 3000); // Poll every 3 seconds
        return () => clearInterval(interval);
    }, []);

    const toggleGrowth = async () => {
        if (waStatus !== 'connected') {
            alert('❌ Conecta WhatsApp primero.');
            return;
        }
        try {
            const response = await fetch(`${API_BASE}/growth/toggle`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ active: !isGrowthActive })
            });
            const data = await response.json();
            setIsGrowthActive(data.active);
        } catch (error) {
            console.error('Error toggling growth:', error);
        }
    };

    const resetStats = async () => {
        if (window.confirm('¿Estás seguro de que quieres reiniciar todas las estadísticas a 0?')) {
            try {
                await fetch(`${API_BASE}/reset-stats`, { method: 'POST' });
                alert('Estadísticas reiniciadas ✅');
            } catch (error) { alert('Error al reiniciar estadísticas ❌'); }
        }
    };

    const resetLeads = async () => {
        if (!window.confirm('¿Reiniciar todos los prospectos a estado "Pendiente"?')) return;
        try {
            const res = await fetch(`${API_BASE}/growth/reset-leads`, { method: 'POST' });
            if (res.ok) {
                const growthResponse = await fetch(`${API_BASE}/growth/status`);
                const growthData = await growthResponse.json();
                setLeads(growthData.leads || []);
                alert('Prospectos reiniciados correctamente 🔄');
            }
        } catch (e) { alert('Error de conexión'); }
    };

    const handleAddLead = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newLeadName || !newLeadPhone) return alert('Completa nombre y teléfono');

        try {
            const res = await fetch(`${API_BASE}/growth/add-lead`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name: newLeadName, phone: newLeadPhone })
            });

            const data = await res.json();

            if (res.ok) {
                setLeads([...leads, data.lead]);
                setNewLeadName('');
                setNewLeadPhone('');
                alert('Prospecto agregado ✅');
            } else {
                alert('Error: ' + data.error);
            }
        } catch (e) { alert('Error de conexión al servidor'); }
    };

    const deleteLead = async (phone: string) => {
        if (!confirm('¿Seguro deseas eliminar este lead?')) return;
        try {
            await fetch(`${API_BASE}/growth/lead/` + encodeURIComponent(phone), { method: 'DELETE' });

            // Refresh list
            const growthResponse = await fetch(`${API_BASE}/growth/status`);
            const growthData = await growthResponse.json();
            setLeads(growthData.leads || []);
        } catch (error) {
            console.error('Error deleting lead:', error);
        }
    };

    const saveTemplates = async () => {
        try {
            await fetch(`${API_BASE}/templates`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(templates)
            });
            alert('Configuración guardada ✅');
        } catch (e) { alert('Error al guardar'); }
    };

    const requestPairing = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!pairingPhone) return alert('Ingresa tu número');
        setIsPairing(true);
        try {
            const res = await fetch(`${API_BASE}/pair-channel`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ phone: pairingPhone })
            });
            const data = await res.json();
            if (data.success && data.code) {
                setPairingCode(data.code);
            } else {
                alert('Error: ' + (data.error || 'No se pudo generar código'));
            }
        } catch (err) { alert('Error de conexión'); }
        setIsPairing(false);
    };

    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [passwordInput, setPasswordInput] = useState('');

    if (!isAuthenticated) {
        return (
            <div className="min-h-screen bg-black flex items-center justify-center p-4">
                <div className="bg-gray-900 border border-gray-800 p-8 rounded-2xl shadow-2xl max-w-sm w-full">
                    <div className="flex justify-center mb-6">
                        <Zap className="text-green-500" size={48} />
                    </div>
                    <h2 className="text-2xl font-bold text-white text-center mb-6">RecoverAI Admin</h2>
                    <form onSubmit={(e) => {
                        e.preventDefault();
                        // Get password from Vercel Environment or use Master Default
                        const masterKey = import.meta.env.VITE_ADMIN_PASSWORD || 'Pr5refux';

                        if (passwordInput === masterKey) {
                            setIsAuthenticated(true);
                        } else {
                            alert('Contraseña Incorrecta');
                        }
                    }}>
                        <input
                            type="password"
                            placeholder="Contraseña Maestro"
                            value={passwordInput}
                            onChange={(e) => setPasswordInput(e.target.value)}
                            className="w-full bg-black border border-gray-700 rounded-lg px-4 py-3 text-white mb-4 focus:border-green-500 outline-none"
                        />
                        <button type="submit" className="w-full bg-green-600 hover:bg-green-500 text-white font-bold py-3 rounded-lg transition-colors">
                            Entrar
                        </button>
                    </form>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-black text-white font-sans selection:bg-green-500 selection:text-black">
            {/* Navbar */}
            <nav className="border-b border-gray-800 bg-gray-900/50 backdrop-blur-md sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between h-16">
                        <div className="flex items-center">
                            <Zap className="text-green-500 mr-2" fill="currentColor" size={24} />
                            <span className="text-2xl font-bold bg-gradient-to-r from-green-400 to-emerald-600 text-transparent bg-clip-text">
                                RecoverAI <span className="text-xs font-mono text-gray-500 border border-gray-700 rounded px-1 ml-1 align-top">PRO</span>
                            </span>
                        </div>
                        <div className="flex space-x-1 bg-gray-900/80 p-1 rounded-lg border border-gray-800 overflow-x-auto custom-scrollbar">
                            {[
                                { id: 'home', icon: BarChart3, label: 'Inicio' },
                                { id: 'connections', icon: Smartphone, label: 'Conexión' },
                                { id: 'sales', icon: Target, label: 'Ventas' },
                                { id: 'recovery', icon: ShoppingCart, label: 'Recuperación' },
                                { id: 'settings', icon: Settings, label: 'Configuración' }
                            ].map((tab) => (
                                <button
                                    key={tab.id}
                                    onClick={() => setActiveTab(tab.id as any)}
                                    className={`flex items-center px-4 py-2 rounded-md text-sm font-medium transition-all ${activeTab === tab.id
                                        ? 'bg-gray-800 text-white shadow-lg'
                                        : 'text-gray-400 hover:text-white hover:bg-gray-800/50'
                                        }`}
                                >
                                    <tab.icon size={16} className="mr-2" />
                                    {tab.label}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>
            </nav>

            {/* Main Content */}
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

                {activeTab === 'home' && (
                    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                        <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div>
                                <h1 className="text-3xl font-bold text-white tracking-tight">Panel General</h1>
                                <p className="text-gray-400 mt-1">Resumen de rendimiento de tu Asistente IA.</p>
                            </div>
                            <div className="flex items-center space-x-3">
                                <span className={`px-3 py-1 rounded-full text-xs font-bold border ${waStatus === 'connected' ? 'bg-green-500/10 border-green-500/30 text-green-500' : 'bg-red-500/10 border-red-500/30 text-red-500'}`}>
                                    {waStatus === 'connected' ? '● SISTEMA ONLINE' : '● SISTEMA OFFLINE'}
                                </span>
                                <button onClick={resetStats} className="flex items-center px-4 py-2 bg-red-500/10 hover:bg-red-500/20 text-red-500 border border-red-500/20 rounded-lg transition-all text-sm font-medium">
                                    <RotateCcw size={16} className="mr-2" /> Reiniciar Todo
                                </button>
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <div className="bg-gray-900/50 border border-gray-800 rounded-xl p-6">
                                <p className="text-gray-400 text-sm mb-1">Ingresos Totales</p>
                                <p className="text-4xl font-bold text-white">${earnings.toLocaleString()}</p>
                            </div>
                            <div className="bg-gray-900/50 border border-gray-800 rounded-xl p-6">
                                <p className="text-gray-400 text-sm mb-1">Mensajes Totales</p>
                                <p className="text-4xl font-bold text-white">{messagesSent}</p>
                            </div>
                            <div className="bg-gray-900/50 border border-gray-800 rounded-xl p-6">
                                <p className="text-gray-400 text-sm mb-1">Carritos Reportados</p>
                                <p className="text-4xl font-bold text-white">{cartsDetected}</p>
                            </div>
                        </div>

                        <div className="bg-gray-900 border border-gray-800 rounded-xl flex flex-col h-[400px]">
                            <div className="p-6 border-b border-gray-800 flex items-center justify-between">
                                <h3 className="font-bold text-white">Log de Actividad</h3>
                                <Activity size={16} className="text-gray-500" />
                            </div>
                            <div className="flex-1 overflow-y-auto p-4 space-y-4 custom-scrollbar">
                                {events.map((event, idx) => (
                                    <div key={idx} className="flex space-x-3 items-start p-3 bg-black/40 rounded-lg border border-gray-800">
                                        <div className={`mt-1 h-2 w-2 rounded-full shrink-0 ${event.type === 'success' ? 'bg-green-500' : event.type === 'error' ? 'bg-red-500' : 'bg-blue-500'
                                            }`} />
                                        <div className="flex-1 min-w-0">
                                            <p className="text-xs text-white opacity-80">{event.description}</p>
                                            <p className="text-[10px] text-gray-500 mt-1">{new Date(event.timestamp).toLocaleTimeString()}</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'connections' && (
                    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500 flex flex-col items-center justify-center min-h-[500px]">
                        <h2 className="text-3xl font-bold mb-8">Conectar Asistente</h2>

                        <div className="bg-gray-900 border border-gray-800 rounded-2xl p-8 flex flex-col items-center text-center max-w-md w-full shadow-2xl">
                            <div className={`w-20 h-20 rounded-full flex items-center justify-center mb-6 ${waStatus === 'connected' ? 'bg-green-500/20 text-green-500' : 'bg-gray-800 text-gray-500'
                                }`}>
                                <Smartphone size={40} />
                            </div>

                            <h3 className="text-2xl font-bold text-white mb-2">WhatsApp Web</h3>
                            <p className={`text-sm font-medium mb-6 uppercase tracking-wider ${waStatus === 'connected' ? 'text-green-400' : 'text-yellow-500'
                                }`}>
                                {waStatus === 'connected' ? '● Conectado y Listo' : '● Esperando Escaneo'}
                            </p>

                            <div className="bg-white p-2 rounded-xl border-4 border-gray-800 w-64 h-64 flex items-center justify-center relative overflow-hidden mb-6">
                                {waStatus === 'connected' ? (
                                    <CheckCircle2 size={80} className="text-green-500" />
                                ) : (
                                    <img
                                        src={`${API_BASE}/qr-image?t=${parsedTick}`}
                                        alt="QR Code"
                                        className="w-full h-full object-contain"
                                        style={{ imageRendering: 'pixelated' }}
                                        onError={(e) => {
                                            const parent = e.currentTarget.parentElement;
                                            if (parent) {
                                                e.currentTarget.style.display = 'none';
                                                parent.textContent = 'Cargando nuevo QR...';
                                            }
                                        }}
                                    />
                                )}
                            </div>

                            <p className="text-sm text-gray-500 mb-4">
                                {waStatus === 'connected'
                                    ? 'Tu asistente está activo y funcionando. La imagen de perfil se actualizó automáticamente.'
                                    : 'Abre WhatsApp en tu celular > Dispositivos Vinculados > Vincular Dispositivo'}
                            </p>

                            {waStatus !== 'connected' && (
                                <button
                                    onClick={async () => {
                                        if (!confirm('¿Reiniciar Bot para generar nuevo QR?')) return;
                                        try {
                                            await fetch(`${API_BASE}/restart-bot`, { method: 'POST' });
                                            alert('Reiniciando... Espera 20 segundos.');
                                            window.location.reload();
                                        } catch (e) { alert('Error al reiniciar'); }
                                    }}
                                    className="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-white rounded text-xs font-bold border border-gray-600"
                                >
                                    🔄 Regenerar QR (Si no carga)
                                </button>
                            )}
                        </div>

                        {/* Pairing Code Section */}
                        {waStatus !== 'connected' && (
                            <div className="bg-gray-900 border border-gray-800 rounded-2xl p-6 mt-6 max-w-md w-full text-center">
                                <h3 className="font-bold text-white mb-4">¿Problemas con el QR?</h3>
                                {!pairingCode ? (
                                    <form onSubmit={requestPairing} className="flex gap-2">
                                        <input
                                            type="text"
                                            placeholder="Tu Número (ej: 57300...)"
                                            value={pairingPhone}
                                            onChange={e => setPairingPhone(e.target.value)}
                                            className="flex-1 bg-black border border-gray-700 rounded px-3 py-2 text-white"
                                        />
                                        <button disabled={isPairing} type="submit" className="bg-blue-600 hover:bg-blue-500 text-white px-4 rounded font-bold">
                                            {isPairing ? '...' : 'Pedir Código'}
                                        </button>
                                    </form>
                                ) : (
                                    <div className="animate-in zoom-in duration-300">
                                        <p className="text-gray-400 text-sm mb-2">Ingresa este código en tu celular:</p>
                                        <div className="text-4xl font-mono font-bold text-yellow-400 bg-black/50 p-4 rounded-xl border border-yellow-500/30 tracking-widest">
                                            {pairingCode}
                                        </div>
                                        <button onClick={() => setPairingCode('')} className="text-xs text-gray-500 mt-4 underline">Intentar con otro número</button>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                )}
                {activeTab === 'sales' && (
                    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                            <div className="lg:col-span-2">
                                <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 mb-6">
                                    <div className="flex items-center justify-between mb-4">
                                        <h3 className="text-xl font-bold flex items-center"><Target className="mr-2 text-purple-500" /> Motor de Crecimiento (Ventas)</h3>
                                        <button
                                            onClick={toggleGrowth}
                                            className={`px-4 py-2 rounded-lg font-bold transition-all ${isGrowthActive ? 'bg-green-500 text-black' : 'bg-gray-700 text-white'
                                                }`}
                                        >
                                            {isGrowthActive ? 'ACTIVO' : 'INACTIVO'}
                                        </button>
                                    </div>
                                    <p className="text-gray-400 text-sm">Este bot busca clientes potenciales automáticamente usando tu número conectado.</p>
                                </div>

                                <div className="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden">
                                    <div className="p-6 border-b border-gray-800 flex items-center justify-between">
                                        <h3 className="font-bold">Lista de Prospectos</h3>
                                        <button onClick={resetLeads} className="text-xs bg-gray-800 px-3 py-1 rounded hover:bg-gray-700">Resetear Lista</button>
                                    </div>
                                    <div className="p-4 border-b border-gray-800 bg-black/20">
                                        <form onSubmit={handleAddLead} className="flex gap-2">
                                            <input
                                                type="text"
                                                placeholder="Nombre Cliente"
                                                value={newLeadName}
                                                onChange={e => setNewLeadName(e.target.value)}
                                                className="flex-1 bg-gray-800 border border-gray-700 rounded px-3 py-2 text-sm text-white focus:border-green-500 outline-none"
                                            />
                                            <input
                                                type="text"
                                                placeholder="Teléfono (ej: 573...)"
                                                value={newLeadPhone}
                                                onChange={e => setNewLeadPhone(e.target.value)}
                                                className="flex-1 bg-gray-800 border border-gray-700 rounded px-3 py-2 text-sm text-white focus:border-green-500 outline-none"
                                            />
                                            <button type="submit" className="bg-green-600 hover:bg-green-500 text-white px-4 rounded font-bold text-sm">
                                                + Agregar
                                            </button>
                                        </form>
                                        <table className="w-full text-left text-sm">
                                            <thead className="bg-black/20 text-gray-500 uppercase text-xs">
                                                <tr>
                                                    <th className="px-6 py-3">Nombre</th>
                                                    <th className="px-6 py-3">Teléfono</th>
                                                    <th className="px-6 py-3">Estado</th>
                                                    <th className="px-6 py-3">Acción</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-800">
                                                {leads.map((lead, i) => (
                                                    <tr key={i} className="hover:bg-white/5">
                                                        <td className="px-6 py-3 font-medium">{lead.name}</td>
                                                        <td className="px-6 py-3 text-gray-400">{lead.phone}</td>
                                                        <td className="px-6 py-3">
                                                            <span className={`px-2 py-1 rounded text-[10px] font-bold ${lead.status === 'pending' ? 'bg-yellow-500/20 text-yellow-500' :
                                                                lead.status === 'contacted' ? 'bg-green-500/20 text-green-500' : 'bg-red-500/20 text-red-500'
                                                                }`}>{lead.status}</span>
                                                        </td>
                                                        <td className="px-6 py-3">
                                                            <button
                                                                onClick={() => deleteLead(lead.phone)}
                                                                className="text-red-400 hover:text-red-300 hover:bg-red-900/20 p-2 rounded transition-colors"
                                                                title="Eliminar"
                                                            >
                                                                <Trash2 size={16} />
                                                            </button>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-6">
                                <div className={`border border-gray-800 rounded-xl p-6 transition-all ${isGrowthActive ? 'bg-green-900/10 border-green-500/50' : 'bg-gray-900'}`}>
                                    <h3 className="font-bold mb-2">⚡ Auto-Piloto (Buscador IA / AI Search)</h3>
                                    <p className="text-xs text-gray-500 mb-4">
                                        The system will search for customers worldwide (Google/Bing) and contact them automatically. <br />
                                        <span className="opacity-70">El sistema buscará clientes en todo el mundo y los contactará automáticamente.</span>
                                    </p>

                                    <div className="flex items-center justify-between bg-black/40 p-3 rounded-lg border border-gray-700">
                                        <div className="flex items-center">
                                            <div className={`w-3 h-3 rounded-full mr-2 ${isGrowthActive ? 'bg-green-500 animate-pulse' : 'bg-gray-500'}`}></div>
                                            <span className="text-sm font-medium text-gray-300">
                                                {isGrowthActive ? 'Searching / Buscando...' : 'Idle / En Reposo'}
                                            </span>
                                        </div>
                                        <button
                                            onClick={toggleGrowth}
                                            className={`px-4 py-2 rounded-lg font-bold text-xs transition-all ${isGrowthActive
                                                ? 'bg-red-500/20 text-red-400 hover:bg-red-500/30'
                                                : 'bg-green-600 hover:bg-green-500 text-white shadow-lg shadow-green-900/20'
                                                }`}
                                        >
                                            {isGrowthActive ? 'STOP / DETENER' : 'START AUTO-PILOT'}
                                        </button>
                                    </div>
                                    {isGrowthActive && (
                                        <div className="mt-3 text-[10px] text-green-400 font-mono">
                                            {'>'} Scanning Global Market: "boutiques..."
                                        </div>
                                    )}
                                </div>

                                <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
                                    <h3 className="font-bold mb-4">Prueba Rápida / Quick Test</h3>
                                    <button
                                        onClick={async () => {
                                            try { await fetch(`${API_BASE}/growth/test-me`, { method: 'POST' }); alert('✅ Enviado'); }
                                            catch { alert('Error'); }
                                        }}
                                        className="w-full py-3 bg-purple-600 hover:bg-purple-500 rounded-lg font-bold mb-3"
                                    >
                                        Probar conmigo (Dueño)
                                    </button>
                                    <div className="text-xs text-gray-500 text-center">Envía un pitch de venta a tu número personal.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                )
                }

                {
                    activeTab === 'recovery' && (
                        <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                            <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 mb-6">
                                <h3 className="text-xl font-bold flex items-center mb-4"><ShoppingCart className="mr-2 text-green-500" /> Recuperación de Carritos</h3>
                                <p className="text-gray-400 text-sm mb-6">Tu asistente contactará automáticamente a quienes abandonen el carrito.</p>

                                <div className="space-y-4 max-w-2xl">
                                    <div>
                                        <label className="text-sm text-gray-400 mb-1 block">Webhook URL (Shopify/WooCommerce)</label>
                                        <div className="flex bg-black border border-gray-800 rounded-lg overflow-hidden">
                                            <input readOnly value={`${API_BASE}/abandoned-cart`} className="bg-transparent flex-1 px-4 py-2 text-sm text-gray-300 outline-none" />
                                            <button onClick={() => { navigator.clipboard.writeText(`${API_BASE}/abandoned-cart`); setCopiedUrl(true); setTimeout(() => setCopiedUrl(false), 2000); }} className="px-4 bg-gray-800 hover:bg-gray-700 transition-colors border-l border-gray-700">
                                                {copiedUrl ? <CheckCircle2 size={16} className="text-green-500" /> : <Copy size={16} />}
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div className="bg-indigo-900/10 border border-indigo-500/30 rounded-xl p-6">
                                <h3 className="font-bold mb-4 text-indigo-400">Simulador de Carrito Abandonado</h3>
                                <div className="flex gap-4">
                                    <div className="flex-1 flex gap-2">
                                        <input id="recovery-phone" type="text" placeholder="Número (ej: 57...)" className="flex-1 bg-black border border-indigo-500/30 rounded px-4 py-2" />
                                        <input id="recovery-url" type="text" placeholder="Link Tienda (ej: mitienda.com)" className="flex-1 bg-black border border-indigo-500/30 rounded px-4 py-2" />
                                    </div>
                                    <button
                                        onClick={async () => {
                                            const phone = (document.getElementById('recovery-phone') as HTMLInputElement).value;
                                            const urlOverride = (document.getElementById('recovery-url') as HTMLInputElement).value;
                                            if (!phone) return alert('Ingresa número');
                                            try { await fetch(`${API_BASE}/test-recovery-custom`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ phone, urlOverride }) }); alert('✅ Enviado'); }
                                            catch { alert('Error'); }
                                        }}
                                        className="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 rounded font-bold"
                                    >
                                        Enviar Recuperación
                                    </button>
                                </div>
                            </div>
                        </div>
                    )
                }

                {
                    activeTab === 'settings' && templates && (
                        <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                            <div className="flex justify-between items-center mb-6">
                                <h2 className="text-2xl font-bold">Configuración de Mensajes</h2>
                                <button onClick={saveTemplates} className="bg-green-600 hover:bg-green-500 px-6 py-2 rounded-lg font-bold flex items-center">
                                    <CheckCircle2 size={18} className="mr-2" />
                                    Guardar Cambios
                                </button>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                                {/* Sales Templates */}
                                <div className="space-y-6">
                                    <h3 className="text-xl font-bold flex items-center text-purple-400"><Target className="mr-2" /> Mensajes de Ventas</h3>

                                    <div className="bg-gray-900 p-4 rounded-xl border border-gray-800">
                                        <label className="text-sm text-gray-400 mb-2 block font-bold">Español (ES)</label>
                                        <textarea
                                            className="w-full bg-black border border-gray-700 rounded p-3 text-sm text-gray-300 h-32 focus:border-green-500 outline-none"
                                            value={templates.sales.es[0]}
                                            onChange={(e) => {
                                                const newEs = [...templates.sales.es];
                                                newEs[0] = e.target.value;
                                                setTemplates({ ...templates, sales: { ...templates.sales, es: newEs } });
                                            }}
                                        />
                                        <p className="text-xs text-gray-600 mt-1">Usa {"{{name}}"} para el nombre y {"{{link}}"} para el enlace.</p>
                                    </div>

                                    <div className="bg-gray-900 p-4 rounded-xl border border-gray-800">
                                        <label className="text-sm text-gray-400 mb-2 block font-bold">Inglés (EN) - Global</label>
                                        <textarea
                                            className="w-full bg-black border border-gray-700 rounded p-3 text-sm text-gray-300 h-32 focus:border-green-500 outline-none"
                                            value={templates.sales.en[0]}
                                            onChange={(e) => {
                                                const newEn = [...templates.sales.en];
                                                newEn[0] = e.target.value;
                                                setTemplates({ ...templates, sales: { ...templates.sales, en: newEn } });
                                            }}
                                        />
                                    </div>

                                    <div className="bg-gray-900 p-4 rounded-xl border border-gray-800">
                                        <label className="text-sm text-gray-400 mb-2 block font-bold">Portugués (PT) - Brasil</label>
                                        <textarea
                                            className="w-full bg-black border border-gray-700 rounded p-3 text-sm text-gray-300 h-32 focus:border-green-500 outline-none"
                                            value={templates.sales.pt[0]}
                                            onChange={(e) => {
                                                const newPt = [...templates.sales.pt];
                                                newPt[0] = e.target.value;
                                                setTemplates({ ...templates, sales: { ...templates.sales, pt: newPt } });
                                            }}
                                        />
                                    </div>
                                </div>

                                {/* Recovery Templates */}
                                <div className="space-y-6">
                                    <h3 className="text-xl font-bold flex items-center text-green-400"><ShoppingCart className="mr-2" /> Recuperación de Carrito</h3>

                                    <div className="bg-gray-900 p-4 rounded-xl border border-gray-800">
                                        <label className="text-sm text-gray-400 mb-2 block font-bold">Español (ES)</label>
                                        <textarea
                                            className="w-full bg-black border border-gray-700 rounded p-3 text-sm text-gray-300 h-24 focus:border-green-500 outline-none"
                                            value={templates.recovery.es}
                                            onChange={(e) => setTemplates({ ...templates, recovery: { ...templates.recovery, es: e.target.value } })}
                                        />
                                    </div>

                                    <div className="bg-gray-900 p-4 rounded-xl border border-gray-800">
                                        <label className="text-sm text-gray-400 mb-2 block font-bold">Inglés (EN)</label>
                                        <textarea
                                            className="w-full bg-black border border-gray-700 rounded p-3 text-sm text-gray-300 h-24 focus:border-green-500 outline-none"
                                            value={templates.recovery.en}
                                            onChange={(e) => setTemplates({ ...templates, recovery: { ...templates.recovery, en: e.target.value } })}
                                        />
                                    </div>

                                    <div className="bg-gray-900 p-4 rounded-xl border border-gray-800">
                                        <label className="text-sm text-gray-400 mb-2 block font-bold">Portugués (PT)</label>
                                        <textarea
                                            className="w-full bg-black border border-gray-700 rounded p-3 text-sm text-gray-300 h-24 focus:border-green-500 outline-none"
                                            value={templates.recovery.pt}
                                            onChange={(e) => setTemplates({ ...templates, recovery: { ...templates.recovery, pt: e.target.value } })}
                                        />
                                        <p className="text-xs text-gray-600 mt-1">Se selecciona automáticamente según el código de país del cliente.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )
                }
            </main >
        </div >
    );
};

export default Dashboard;
