const fetch = require('node-fetch'); // Needs 'npm install node-fetch' or use standard fetch if Node 18+

// === CONFIGURACIÓN ===
const API_URL = 'http://localhost:3000/api/abandoned-cart';
const MY_PHONE = '573172922575'; // Tu número real para recibir la prueba
const API_KEY = 'CRISTIAN_DEV_KEY'; // Tu llave de tienda

// === DATOS DE PRUEBA (Lo que enviaría Shopify/WooCommerce) ===
const payload = {
    apiKey: API_KEY,
    phone: MY_PHONE,
    customerName: "Cristian (Dueño)",
    cartUrl: "https://mitienda.com/checkout/recuperar?id=123456789",
    products: ["Zapatos Nike Air", "Camiseta Recovery"]
};

console.log("🛒 Simulando evento de Carrito Abandonado...");
console.log("📡 Enviando datos a:", API_URL);

// Función autoejecutable para usar async/await
(async () => {
    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const data = await response.json();

        if (response.ok) {
            console.log("✅ ¡ÉXITO! El servidor recibió el evento.");
            console.log("📩 Respuesta del servidor:", data);
            console.log("📱 Revisa tu WhatsApp, el mensaje debería llegar en unos segundos.");
        } else {
            console.log("❌ ERROR del servidor:", data);
        }
    } catch (error) {
        console.error("❌ ERROR DE CONEXIÓN:", error.message);
        console.log("💡 Sugerencia: Asegúrate de que tu backend esté corriendo (node server.js)");
    }
})();
