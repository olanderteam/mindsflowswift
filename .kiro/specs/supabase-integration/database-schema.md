# Database Schema - Supabase Minds Flow

## Tabelas Existentes

### 1. profiles
Perfil do usuário com informações pessoais e preferências.

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key (FK para auth.users) |
| name | text | NULL | Nome do usuário |
| avatar_url | text | NULL | URL do avatar |
| theme | text | NULL | Tema preferido (light/dark/system) |
| language | text | NULL | Idioma preferido |
| created_at | timestamptz | NOT NULL | Data de criação |
| updated_at | timestamptz | NOT NULL | Data de atualização |

### 2. mental_states
Histórico de estados mentais do usuário (energia + emoção).

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NOT NULL | FK para profiles(id) |
| mood | text | NOT NULL | Emoção/humor (happy, calm, anxious, etc) |
| energy | int4 | NOT NULL | Nível de energia (1-10 ou low/medium/high) |
| notes | text | NULL | Notas opcionais sobre o estado |
| created_at | timestamptz | NOT NULL | Data/hora do registro |

### 3. tasks
Tarefas do usuário com nível de energia associado.

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NOT NULL | FK para profiles(id) |
| title | text | NOT NULL | Título da tarefa |
| description | text | NULL | Descrição detalhada |
| purpose | text | NULL | Propósito/significado da tarefa |
| energy | text | NOT NULL | Nível de energia (high/medium/low) |
| time_estimate | int4 | NULL | Estimativa de tempo em minutos |
| is_completed | boolean | NOT NULL | Status de conclusão |
| due_date | timestamptz | NULL | Data de vencimento |
| created_at | timestamptz | NOT NULL | Data de criação |
| updated_at | timestamptz | NOT NULL | Data de atualização |
| completed_at | timestamptz | NULL | Data de conclusão |

### 4. wisdom_entries
Biblioteca pessoal de conhecimentos, reflexões e insights.

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NOT NULL | FK para profiles(id) |
| content | text | NOT NULL | Conteúdo da sabedoria |
| title | text | NULL | Título opcional |
| category | text | NOT NULL | Categoria (reflection, learning, insight, etc) |
| emotional_tag | text | NULL | Tag emocional associada |
| tags | text[] | NULL | Array de tags para busca |
| created_at | timestamptz | NOT NULL | Data de criação |
| updated_at | timestamptz | NOT NULL | Data de atualização |

### 5. timeline_events
Eventos da linha do tempo do usuário.

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NOT NULL | FK para profiles(id) |
| action_activity_count | int4 | NULL | Contagem de atividades |
| tasks_completed | int4 | NULL | Tarefas completadas |
| mental_status_count | int4 | NULL | Registros de estado mental |
| timeline_event_count | int4 | NULL | Contagem de eventos |
| user_since | timestamptz | NULL | Usuário desde |
| created_at | timestamptz | NOT NULL | Data de criação |
| updated_at | timestamptz | NOT NULL | Data de atualização |

### 6. usage_stats
Estatísticas de uso do aplicativo.

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NOT NULL | FK para profiles(id) |
| wisdom_entries_count | int4 | NULL | Total de wisdom entries |
| total_tasks | int4 | NULL | Total de tarefas |
| completed_tasks | int4 | NULL | Tarefas completadas |
| mental_state_entries | int4 | NULL | Registros de estado mental |
| timeline_events | int4 | NULL | Eventos na timeline |
| user_since | timestamptz | NULL | Usuário desde |
| created_at | timestamptz | NOT NULL | Data de criação |
| updated_at | timestamptz | NOT NULL | Data de atualização |

### 7. subscriptions
Informações de assinatura do usuário.

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| id | uuid | NOT NULL | Primary Key |
| user_id | uuid | NOT NULL | FK para profiles(id) |
| plan_id | text | NOT NULL | ID do plano (pro, free, etc) |
| status | text | NOT NULL | Status da assinatura (active, inactive) |
| current_period_start | timestamptz | NOT NULL | Início do período atual |
| current_period_end | timestamptz | NOT NULL | Fim do período atual |
| stripe_customer_id | text | NULL | ID do cliente no Stripe |
| stripe_subscription_id | text | NULL | ID da assinatura no Stripe |
| created_at | timestamptz | NOT NULL | Data de criação |
| updated_at | timestamptz | NOT NULL | Data de atualização |

## Relacionamentos

```
auth.users (Supabase Auth)
    ↓
profiles (1:1)
    ↓
    ├── mental_states (1:N)
    ├── tasks (1:N)
    ├── wisdom_entries (1:N)
    ├── timeline_events (1:N)
    ├── usage_stats (1:1)
    └── subscriptions (1:1)
```

## Observações Importantes

1. **Autenticação**: O sistema usa `auth.users` do Supabase Auth como base
2. **Perfil**: Cada usuário tem um registro em `profiles` com o mesmo `id` do `auth.users`
3. **Energy Levels**: 
   - Na tabela `mental_states`: campo `energy` é `int4` (provavelmente 1-10)
   - Na tabela `tasks`: campo `energy` é `text` (high/medium/low)
4. **Tags**: `wisdom_entries.tags` é um array PostgreSQL (`text[]`)
5. **Timestamps**: Todas as tabelas usam `timestamptz` (timestamp with timezone)
6. **UUIDs**: Todos os IDs são UUID v4

## Mapeamento para Modelos Swift

### Task (Swift) → tasks (Supabase)
- `id: UUID` → `id: uuid`
- `title: String` → `title: text`
- `description: String` → `description: text`
- `energyLevel: EnergyLevel` → `energy: text` (enum as string)
- `purpose: String` → `purpose: text`
- `isCompleted: Bool` → `is_completed: boolean`
- `createdAt: Date` → `created_at: timestamptz`
- `updatedAt: Date` → `updated_at: timestamptz`
- `completedAt: Date?` → `completed_at: timestamptz`
- `userId: String` → `user_id: uuid`
- **NOVO**: `dueDate: Date?` → `due_date: timestamptz`
- **NOVO**: `timeEstimate: Int?` → `time_estimate: int4`

### Wisdom (Swift) → wisdom_entries (Supabase)
- `id: UUID` → `id: uuid`
- `content: String` → `content: text`
- **NOVO**: `title: String?` → `title: text`
- `category: WisdomCategory` → `category: text` (enum as string)
- `emotion: Emotion` → `emotional_tag: text` (enum as string)
- `tags: [String]` → `tags: text[]`
- `createdAt: Date` → `created_at: timestamptz`
- `updatedAt: Date` → `updated_at: timestamptz`
- `userId: String` → `user_id: uuid`

### UserProfile (Swift) → profiles (Supabase)
- `id: UUID` → `id: uuid`
- `name: String` → `name: text`
- `email: String` → (vem de auth.users)
- **NOVO**: `avatarUrl: String?` → `avatar_url: text`
- `theme: AppTheme` → `theme: text` (enum as string)
- **NOVO**: `language: String?` → `language: text`
- `createdAt: Date` → `created_at: timestamptz`
- `updatedAt: Date` → `updated_at: timestamptz`
- `userId: String` → `id: uuid` (mesmo ID)
- **REMOVER**: `currentEnergyLevel` (não está no perfil, vem de mental_states)
- **REMOVER**: `currentEmotion` (não está no perfil, vem de mental_states)
- **REMOVER**: `isCollapseMode` (preferência local do app)

### MentalState (Swift) → mental_states (Supabase)
- `energyLevel: EnergyLevel` → `energy: int4` (converter enum para int)
- `emotion: Emotion` → `mood: text` (enum as string)
- `timestamp: Date` → `created_at: timestamptz`
- **NOVO**: `notes: String?` → `notes: text`
- **NOVO**: `userId: String` → `user_id: uuid`
- **NOVO**: `id: UUID` → `id: uuid`

## Novas Estruturas Necessárias

### TimelineEvent (Swift) - NOVO
Precisa criar modelo Swift para mapear `timeline_events`

### UsageStats (Swift) - NOVO
Precisa criar modelo Swift para mapear `usage_stats`

### Subscription (Swift) - NOVO
Precisa criar modelo Swift para mapear `subscriptions`
