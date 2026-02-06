# 📘 RecoverAI: Manual del Propietario

¡Bienvenido a tu nuevo sistema de ingresos pasivos! **RecoverAI** es una plataforma automatizada que ayuda a dueños de tiendas online a recuperar ventas perdidas por WhatsApp.

---

## 🚀 ¿Cómo Funciona?

1.  **El Cliente (Dueño de Tienda)** conecta su tienda usando su **API Key** y la **URL del Webhook** que le das.
2.  **Configura su Pago**: Te paga mensualmente vía **PayPal** ($29 - $49 USD).
### 💳 Embudo de Ventas y Pagos
1.  **URL Pública de Cobro**: Envía a tus clientes a `http://localhost:3000/checkout.html`.
2.  **Experiencia Premium**: La página está diseñada para convertir visitantes en clientes pagando vía PayPal.
3.  **Onboarding Automático**: Una vez que el cliente paga, el sistema genera una **API Key** única al instante y la añade a tu base de datos sin que tú hagas nada.

### 🤖 Motor de Crecimiento (Growth Engine)
- Actívalo desde el Dashboard para que el bot empiece a buscar tiendas y les envíe el link de cobro automáticamente.
    *   Envía un WhatsApp profesional con tu logo y disclaimer.
    *   ✅ **TÚ GANAS DÓLARES** de forma pasiva.

---

## 🛠️ Tu Panel de Control

Para ver cuánto dinero estás ganando, accede a tu Dashboard:
1.  Abre el navegador en `http://localhost:5173` (Local) o tu dominio web.
2.  Verás:
    *   **Ingresos**: Cobros por suscripción o comisión.
    *   **Actividad en Vivo**: Feed en tiempo real de lo que hace el bot.
    *   **Configuración SaaS**: Tus credenciales para dar a los clientes.
    *   **Estado de WhatsApp**: Debe estar en 🟢 ONLINE.

---

## 🟢 Conectar WhatsApp (Solo 1 vez)

Para que el sistema envíe mensajes, necesita un número de WhatsApp.
1.  Cuando inicies el servidor, aparecerá un **Código QR**.
2.  Abre WhatsApp en tu celular > Dispositivos Vinculados > Vincular dispositivo.
3.  Escanea el QR.
4.  ¡Listo! El sistema ahora tiene "voz".

---

## 💰 Pagos (PayPal)

El dinero va directo a tu cuenta de PayPal en dólares.
*   **Retiros**: Puedes bajar el dinero a pesos colombianos usando **Nequi** o **Lulo Bank**.
*   **Automatización**: PayPal gestiona las suscripciones de tus clientes sin que tú hagas nada.

---

## 🌍 Lanzamiento Público (ngrok)

Para que tiendas fuera de tu casa puedan enviarte datos:
1.  Descarga **ngrok** (ngrok.com).
2.  Ejecuta: `ngrok http 3000`.
3.  Copia la URL `https://...` y esa es la que pondrás en tu Dashboard para tus clientes.


---

**RecoverAI v1.0 - Construido para la Libertad Financiera**

---

## 🔧 Solución de Problemas (Troubleshooting)

### 1. "El servidor dice que no encuentra Chrome"
Esto pasa la primera vez. La solución es reinstalar el cerebro:
1.  Cierra la terminal.
2.  Ejecuta: `cd backend` y luego `npm install`.
3.  Vuelve a intentar `node server.js`.

### 2. "Archivos Bloqueados / EBUSY"
Si Windows no te deja instalar algo porque "está en uso":
1.  Abre una terminal como Administrador.
2.  Escribe: `taskkill /F /IM node.exe` (Esto cierra todo lo que se quedó pegado).
3.  Vuelve a iniciar.
