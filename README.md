# Naut&Co - Alquiler de Embarcaciones

Sitio web estático desplegado en **Cloudflare Pages**.

## 🌐 URLs

- **Producció³³³n:** https://nautandco-pages.pages.dev
- **Dominios personalizados:** 
  - nautandco.com
  - www.nautandco.com

## 🚀 Despliegue Automá³³tico

Este repositorio está conectado a Cloudflare Pages. Cada push a `main` despliega automáticamente:

```bash
git push origin main
```

## 📁 Estructura

```
nautandco-pages/
├── index.html          # Landing page
├── README.md           # Documentació³³³n
└── .github/            # Workflows (opcional)
```

## 🔧 Configuració³³³n en Cloudflare

### 1. Crear Proyecto Pages

```bash
export CLOUDFLARE_API_TOKEN="tu_token"
export CLOUDFLARE_ACCOUNT_ID="tu_account_id"

curl -X POST "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "name": "nautandco-pages",
    "production_branch": "main"
  }'
```

### 2. Conectar GitHub

1. Ve a https://dash.cloudflare.com/
2. **Workers y Pages** → **nautandco-pages**
3. **Configuració³³³n** → **Git** → **Conectar repositorio**
4. Selecciona `Pablofifa/nautandco-pages`
5. **Guardar**

### 3. Añadir Dominios Personalizados

1. **Configuració³³³n** → **Dominios**
2. **Añ³³³adir dominio personalizado**
3. Añ³³³ade:
   - `nautandco.com`
   - `www.nautandco.com`

### 4. Configurar DNS en Cloudflare

Añ³³³ade registros CNAME:

| Tipo | Nombre | Contenido | Proxy |
|------|--------|-----------|-------|
| CNAME | nautandco.com | nautandco-pages.pages.dev | Proxied |
| CNAME | www | nautandco-pages.pages.dev | Proxied |

## 🔑 Token de API

El token necesita estos permisos:

- **Account** → `Cloudflare Pages: Edit`
- **Account** → `Account Settings: Read`
- **Zone** → `Read` (para DNS)
- **DNS** → `Edit` (para DNS)

## 🛠️ Comandos Útiles

### Deploy manual con Wrangler

```bash
npm install -g wrangler
wrangler login
wrangler pages deploy . --project-name=nautandco-pages
```

### Ver logs de deployment

```bash
wrangler pages deployment list --project-name=nautandco-pages
```

## 📝 Notas

- **Framework:** Estáá³³á³³tico (HTML/CSS)
- **Build Command:** (vací³³á³³o, no requiere build)
- **Output Directory:** (vací³³á³³o, root)
- **Compatibility Date:** 2026-09-01

---

**Creado:** 2026-09-01  
**Autor:** Naut&Co Team
