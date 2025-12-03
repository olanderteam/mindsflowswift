# ⚡ Quick Start - Minds Flow

## 🚀 Setup em 3 Minutos

### Passo 1: Configure as Credenciais

```bash
# Execute o script de configuração
./configure-supabase.sh
```

Isso criará o arquivo `secrets.json`. Edite-o com suas credenciais do Supabase.

### Passo 2: Adicione ao Xcode

1. Abra `Minds Flow.xcodeproj` no Xcode
2. Arraste `secrets.json` para o projeto no Xcode
3. ✅ Marque "Copy items if needed"
4. ✅ Marque o target "Minds Flow"
5. Clique em "Finish"

### Passo 3: Build e Run

```bash
# No Xcode:
# 1. Clean: Product → Clean Build Folder (Cmd + Shift + K)
# 2. Build: Product → Build (Cmd + B)
# 3. Run: Product → Run (Cmd + R)
```

## ✅ Verificação

Se tudo estiver correto, você verá no console:

```
✅ Supabase configuration is valid
📍 Using Supabase URL: https://txlukdftqiqbpdxuuozp.supabase.co
```

## 🔧 Estrutura de Arquivos

```
mindsflowswift/
├── secrets.json              ← Suas credenciais (NÃO commitar)
├── secrets.example.json      ← Template (pode commitar)
├── Minds Flow/
│   └── Services/
│       └── SupabaseConfig.swift  ← Lê do secrets.json
└── .gitignore               ← Inclui secrets.json
```

## 🔒 Segurança

- ✅ `secrets.json` está no `.gitignore`
- ✅ Não será commitado no Git
- ✅ Cada desenvolvedor tem seu próprio arquivo
- ✅ Sem credenciais no código fonte

## ❓ Problemas Comuns

### "secrets.json not found in app bundle"

**Solução:**
1. Verifique se `secrets.json` está no projeto do Xcode
2. Vá em Build Phases → Copy Bundle Resources
3. Certifique-se que `secrets.json` está na lista
4. Se não estiver, clique em "+" e adicione

### "Failed to load secrets.json"

**Solução:**
1. Verifique o formato JSON:
```json
{
  "supabase": {
    "url": "https://seu-projeto.supabase.co",
    "anonKey": "sua-chave-aqui"
  }
}
```
2. Sem vírgulas extras
3. Aspas duplas, não simples
4. URL completa com https://

### Build funciona mas app crasha

**Solução:**
1. Verifique se `secrets.json` está em "Copy Bundle Resources"
2. Clean build folder (Cmd + Shift + K)
3. Delete DerivedData:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```
4. Rebuild

## 📚 Mais Informações

- [SETUP.md](SETUP.md) - Guia completo
- [SECURITY.md](SECURITY.md) - Política de segurança
- [MIGRATION-GUIDE.md](MIGRATION-GUIDE.md) - Migração detalhada

## 🆘 Precisa de Ajuda?

1. Verifique se `secrets.json` existe
2. Verifique se está no Xcode
3. Verifique se está em "Copy Bundle Resources"
4. Clean e rebuild
5. Consulte SETUP.md para mais detalhes

---

**Tempo estimado:** 3 minutos  
**Dificuldade:** Fácil  
**Requer:** Xcode, credenciais do Supabase
