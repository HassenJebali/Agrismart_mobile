# AgriSmart

Plateforme d'agriculture intelligente composée de cinq services.

## Architecture

| Service | Répertoire | Port |
|---------|-----------|------|
| Frontend Angular | `agrismart-web/` | 4200 |
| Backend Spring Boot | `spring_boot-main/` | 8080 |
| API Gateway (Spring Cloud) | `api-gateway/` | 8081 |
| Chatbot multi-agents (LangGraph) | `chatbot-flask/agrismart_agents/` | 5002 |
| Serveur MCP (exécuteur MongoDB) | `chatbot-flask/mcp_server/` | 5001 |
| Base de données | MongoDB | 27017 |

```
Angular (4200)
    └─→ API Gateway (8081)
            ├─→ Spring Boot (8080)  ─→ MongoDB (27017)
            └─→ Chatbot Flask (5002)
                    └─→ MCP Server (5001) ─→ MongoDB (27017)
```

### Chatbot multi-agents

- **LangGraph** : orchestration d'agents spécialisés (routing, RAG, DB, réponse)
- **Groq LLM** : génération de réponses (modèle `llama-3.3-70b-versatile`)
- **MCP Server** : microservice d'exécution des requêtes MongoDB (port 5001)
- **RAG** : retrieval depuis `knowledge_sources/` (FAISS + embeddings sentence-transformers)

### API Gateway — routes principales

- `/api/**` → Spring Boot
- `/chatbot/**` → Chatbot Flask

Fonctions : validation JWT, rate limiting, logging, CORS centralisé.

## Configuration (.env)

Copiez `.env.example` à la racine et renseignez vos secrets :

```powershell
Copy-Item .env.example .env
```

Variables essentielles :

| Variable | Description |
|----------|-------------|
| `JWT_SECRET` | Minimum 32 caractères, identique entre backend et chatbot |
| `GROQ_API_KEY` | Clé API Groq (https://console.groq.com) |
| `MONGO_URI` | `mongodb://localhost:27017` par défaut |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:4200` |
| `CHATBOT_ADMIN_TOKEN` | Obligatoire pour les endpoints admin chatbot |
| `INGEST_API_KEY` | Clé pour l'endpoint `/ingest` du chatbot |

Les fichiers `.env` sont ignorés par Git.

## Prérequis

- Java 17+, Maven (ou `mvnw.cmd` inclus)
- Python 3.11+ avec `pip`
- Node.js 18+, npm
- MongoDB en cours d'exécution sur le port 27017

### Installation Python (une seule fois)

```powershell
python -m venv .venv-1
.venv-1\Scripts\Activate.ps1
pip install -r chatbot-flask\requirements.txt
```

## Lancement rapide

### Option 1 — Script tout-en-un (recommandé)

```powershell
cd Agrismart
powershell -ExecutionPolicy Bypass -File .\start-all.ps1
```

Lance dans des fenêtres séparées : MongoDB (vérification) → Spring Boot → API Gateway → MCP Server → Chatbot → Angular.

### Option 2 — Manuel

```powershell
# Terminal 1 — Spring Boot
cd spring_boot-main
.\mvnw.cmd spring-boot:run

# Terminal 2 — API Gateway
cd api-gateway
..\spring_boot-main\mvnw.cmd spring-boot:run

# Terminal 3 — MCP Server
cd chatbot-flask\mcp_server
python app.py

# Terminal 4 — Chatbot LangGraph
cd chatbot-flask\agrismart_agents
python app.py

# Terminal 5 — Angular
cd agrismart-web
npm install
npm start
```

Ordre recommandé : MongoDB → Spring Boot → API Gateway → MCP Server → Chatbot → Angular.

## Vérification des services

| Service | URL |
|---------|-----|
| Angular | http://localhost:4200 |
| Spring Boot | http://localhost:8080/actuator/health |
| API Gateway | http://localhost:8081 |
| Chatbot | http://localhost:5002/health |
| MCP Server | http://localhost:5001/health |

```powershell
# Smoke test rapide (tous les services doivent être démarrés)
powershell -ExecutionPolicy Bypass -File .\smoke-test.ps1
```

## Tests E2E chatbot

```powershell
cd chatbot-flask
powershell -ExecutionPolicy Bypass -File .\test_e2e.ps1
```

Résultat attendu : `PASS=8 FAIL=0 SKIP=0`

## Module ML — Détection de maladies

Le notebook `Détection de maladie/dev_models/Resnet.ipynb` entraîne un modèle ResNet9 sur 38 classes de maladies végétales (dataset Kaggle `vipoooool/new-plant-diseases-dataset`).

Les modèles exportés sont lisibles par `Détection de maladie/fastapi_resnet/` :
- `.pth` : inférence PyTorch locale
- `.onnx` : production via FastAPI (opset 11)

## Sécurité

- Ne jamais versionner une clé API réelle dans `.env.example`.
- JWT partagé entre Spring Boot et le chatbot (même `JWT_SECRET` et `JWT_ALGORITHM=HS256`).
- Rotation des secrets : révoquer l'ancienne clé avant d'en générer une nouvelle.
- HTTPS obligatoire en production (reverse proxy ou load balancer avec TLS).
- Utiliser un Secret Manager (Vault, AWS/GCP/Azure) pour les cles sensibles.

## Comptes de test backend (actuels)

Ces comptes sont injectes par `DataInitializer`:
- admin@agrismart.gn / admin123
- producteur1@agrismart.gn / Test@1234
- producteur2@agrismart.gn / Tes@t1234
- cooperative@agrismart.gn / Test@1234
- technicien@agrismart.gn / test@1234
- ong@agrismart.gn / Test@1234
- etat@agrismart.gn / Test@1234
- visiteur@agrismart.gn / Test@1234

## Notes importantes

- Le README racine est en UTF-8 pour eviter les problemes d affichage.
- Le mode vocal chatbot cote frontend fonctionne deja avec Web Speech API.
- Le endpoint backend `POST /api/chatbot/tts` est disponible pour une integration audio MP3.
- Les CORS sont centralises dans le backend (Spring Boot) via `CORS_ALLOWED_ORIGINS`.
- Les mots de passe de seed peuvent etre changes via `SEED_ADMIN_PASSWORD` et `SEED_DEFAULT_PASSWORD`.
- Le backend est configure avec un `UserDetailsService` applicatif: le log `Using generated security password` ne doit plus apparaitre.
- Si ce message apparait encore apres une mise a jour, relancer avec `.\mvnw.cmd clean test` puis `.\mvnw.cmd spring-boot:run`.

## Modifications recentes (Panier & Marketplace)

### Corrections du systeme de panier
- **Backend**: Gestion des Offers (marketplace) et Products avec stock synchronise
- **Frontend**: Toast notifications en francais pour tous les messages
- **Endpoints**: Fixed GET/POST/PUT/DELETE operations avec authenticated users
- **Erreurs**: Tous les messages d'erreur affichent en francais
- **Translations**: Nouvelles cles i18n pour quantite, suppression, clearing panier
