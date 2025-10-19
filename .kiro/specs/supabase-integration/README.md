# Spec: Integração Supabase no Minds Flow

## Status: ✅ Aprovado e Pronto para Implementação

Esta spec define a integração completa do Supabase como backend do aplicativo iOS Minds Flow.

## Documentos

### 📋 [requirements.md](./requirements.md)
Define 13 requisitos com user stories e acceptance criteria em formato EARS:
- Configuração do Supabase
- Autenticação de usuários
- Persistência de Tasks, Wisdom e Mental States
- Perfil do usuário
- Tratamento de erros e modo offline
- Validação de schema
- Segurança com RLS
- Novos modelos e adaptações

### 🎨 [design.md](./design.md)
Descreve a arquitetura técnica completa:
- Arquitetura em camadas (Views → ViewModels → Services → Supabase)
- 4 componentes principais: SupabaseManager, AuthManager, CacheManager, SyncManager
- Modelos atualizados: Task, Wisdom, UserProfile, MentalState
- 3 novos modelos: TimelineEvent, UsageStats, Subscription
- Integração com ViewModels existentes
- Estratégia de testes e segurança
- Plano de migração em 5 fases (7-9 dias)

### ✅ [tasks.md](./tasks.md)
Plano de implementação com 39 tasks em 10 fases:
1. **Setup e Configuração** (4 tasks)
2. **Atualização de Modelos** (7 tasks)
3. **Refatoração do AuthManager** (3 tasks)
4. **Refatoração do SupabaseManager** (3 tasks)
5. **Refatoração dos ViewModels** (13 subtasks)
6. **Tratamento de Erros e UX** (4 tasks)
7. **Segurança e Validação** (3 tasks)
8. **Testes** (4 tasks)
9. **Otimização e Polish** (4 tasks)
10. **Validação e Deploy** (4 tasks)

### 📊 [database-schema.md](./database-schema.md)
Documentação completa do schema do Supabase:
- 7 tabelas existentes com todas as colunas
- Relacionamentos entre tabelas
- Mapeamento para modelos Swift
- Observações sobre tipos de dados

### ⚙️ [supabase-config.md](./supabase-config.md)
Credenciais e configuração do projeto Supabase

## Informações do Projeto Supabase

**Project ID**: txlukdftqiqbpdxuuozp  
**URL**: https://txlukdftqiqbpdxuuozp.supabase.co

### Tabelas Existentes

1. **profiles** - Perfil do usuário
2. **mental_states** - Histórico de estados mentais
3. **tasks** - Tarefas do usuário
4. **wisdom_entries** - Biblioteca de sabedoria
5. **timeline_events** - Eventos da timeline
6. **usage_stats** - Estatísticas de uso
7. **subscriptions** - Informações de assinatura

## Como Começar a Implementação

### 1. Abrir o arquivo de tasks
```bash
open .kiro/specs/supabase-integration/tasks.md
```

### 2. Começar pela Phase 1, Task 1
Clique em "Start task" ao lado da primeira task no arquivo tasks.md

### 3. Seguir a ordem das tasks
Cada task tem:
- Descrição clara do que fazer
- Subtasks com detalhes de implementação
- Referências aos requisitos relacionados

### 4. Marcar como completo
Após implementar e testar cada task, marque como concluída

## Estimativa de Tempo

**Total**: 7-9 dias de desenvolvimento

- Phase 1-2: 2-3 dias (Setup + Modelos)
- Phase 3-5: 3-4 dias (Services + ViewModels)
- Phase 6-10: 2-3 dias (UX + Testes + Deploy)

## Principais Desafios Técnicos

1. **Conversão de Energy Level**: tasks usa text, mental_states usa int4
2. **Modo Offline**: Implementar queue e sincronização
3. **Realtime**: Gerenciar subscriptions e lifecycle
4. **Compatibilidade**: Manter sincronização com website
5. **Migração**: Transição suave de mock para dados reais

## Recursos Úteis

- [Supabase Swift Docs](https://supabase.com/docs/reference/swift)
- [Supabase Dashboard](https://supabase.com/dashboard/project/txlukdftqiqbpdxuuozp)
- [SwiftUI + Supabase Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-swift)

## Próximos Passos

1. ✅ Requirements aprovados
2. ✅ Design aprovado
3. ✅ Tasks criadas
4. 🚀 **Começar implementação** - Phase 1, Task 1

---

**Criado em**: 2025-10-18  
**Última atualização**: 2025-10-18  
**Status**: Pronto para implementação
