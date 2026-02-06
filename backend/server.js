require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const qrcodeFile = require('qrcode');
const { initGrowth } = require('./growth');
const { scrapeLeads } = require('./scraper'); // New Scraper Module

const TEMPLATES_FILE = path.join(__dirname, 'templates.json');

function detectLanguage(phone) {
    if (!phone) return 'en';
    const p = phone.toString();
    if (p.startsWith('55')) return 'pt';
    const spanishPrefixes = ['34', '57', '52', '54', '56', '51', '593', '503', '502', '506', '507', '591', '595', '598'];
    if (spanishPrefixes.some(prefix => p.startsWith(prefix))) return 'es';
    return 'en';
}

function getTemplates() {
    try {
        return JSON.parse(fs.readFileSync(TEMPLATES_FILE, 'utf8'));
    } catch (e) {
    } catch (e) {
        return {
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
        };
    }
}

function saveTemplates(templates) {
    fs.writeFileSync(TEMPLATES_FILE, JSON.stringify(templates, null, 4));
    growthAgent.reloadTemplates();
}

const app = express();

// CORS Configuration to allow Frontend to talk to Backend
app.use(cors({
    origin: '*', // Allow all for simplicity in this setup, or specify 'https://recoverai-pro-shop.surge.sh'
    methods: ['GET', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Bypass-Tunnel-Reminder', 'x-api-key']
}));

app.use(express.json());

const PORT = process.env.PORT || 3000;
const STATS_FILE = path.join(__dirname, 'stats.json');

// --- SaaS Persistence ---
// Routes moved below to avoid blocking APIs

// Data persistence logic
let data = {
    shops: {
        "CRISTIAN_DEV_KEY": {
            "name": "Tienda Demo (Cristian)",
            "earnings": 0,
            "messagesSent": 0,
            "cartsDetected": 0,
            "events": []
        }
    }
};

if (fs.existsSync(STATS_FILE)) {
    try {
        const savedData = JSON.parse(fs.readFileSync(STATS_FILE, 'utf8'));
        if (!savedData.shops) {
            data.shops["CRISTIAN_DEV_KEY"].earnings = savedData.earnings || 0;
            data.shops["CRISTIAN_DEV_KEY"].messagesSent = savedData.messagesSent || 0;
            data.shops["CRISTIAN_DEV_KEY"].cartsDetected = savedData.cartsDetected || 0;
        } else {
            data = savedData;
        }
    } catch (e) { console.error('Error loading data:', e); }
}

const saveData = () => fs.writeFileSync(STATS_FILE, JSON.stringify(data, null, 2));

const logEvent = (shopKey, type, description) => {
    const shop = data.shops[shopKey];
    if (shop) {
        shop.events.unshift({ timestamp: new Date().toISOString(), type, description });
        if (shop.events.length > 20) shop.events.pop();
        saveData();
    }
};

const authenticateShop = (req, res, next) => {
    const apiKey = req.headers['x-api-key'] || req.body.apiKey || req.query.apiKey;
    if (!apiKey || !data.shops[apiKey]) return res.status(401).json({ error: 'Invalid API Key' });
    req.shopKey = apiKey;
    req.shop = data.shops[apiKey];
    next();
};

// --- Single Bot Architecture ---
console.log('Initializing WhatsApp Client...');
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--disable-gpu'
        ],
        executablePath: process.platform === 'win32'
            ? 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
            : '/usr/bin/google-chrome-stable'
    }
});

let waStatus = 'disconnected';

// Auto-Branding Logic
const applyBranding = async () => {
    setTimeout(async () => {
        try {
            const logoProPath = path.join(__dirname, '..', 'assets', 'logo_recoverai_pro.png');
            if (fs.existsSync(logoProPath)) {
                const { MessageMedia } = require('whatsapp-web.js');
                const media = MessageMedia.fromFilePath(logoProPath);
                await client.setProfilePicture(media);
                console.log('🖼️ Logotipo RecoverAI PRO aplicado al perfil.');
            }
        } catch (err) {
            console.warn('⚠️ No se pudo aplicar el logo automáticamente:', err.message);
        }
    }, 5000);
};

console.log('--- QR CODE EVENT RECEIVED ---');
console.log('QR String Length:', qr.length);

qrcode.generate(qr, { small: true });
waStatus = 'scanned_needed';

// Store QR globally for API access
global.latestQr = qr;
});

// Add QR Image Endpoint
app.get('/api/qr-image', async (req, res) => {
    if (!global.latestQr) return res.status(404).send('QR Not Ready');

    try {
        const url = await qrcodeFile.toDataURL(global.latestQr);
        const img = Buffer.from(url.split(',')[1], 'base64');
        res.writeHead(200, {
            'Content-Type': 'image/png',
            'Content-Length': img.length
        });
        res.end(img);
    } catch (e) {
        res.status(500).send('Error generating QR');
    }
});

client.on('ready', () => {
    console.log('✅ WhatsApp Client is READY!');
    waStatus = 'connected';
    applyBranding();

    // --- AUTO-PILOT ZERO TOUCH ---
    console.log('🚀 SYSTEM: Iniciando Modo Piloto Automático (Global Growth)...');
    growthAgent.startOutreach();
});

client.on('authenticated', () => console.log('🔐 Client Authenticated'));
client.on('disconnected', (reason) => {
    console.log('❌ Client Disconnected:', reason);
    waStatus = 'disconnected';
    client.initialize();
});

client.on('message', async msg => {
    if (msg.body === '!ping') {
        msg.reply('pong');
        return;
    }

    // Auto-responder for customers -> DISABLED BY USER REQUEST
    /*
    if (!msg.fromMe && !msg.isGroup) {
        // Exclude owner from auto-reply (New Number: 573172922575)
        // Also adding the "Test Lead" number (573228516001) so the bot doesn't reply to itself in a loop if testing
        if (msg.from.includes('573172922575') || msg.from.includes('573228516001')) return;

        console.log(`Received message from ${msg.from}: ${msg.body}`);

        const autoReply = "¡Hola! 👋 Gracias por contactar a RecoverAI. Para brindarte una mejor atención y soporte personalizado, te invitamos a escribirnos a través de nuestra web oficial o nuestro canal de soporte directo. ¡Estamos para ayudarte! 🚀";

        await client.sendMessage(msg.from, autoReply);
        console.log(`Auto-reply sent to ${msg.from}`);
    }
    */
});

client.initialize();

// Initialize Growth Agent
const growthAgent = initGrowth(client, logEvent);

// --- API Router ---

app.get('/api/status', (req, res) => {
    // Legacy support for multi-bot endpoint structure if needed, or simple status
    res.json({
        sales: { status: waStatus },
        recovery: { status: waStatus },
        global: waStatus
    });
});

app.get('/api/whatsapp-status', (req, res) => res.json({ status: waStatus }));

// --- Growth / Sales API ---
app.get('/api/growth/status', (req, res) => {
    res.json({ ...growthAgent.getStatus(), leads: growthAgent.getLeads() });
});

app.post('/api/growth/toggle', (req, res) => {
    const { active } = req.body;
    if (waStatus !== 'connected') return res.status(503).json({ error: 'WhatsApp no conectado' });
    active ? growthAgent.startOutreach() : growthAgent.stopOutreach();
    res.json({ success: true, active });
});

// Restart Bot Endpoint
app.post('/api/restart-bot', async (req, res) => {
    try {
        await client.destroy();
        await client.initialize();
        global.latestQr = null; // Clear old QR
        waStatus = 'disconnected';
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.post('/api/growth/test-me', async (req, res) => {
    if (waStatus !== 'connected') return res.status(503).json({ error: 'WhatsApp no conectado' });
    try {
        const result = await growthAgent.sendManualPitch('573172922575', 'Cristian (Dueño)');
        res.json(result);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/growth/test-custom', async (req, res) => {
    const { phone, name } = req.body;
    if (waStatus !== 'connected') return res.status(503).json({ error: 'WhatsApp no conectado' });
    try {
        const result = await growthAgent.sendManualPitch(phone, name);
        res.json(result);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/growth/reset-leads', (req, res) => res.json(growthAgent.resetLeads()));

app.post('/api/growth/add-lead', (req, res) => {
    const { name, phone } = req.body;
    const result = growthAgent.addLead(name, phone);
    if (result.success) res.json(result);
    else res.status(400).json(result);
});

app.delete('/api/growth/lead/:phone', (req, res) => {
    const { phone } = req.params;
    const result = growthAgent.removeLead(phone);
    if (result.success) res.json(result);
    else res.status(404).json(result);
});

app.post('/api/growth/scrape', async (req, res) => {
    const { query } = req.body;
    if (!query) return res.status(400).json({ error: 'Query required' });

    try {
        console.log(`🔎 Iniciando scraper para: ${query}`);
        const results = await scrapeLeads(query);

        // Add found leads to Growth Engine
        let addedCount = 0;
        results.forEach(lead => {
            const added = growthAgent.addLead(lead.name, lead.phone);
            if (added.success) addedCount++;
        });

        res.json({
            success: true,
            found: results.length,
            added: addedCount,
            leads: results
        });
    } catch (error) {
        console.error('Scraper error:', error);
        res.status(500).json({ error: 'Scraping failed' });
    }
});

// --- Recovery API ---
app.post('/api/abandoned-cart', authenticateShop, async (req, res) => {
    const { phone, cartUrl, customerName } = req.body;
    const { shopKey, shop } = req;

    if (waStatus !== 'connected') return res.status(503).json({ error: 'WhatsApp no conectado' });

    shop.cartsDetected++;
    logEvent(shopKey, 'info', `Carrito detectado de ${customerName || phone}`);
    saveData();

    const templates = getTemplates();
    const lang = detectLanguage(phone);
    const templateText = templates.recovery[lang] || templates.recovery['en'];

    const msg = templateText
        .replace('{{name}}', customerName || (lang === 'es' ? 'Cliente' : (lang === 'pt' ? 'Cliente' : 'Customer')))
        .replace('{{link}}', cartUrl);

    setTimeout(async () => {
        try {
            const numberId = await client.getNumberId(phone);
            if (numberId) {
                await client.sendMessage(numberId._serialized, msg);
                shop.messagesSent++;
                shop.earnings += 10;
                logEvent(shopKey, 'success', `Recuperación enviada a ${customerName}`);
                saveData();
            }
        } catch (e) {
            console.error('Recovery Send Error', e);
            logEvent(shopKey, 'error', `Fallo al enviar recuperación a ${phone}`);
        }
    }, 5000);

    res.json({ success: true, message: 'Recovery Queued' });
});

app.post('/api/test-recovery-custom', async (req, res) => {
    const { phone, urlOverride } = req.body;
    if (waStatus !== 'connected') return res.status(503).json({ error: 'WhatsApp no conectado' });

    try {
        // Use Professional Frontend URL or Custom
        const baseUrl = urlOverride || 'https://recoverai-pro-shop.surge.sh/checkout.html';
        const templates = getTemplates();
        const lang = detectLanguage(phone);
        const templateText = templates.recovery[lang] || templates.recovery['en'];

        const msg = templateText
            .replace('{{name}}', name || (lang === 'es' ? 'Cliente de Prueba' : 'Test Client'))
            .replace('{{link}}', baseUrl);
        const numberId = await client.getNumberId(phone);

        if (numberId) {
            await client.sendMessage(numberId._serialized, msg);
            res.json({ success: true });
        } else {
            res.status(404).json({ error: 'Número no válido' });
        }
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// --- Dashboard & Stats ---
app.get('/api/stats', (req, res) => {
    const firstShopKey = Object.keys(data.shops)[0];
    res.json({ ...data.shops[firstShopKey], apiKey: firstShopKey });
});

// --- Templates API ---
app.get('/api/templates', (req, res) => res.json(getTemplates()));

app.post('/api/templates', (req, res) => {
    saveTemplates(req.body);
    res.json({ success: true });
});

app.post('/api/reset-stats', (req, res) => {
    Object.keys(data.shops).forEach(key => {
        data.shops[key].earnings = 0;
        data.shops[key].messagesSent = 0;
        data.shops[key].cartsDetected = 0;
        data.shops[key].events = [];
    });
    saveData();
    res.json({ success: true });
});

// --- SaaS / Payment API ---
app.get('/api/config', (req, res) => {
    res.json({ paypalClientId: process.env.PAYPAL_CLIENT_ID });
});

// Static Files (Moved to end to ensure API priority)
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'public', 'checkout.html')));
app.use(express.static(path.join(__dirname, 'public')));

// --- PayPal Integration ---
const { PAYPAL_CLIENT_ID, PAYPAL_SECRET } = process.env;
const BASE_URL = 'https://api-m.sandbox.paypal.com'; // CHANGE TO 'https://api-m.paypal.com' FOR PRODUCTION

async function generateAccessToken() {
    if (!PAYPAL_CLIENT_ID || !PAYPAL_SECRET) {
        throw new Error("MISSING_API_CREDENTIALS");
    }
    const auth = Buffer.from(PAYPAL_CLIENT_ID + ":" + PAYPAL_SECRET).toString("base64");
    const response = await fetch(`${BASE_URL}/v1/oauth2/token`, {
        method: "POST",
        body: "grant_type=client_credentials",
        headers: {
            Authorization: `Basic ${auth}`,
        },
    });

    const data = await response.json();
    return data.access_token;
}

async function createOrder() {
    const accessToken = await generateAccessToken();
    const url = `${BASE_URL}/v2/checkout/orders`;
    const payload = {
        intent: "CAPTURE",
        purchase_units: [
            {
                amount: {
                    currency_code: "USD",
                    value: "29.00",
                },
            },
        ],
    };

    const response = await fetch(url, {
        headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accessToken}`,
        },
        method: "POST",
        body: JSON.stringify(payload),
    });

    return handleResponse(response);
}

async function handleResponse(response) {
    if (response.status === 200 || response.status === 201) {
        return response.json();
    }
    const errorMessage = await response.text();
    throw new Error(errorMessage);
}

app.post('/api/create-paypal-order', async (req, res) => {
    try {
        const order = await createOrder();
        res.json(order);
    } catch (error) {
        console.error("Failed to create order:", error);
        res.status(500).json({ error: "Failed to create order." });
    }
});

app.post('/api/onboard-shop', (req, res) => {
    // Generate new API Key
    const newApiKey = 'SHOP_' + Math.random().toString(36).substr(2, 9).toUpperCase();

    // Create new Shop Entry
    data.shops[newApiKey] = {
        name: "Nueva Tienda (Pro)",
        earnings: 0,
        messagesSent: 0,
        cartsDetected: 0,
        events: []
    };
    saveData();

    res.json({ success: true, apiKey: newApiKey });
});

app.listen(PORT, '0.0.0.0', () => console.log(`🚀 RecoverAI Unified Server running on port ${PORT}`));
