const fs = require('fs');
const path = require('path');

const LEADS_FILE = path.join(__dirname, 'leads.json');

const { scrapeLeads } = require('./scraper');

const AUTO_KEYWORDS = [
    // --- UNIVERSAL HIGH VOLUME (Broad E-commerce) ---
    "online store whatsapp", "buy online whatsapp", "shopping whatsapp", "delivery whatsapp",
    "tienda virtual whatsapp", "ventas online whatsapp", "pedidos whatsapp", "envios nacionales whatsapp",
    "loja virtual whatsapp", "comprar online whatsapp", "encomendas whatsapp", // Portuguese

    // --- SPECIFIC HIGH TRAFFIC NICHES (Global) ---
    "fashion store whatsapp", "shoes shop whatsapp", "sneakers store whatsapp",
    "electronics store whatsapp", "gadgets shop whatsapp", "mobile phones sale whatsapp",
    "beauty products whatsapp", "cosmetics shop whatsapp", "skincare store whatsapp",
    "furniture store whatsapp", "home decor shop whatsapp",
    "autoparts store whatsapp", "car accessories whatsapp",
    "pet supplies whatsapp", "dog food delivery whatsapp",

    // --- CITIES & REGIONS (Mixed) ---
    "boutique new york whatsapp", "store london whatsapp", "shop dubai whatsapp",
    "tienda madrid whatsapp", "negocio cdmx whatsapp", "ventas bogota whatsapp",
    "loja sao paulo whatsapp", "ventas santiago chile whatsapp", "store toronto whatsapp",
    "shop sydney whatsapp", "store paris whatsapp", "store berlin whatsapp"
];

let leadsData = {
    potentialLeads: [], // Start empty to force auto-scrape
    outreachStats: {
        totalSent: 0,
        repliesReceived: 0,
        active: false
    }
};

// Load existing leads or create new
if (fs.existsSync(LEADS_FILE)) {
    try {
        leadsData = JSON.parse(fs.readFileSync(LEADS_FILE, 'utf8'));
    } catch (e) {
        console.error('Error loading leads:', e);
    }
}

const saveLeads = () => {
    fs.writeFileSync(LEADS_FILE, JSON.stringify(leadsData, null, 2));
};

const { MessageMedia } = require('whatsapp-web.js');

const BASE_URL = 'https://recoverai-pro-shop.surge.sh';

const PITCH_DEFAULT = {
    es: [`¡Hola {{name}}! 👋... (Error al cargar templates)`],
    pt: [`Olá {{name}}! 👋... (Error loading templates)`],
    en: [`Hello {{name}}! 👋... (Error loading templates)`]
};

let activeTemplates = null;

try {
    const templates = require('./templates.json');
    activeTemplates = templates.sales;
} catch (e) {
    console.error('Error loading templates.json:', e);
    activeTemplates = PITCH_DEFAULT;
}

function reloadTemplates() {
    try {
        delete require.cache[require.resolve('./templates.json')];
        const templates = require('./templates.json');
        activeTemplates = templates.sales;
        console.log('🔄 Templates reloaded in Growth Engine');
    } catch (e) { console.error('Reload Error:', e); }
}

function detectLanguage(phone) {
    if (!phone) return 'en';
    const p = phone.toString();

    // Portuguese (Brazil)
    if (p.startsWith('55')) return 'pt';

    // Spanish (Spain + LATAM)
    // 34=Spain, 57=Colombia, 52=Mexico, 54=Argentina, 56=Chile, 51=Peru, 593=Ecuador, 503=El Salvador, 502=Guatemala, 506=Costa Rica, 507=Panama, 591=Bolivia, 595=Paraguay, 598=Uruguay
    const spanishPrefixes = ['34', '57', '52', '54', '56', '51', '593', '503', '502', '506', '507', '591', '595', '598'];
    if (spanishPrefixes.some(prefix => p.startsWith(prefix))) return 'es';

    // Default to English (US + Rest of World)
    return 'en';
}

function getPitch(name, phone) {
    const lang = detectLanguage(phone);
    const templates = activeTemplates[lang] || activeTemplates['en'];
    const template = templates[Math.floor(Math.random() * templates.length)];

    return template
        .replace('{{name}}', name || 'Partner')
        .replace('{{link}}', `${BASE_URL}/checkout.html`);
}

const initGrowth = (whatsappClient, logEvent) => {
    let outreachInterval = null;

    const startOutreach = () => {
        if (outreachInterval) {
            console.log('⚠️ El motor de ventas ya está en marcha.');
            return;
        }
        leadsData.outreachStats.active = true;
        saveLeads();

        console.log('🚀 Iniciando Campaña de Ventas Automática...');

        // Check for leads every 60 seconds
        outreachInterval = setInterval(async () => {
            // 1. Check if we need more leads (Auto-Pilot)
            const pendingLeads = leadsData.potentialLeads.filter(l => l.status === 'pending');

            if (pendingLeads.length === 0 && leadsData.outreachStats.active) {
                console.log('📉 Sin leads pendientes. Activando BUSCADOR AUTOMÁTICO...');
                const keyword = AUTO_KEYWORDS[Math.floor(Math.random() * AUTO_KEYWORDS.length)];

                try {
                    const report = await scrapeLeads(keyword);
                    if (report.length > 0) {
                        report.forEach(l => {
                            // Dedup check
                            if (!leadsData.potentialLeads.find(ex => ex.phone === l.phone)) {
                                leadsData.potentialLeads.push({ ...l, status: 'pending' });
                            }
                        });
                        saveLeads();
                        console.log(`✅ Auto-Pilot: Agregados ${report.length} nuevos leads.`);
                    }
                } catch (e) {
                    console.error("Auto-Pilot Scrape Error:", e);
                }
            }

            // 2. Process Next Lead
            const nextLead = leadsData.potentialLeads.find(l => l.status === 'pending');

            if (nextLead && leadsData.outreachStats.active) {
                try {
                    console.log(`📡 Contactando a: ${nextLead.name} (${nextLead.phone})...`);
                    const pitch = getPitch(nextLead.name, nextLead.phone);

                    // Mark as contacted immediately to prevent loops
                    nextLead.status = 'contacted';
                    nextLead.contactedAt = new Date().toISOString();
                    saveLeads();

                    // Verify number exists
                    const numberId = await whatsappClient.getNumberId(nextLead.phone);
                    if (numberId) {
                        await whatsappClient.sendMessage(numberId._serialized, pitch);
                        leadsData.outreachStats.totalSent++;
                        logEvent('CRISTIAN_DEV_KEY', 'info', `Propuesta enviada a: ${nextLead.name}`);
                        saveLeads();
                        console.log(`✅ Mensaje enviado exitosamente a ${nextLead.name}`);
                    } else {
                        nextLead.status = 'invalid';
                        saveLeads();
                        console.log(`⚠️ Número inválido para ${nextLead.name}`);
                    }
                } catch (error) {
                    console.error(`Error enviando pitch a ${nextLead.phone}:`, error);
                }
            } else if (!nextLead) {
                console.log('⏳ Esperando nuevos leads del Auto-Pilot...');
                // Do not stop, wait for next cycle to scrape
            }
        }, 10000); // 10 seconds for faster outreach
    };

    const stopOutreach = () => {
        if (outreachInterval) {
            clearInterval(outreachInterval);
            outreachInterval = null;
        }
        leadsData.outreachStats.active = false;
        saveLeads();
        console.log('🛑 Campaña de Ventas Detenida.');
    };

    const sendManualPitch = async (phone, name) => {
        try {
            console.log(`📡 Enviando pitch manual a: ${name} (${phone})...`);
            const pitch = getPitch(name, phone);
            const numberId = await whatsappClient.getNumberId(phone);
            if (numberId) {
                await whatsappClient.sendMessage(numberId._serialized, pitch);
                console.log(`✅ Pitch manual enviado a ${phone}`);
                return { success: true };
            } else {
                return { success: false, error: 'Número no registrado en WhatsApp' };
            }
        } catch (error) {
            console.error('Error enviando pitch manual:', error);
            throw error;
        }
    };

    const resetLeads = () => {
        leadsData.potentialLeads.forEach(lead => {
            lead.status = 'pending';
            if (lead.contactedAt) delete lead.contactedAt;
        });
        leadsData.outreachStats.totalSent = 0;
        leadsData.outreachStats.active = false;
        saveLeads();
        console.log('🔄 Leads reseteados a estado pending.');
        return { success: true };
    };

    const addLead = (name, phone) => {
        if (!name || !phone) return { success: false, error: 'Datos incompletos' };

        // Basic duplicate check
        const exists = leadsData.potentialLeads.find(l => l.phone === phone);
        if (exists) return { success: false, error: 'El número ya existe' };

        const newLead = { name, phone, status: 'pending' };
        leadsData.potentialLeads.push(newLead);
        saveLeads();
        console.log(`➕ Nuevo lead agregado: ${name} (${phone})`);
        return { success: true, lead: newLead };
    };

    const removeLead = (phone) => {
        const initialLength = leadsData.potentialLeads.length;
        leadsData.potentialLeads = leadsData.potentialLeads.filter(l => l.phone !== phone);

        if (leadsData.potentialLeads.length < initialLength) {
            saveLeads();
            console.log(`🗑️ Lead eliminado: ${phone}`);
            return { success: true };
        }
        return { success: false, error: 'Lead no encontrado' };
    };

    return {
        startOutreach,
        stopOutreach,
        sendManualPitch,
        resetLeads,
        addLead,
        removeLead,
        getStatus: () => leadsData.outreachStats,
        getLeads: () => leadsData.potentialLeads,
        reloadTemplates
    };
};

module.exports = { initGrowth };
