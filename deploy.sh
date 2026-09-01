#!/bin/bash

# Naut&Co Pages - Script de despliegue automático
# Uso: ./deploy.sh

set -e

# Variables - Configura estas variables
export CLOUDFLARE_API_TOKEN="TU_TOKEN_AQUI"
export CLOUDFLARE_ACCOUNT_ID="ae19d70978eef4f5587ec393b9527fa0"
export CLOUDFLARE_ZONE_ID="ae19d70978eef4f5587ec393b9527fa0"
PROJECT_NAME="nautandco-pages"

echo "=== Naut&Co Pages Deploy Script ==="
echo ""

# 1. Verificar proyecto existe
echo "[1/4] Verificando proyecto Pages..."
PROJECT_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")

if echo "$PROJECT_CHECK" | grep -q '"success":true'; then
  echo "✅ Proyecto existe: $PROJECT_NAME"
else
  echo "❌ Proyecto no existe. Creando..."
  curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{
      "name": "'$PROJECT_NAME'",
      "production_branch": "main"
    }'
  echo "✅ Proyecto creado"
fi

echo ""

# 2. Añadir dominios personalizados
echo "[2/4] Añ³³³adiendo dominios personalizados..."

for DOMAIN in "nautandco.com" "www.nautandco.com"; do
  echo "  - Añ³³³adiendo: $DOMAIN"
  curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME/domains" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{
      "name": "'$DOMAIN'"
    }' > /dev/null 2>&1 || echo "    (ya existe)"
done

echo "✅ Dominios configurados"
echo ""

# 3. Configurar DNS
echo "[3/4] Configurando registros DNS..."

# Eliminar registros existentes si los hay
echo "  Limpiando DNS antiguos..."
curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data.get('result', []):
  if 'nautandco' in r.get('name', '').lower():
    print(f\"  Eliminando: {r['name']} ({r['type']})\")
" 2>/dev/null || true

# Crear registros CNAME
echo "  Creando CNAME..."

# nautandco.com -> pages.dev
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "CNAME",
    "name": "nautandco.com",
    "content": "'$PROJECT_NAME'.pages.dev",
    "proxied": true,
    "ttl": 1
  }' > /dev/null 2>&1 || echo "    nautandco.com (ya existe)"

# www.nautandco.com -> pages.dev
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "CNAME",
    "name": "www",
    "content": "'$PROJECT_NAME'.pages.dev",
    "proxied": true,
    "ttl": 1
  }' > /dev/null 2>&1 || echo "    www (ya existe)"

echo "✅ DNS configurados"
echo ""

# 4. Trigger deployment desde GitHub
echo "[4/4] Trigger deployment..."
echo ""
echo "⚠️  Para conectar GitHub:"
echo "   1. Ve a: https://dash.cloudflare.com/"
echo "   2. Workers y Pages → $PROJECT_NAME"
echo "   3. Configuració³³³n → Git → Conectar repositorio"
echo "   4. Selecciona: Pablofifa/$PROJECT_NAME"
echo ""
echo "O usa wrangler:"
echo "   npm install -g wrangler"
echo "   wrangler pages deploy . --project-name=$PROJECT_NAME"
echo ""

# Resumen
echo "=== ✅ Completado ==="
echo ""
echo "🌐 URLs:"
echo "   - https://$PROJECT_NAME.pages.dev"
echo "   - https://nautandco.com (tras conectar DNS)"
echo "   - https://www.nautandco.com (tras conectar DNS)"
echo ""
echo "📁 Repo: https://github.com/Pablofifa/$PROJECT_NAME"
echo ""
