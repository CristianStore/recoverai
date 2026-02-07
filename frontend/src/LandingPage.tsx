
import { Zap, Bot, ShieldCheck, TrendingUp, ChevronRight, Check } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const LandingPage = () => {
    const navigate = useNavigate();

    return (
        <div className="min-h-screen bg-black text-white font-sans selection:bg-green-500 selection:text-black overflow-hidden">
            {/* Navbar */}
            <nav className="fixed w-full z-50 bg-black/50 backdrop-blur-lg border-b border-white/10">
                <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <Zap className="text-green-500" fill="currentColor" size={28} />
                        <span className="text-2xl font-bold tracking-tight">RecoverAI</span>
                    </div>
                    <div className="hidden md:flex items-center gap-8 text-sm font-medium text-gray-300">
                        <a href="#features" className="hover:text-white transition-colors">Características</a>
                        <a href="#pricing" className="hover:text-white transition-colors">Precios</a>
                        <button
                            onClick={() => navigate('/dashboard')}
                            className="bg-white/10 hover:bg-white/20 px-5 py-2 rounded-full text-white transition-all border border-white/10"
                        >
                            Acceso Clientes
                        </button>
                    </div>
                </div>
            </nav>

            {/* Hero Section */}
            <section className="relative pt-32 pb-20 px-6 overflow-hidden">
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[500px] bg-green-500/20 blur-[120px] rounded-full pointer-events-none" />

                <div className="max-w-4xl mx-auto text-center relative z-10">
                    <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-500/10 border border-green-500/20 text-green-400 text-sm font-medium mb-8 animate-fade-in-up">
                        <Bot size={16} />
                        <span>IA Revolucionaria para WhatsApp</span>
                    </div>

                    <h1 className="text-5xl md:text-7xl font-bold tracking-tighter mb-8 leading-tight bg-gradient-to-b from-white to-gray-400 text-transparent bg-clip-text">
                        Recupera el <span className="text-green-500">30% de tus ventas</span> automáticamente.
                    </h1>

                    <p className="text-xl text-gray-400 mb-12 max-w-2xl mx-auto leading-relaxed">
                        El primer empleado virtual que trabaja 24/7. Detecta carritos abandonados, contacta clientes y cierra ventas por WhatsApp sin que muevas un dedo.
                    </p>

                    <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                        <button className="w-full sm:w-auto px-8 py-4 bg-green-600 hover:bg-green-500 text-black font-bold rounded-full text-lg transition-all transform hover:scale-105 flex items-center justify-center gap-2 shadow-lg shadow-green-900/50">
                            Empezar Prueba Gratis
                            <ChevronRight size={20} />
                        </button>
                        <button onClick={() => navigate('/dashboard')} className="w-full sm:w-auto px-8 py-4 bg-white/5 hover:bg-white/10 text-white font-medium rounded-full text-lg transition-all border border-white/10">
                            Ver Demo en Vivo
                        </button>
                    </div>
                </div>
            </section>

            {/* Stats Section */}
            <section className="py-20 border-y border-white/5 bg-white/[0.02]">
                <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-12 text-center">
                    <div>
                        <p className="text-5xl font-bold text-white mb-2">+45%</p>
                        <p className="text-gray-400">Tasa de Apertura</p>
                    </div>
                    <div>
                        <p className="text-5xl font-bold text-white mb-2">24/7</p>
                        <p className="text-gray-400">Funcionamiento Automático</p>
                    </div>
                    <div>
                        <p className="text-5xl font-bold text-white mb-2">x10</p>
                        <p className="text-gray-400">ROI Promedio</p>
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section id="features" className="py-32 px-6">
                <div className="max-w-7xl mx-auto">
                    <h2 className="text-3xl md:text-5xl font-bold text-center mb-20">Todo lo que necesitas para crecer</h2>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        {[
                            {
                                icon: ShieldCheck,
                                title: "Cero Bloqueos",
                                desc: "Tecnología anti-ban con rotación de IPs y simulación humana."
                            },
                            {
                                icon: Zap,
                                title: "Respuesta Inmediata",
                                desc: "Contacta al cliente 2 minutos después de abandonar el carrito."
                            },
                            {
                                icon: TrendingUp,
                                title: "Motor de Crecimiento",
                                desc: "Busca nuevos clientes potenciales en Google y los contacta por ti."
                            }
                        ].map((feature, i) => (
                            <div key={i} className="p-8 rounded-3xl bg-white/5 border border-white/10 hover:border-green-500/50 transition-all group">
                                <div className="w-14 h-14 bg-green-500/10 rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                                    <feature.icon className="text-green-500" size={28} />
                                </div>
                                <h3 className="text-xl font-bold mb-4">{feature.title}</h3>
                                <p className="text-gray-400 leading-relaxed">{feature.desc}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Pricing Section */}
            <section id="pricing" className="py-32 px-6 relative">
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-purple-500/10 blur-[150px] rounded-full pointer-events-none" />

                <div className="max-w-7xl mx-auto relative z-10">
                    <h2 className="text-3xl md:text-5xl font-bold text-center mb-6">Planes Simples</h2>
                    <p className="text-center text-gray-400 mb-20 max-w-xl mx-auto">Comienza gratis. Paga solo cuando veas resultados.</p>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
                        {/* Starter */}
                        <div className="p-8 rounded-3xl bg-black border border-white/10 flex flex-col">
                            <h3 className="text-xl font-medium text-gray-400 mb-2">Starter</h3>
                            <div className="flex items-baseline gap-1 mb-6">
                                <span className="text-4xl font-bold text-white">$29</span>
                                <span className="text-gray-500">/mes</span>
                            </div>
                            <ul className="space-y-4 mb-8 flex-1">
                                {['100 Mensajes/mes', 'Recuperación Básica', 'Panel de Control'].map(item => (
                                    <li key={item} className="flex items-center gap-3 text-sm text-gray-300">
                                        <Check size={16} className="text-green-500" /> {item}
                                    </li>
                                ))}
                            </ul>
                            <button className="w-full py-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 font-bold transition-all">Elegir Plan</button>
                        </div>

                        {/* Pro */}
                        <div className="p-8 rounded-3xl bg-green-900/10 border border-green-500 relative flex flex-col transform md:-translate-y-4">
                            <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-green-500 text-black text-xs font-bold px-3 py-1 rounded-full uppercase">Más Popular</div>
                            <h3 className="text-xl font-medium text-green-400 mb-2">Pro Growth</h3>
                            <div className="flex items-baseline gap-1 mb-6">
                                <span className="text-4xl font-bold text-white">$79</span>
                                <span className="text-gray-500">/mes</span>
                            </div>
                            <ul className="space-y-4 mb-8 flex-1">
                                {['Mensajes Ilimitados', 'Motor de Crecimiento IA', 'Soporte Prioritario', 'Marca Blanca'].map(item => (
                                    <li key={item} className="flex items-center gap-3 text-sm text-white">
                                        <Check size={16} className="text-green-500" /> {item}
                                    </li>
                                ))}
                            </ul>
                            <button className="w-full py-3 rounded-xl bg-green-600 hover:bg-green-500 text-black font-bold transition-all shadow-lg shadow-green-900/50">Empezar Ahora</button>
                        </div>

                        {/* Enterprise */}
                        <div className="p-8 rounded-3xl bg-black border border-white/10 flex flex-col">
                            <h3 className="text-xl font-medium text-gray-400 mb-2">Enterprise</h3>
                            <div className="flex items-baseline gap-1 mb-6">
                                <span className="text-4xl font-bold text-white">Custom</span>
                            </div>
                            <ul className="space-y-4 mb-8 flex-1">
                                {['API Dedicada', 'Servidor Privado', 'Account Manager', 'Contrato SLA'].map(item => (
                                    <li key={item} className="flex items-center gap-3 text-sm text-gray-300">
                                        <Check size={16} className="text-green-500" /> {item}
                                    </li>
                                ))}
                            </ul>
                            <button className="w-full py-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 font-bold transition-all">Contactar</button>
                        </div>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="py-12 px-6 border-t border-white/10 text-center text-gray-500 text-sm">
                <p>&copy; 2024 RecoverAI. Todos los derechos reservados.</p>
            </footer>
        </div>
    );
};

export default LandingPage;
