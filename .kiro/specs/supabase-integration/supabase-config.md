# Configuração do Supabase - Minds Flow

## Credenciais do Projeto

**Project ID:** txlukdftqiqbpdxuuozp

**Supabase URL:** https://txlukdftqiqbpdxuuozp.supabase.co

**Anon Public Key:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4bHVrZGZ0cWlxYnBkeHV1b3pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzU2NzcsImV4cCI6MjA3NTg1MTY3N30.D4DXTknWbq2zHp3UKA_ecohfmP-11mNGhCkv8hYfMks
```

## Notas Importantes

- Este projeto Supabase já possui tabelas existentes que estão sincronizadas com um site
- O aplicativo iOS deve usar as mesmas tabelas para manter consistência entre plataformas
- Não criar novas tabelas - adaptar os modelos Swift às tabelas existentes

## Próximos Passos

1. Conectar ao Supabase e ler o schema das tabelas existentes
2. Mapear as tabelas existentes para os modelos Swift (Task, Wisdom, UserProfile, etc)
3. Adaptar os ViewModels para usar as tabelas reais
4. Garantir sincronização entre iOS app e website
