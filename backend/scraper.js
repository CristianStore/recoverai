const puppeteer = require('puppeteer');

async function scrapeLeads(query = "tiendas de ropa medellin whatsapp") {
    console.log(`🕵️‍♂️ Iniciando búsqueda de: "${query}"...`);

    // Launch separate browser instance for scraping to avoid conflict with WA Client
    const browser = await puppeteer.launch({
        headless: "new", // Use new headless mode
        executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();
    const leads = [];

    try {
        // Search on Bing (Less strict blocking than Google)
        await page.goto(`https://www.bing.com/search?q=${encodeURIComponent(query)}`, { waitUntil: 'domcontentloaded' });

        // Check if blocked
        const title = await page.title();
        console.log(`Page Title: ${title}`);

        const items = [];
        const bodyText = document.body.innerText;

        // GLOBAL REGEX PATTERNS
        // 1. Generic International (e.g., +1 555..., +34 6..., +86 1...)
        // Matches: +[1-9] followed by 8-14 digits
        const regexGlobal = /\+(?:[0-9] ?){6,14}[0-9]/g;

        // 2. Colombia / LATAM / US Local (10 digits)
        // Matches: 3xxxxxxxxx or 555xxxxxxx
        const regexLocal = /\b[3-9]\d{2}[-\s]?\d{3}[-\s]?\d{4}\b/g;

        // 3. Spain Local (9 digits, starts with 6 or 7)
        const regexSpain = /\b[67]\d{2}[-\s]?\d{3}[-\s]?\d{3}\b/g;

        const matchesGlobal = bodyText.match(regexGlobal) || [];
        const matchesLocal = bodyText.match(regexLocal) || [];
        const matchesSpain = bodyText.match(regexSpain) || [];

        const allMatches = [...new Set([...matchesGlobal, ...matchesLocal, ...matchesSpain])];

        allMatches.forEach(rawPhone => {
            let cleanPhone = rawPhone.replace(/\D/g, ''); // Remove non-digits

            // Normalization Logic
            if (cleanPhone.length === 10) {
                // Assume US (+1) or COL (+57) based on first digit? 
                // For safety in this "Global" mode, we might need to guess or rely on context.
                // Defaulting to wildcard approach or checking if it starts with 3 (Col) vs others.
                if (cleanPhone.startsWith('3')) cleanPhone = '57' + cleanPhone; // Colombia
                else cleanPhone = '1' + cleanPhone; // USA Default
            }
            else if (cleanPhone.length === 9 && (cleanPhone.startsWith('6') || cleanPhone.startsWith('7'))) {
                cleanPhone = '34' + cleanPhone; // Spain
            }

            // WhatsApp Filter: valid lengths roughly 10-15 digits
            if (cleanPhone.length >= 10 && cleanPhone.length <= 15) {
                items.push({
                    name: "Prospecto Global",
                    phone: cleanPhone,
                    source: 'Global Search'
                });
            }
        });
        return items;

        console.log(`✅ Encontrados ${results.length} posibles clientes.`);
        leads.push(...results);

    } catch (err) {
        console.error("Error scraping:", err);
    } finally {
        await browser.close();
    }

    return leads;
}

module.exports = { scrapeLeads };
