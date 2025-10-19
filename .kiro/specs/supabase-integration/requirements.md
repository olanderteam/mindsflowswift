# Requirements Document - Integração Supabase no Minds Flow

## Introduction

Este documento define os requisitos para integrar o Supabase como backend do aplicativo iOS Minds Flow. O aplicativo atualmente usa dados mock e precisa ser conectado a um banco de dados real para persistência de dados, autenticação de usuários e sincronização entre dispositivos.

## Glossary

- **Minds Flow App**: Aplicativo iOS em SwiftUI para produtividade e bem-estar mental
- **Supabase**: Plataforma de backend-as-a-service com PostgreSQL, autenticação e APIs REST
- **SupabaseManager**: Classe singleton responsável pela comunicação com o Supabase
- **AuthManager**: Classe singleton para gerenciar autenticação (atualmente com dados mock)
- **Mental State**: Estado mental do usuário composto por nível de energia e emoção
- **Task**: Tarefa do usuário com nível de energia associado
- **Wisdom**: Entrada de conhecimento/reflexão pessoal do usuário
- **Energy Level**: Nível de energia do usuário (high, medium, low)
- **Emotion**: Estado emocional do usuário (calm, anxious, creative, focused, etc)

## Requirements

### Requirement 1: Configuração do Supabase

**User Story:** Como desenvolvedor, eu quero configurar as credenciais do Supabase no aplicativo, para que o app possa se conectar ao backend real.

#### Acceptance Criteria

1. WHEN THE Minds Flow App IS initialized, THE SupabaseManager SHALL load Supabase URL and anon key from a secure configuration file
2. THE SupabaseManager SHALL initialize the Supabase client with the provided credentials
3. THE SupabaseManager SHALL verify the connection to Supabase during initialization
4. IF THE connection fails, THEN THE SupabaseManager SHALL log an error and provide fallback to offline mode
5. THE configuration file SHALL NOT be committed to version control for security

### Requirement 2: Autenticação de Usuários

**User Story:** Como usuário, eu quero fazer login com email e senha, para que eu possa acessar meus dados de forma segura.

#### Acceptance Criteria

1. WHEN A user provides valid email and password, THE AuthManager SHALL authenticate the user via Supabase Auth
2. WHEN authentication succeeds, THE AuthManager SHALL store the user session securely
3. WHEN THE app launches, THE AuthManager SHALL check for an existing valid session
4. THE AuthManager SHALL provide methods for sign up, sign in, and sign out
5. WHEN A user signs out, THE AuthManager SHALL clear all local session data

### Requirement 3: Persistência de Tarefas

**User Story:** Como usuário, eu quero que minhas tarefas sejam salvas no banco de dados, para que eu não perca meus dados ao fechar o app.

#### Acceptance Criteria

1. WHEN A user creates a task, THE TasksViewModel SHALL insert the task into the Supabase tasks table
2. WHEN A user updates a task, THE TasksViewModel SHALL update the corresponding record in Supabase
3. WHEN A user deletes a task, THE TasksViewModel SHALL remove the record from Supabase
4. WHEN THE TasksViewModel loads tasks, THE SupabaseManager SHALL fetch all tasks for the authenticated user
5. THE tasks table SHALL enforce user_id foreign key constraint to ensure data isolation

### Requirement 4: Persistência de Wisdom

**User Story:** Como usuário, eu quero que minhas entradas de wisdom sejam salvas no banco de dados, para que eu possa acessá-las de qualquer dispositivo.

#### Acceptance Criteria

1. WHEN A user creates a wisdom entry, THE WisdomViewModel SHALL insert the entry into the Supabase wisdom table
2. WHEN A user updates a wisdom entry, THE WisdomViewModel SHALL update the corresponding record in Supabase
3. WHEN A user deletes a wisdom entry, THE WisdomViewModel SHALL remove the record from Supabase
4. WHEN THE WisdomViewModel loads wisdom entries, THE SupabaseManager SHALL fetch all entries for the authenticated user
5. THE wisdom table SHALL support tags as a JSON array field

### Requirement 5: Rastreamento de Estado Mental

**User Story:** Como usuário, eu quero que meu estado mental seja registrado ao longo do tempo, para que eu possa ver padrões e tendências.

#### Acceptance Criteria

1. WHEN A user updates their mental state, THE DashboardViewModel SHALL insert a new mental_state record in Supabase
2. THE mental_state table SHALL store energy_level, emotion, timestamp, and optional notes
3. WHEN THE DashboardViewModel loads the current state, THE SupabaseManager SHALL fetch the most recent mental_state record
4. THE DashboardViewModel SHALL be able to query mental state history for analytics
5. THE mental_state records SHALL be associated with the authenticated user via user_id

### Requirement 6: Perfil do Usuário

**User Story:** Como usuário, eu quero que minhas preferências e configurações sejam salvas, para que o app se comporte de acordo com minhas escolhas.

#### Acceptance Criteria

1. WHEN A user updates their profile, THE SupabaseManager SHALL update the user_profiles table
2. THE user_profiles table SHALL store name, theme preference, collapse_mode, and other settings
3. WHEN THE app launches, THE SupabaseManager SHALL load the user profile from Supabase
4. THE user profile SHALL be created automatically when a new user signs up
5. THE user_profiles table SHALL have a one-to-one relationship with auth.users

### Requirement 7: Tratamento de Erros e Offline

**User Story:** Como usuário, eu quero que o app funcione mesmo sem conexão, para que eu possa continuar usando em qualquer situação.

#### Acceptance Criteria

1. WHEN THE network is unavailable, THE SupabaseManager SHALL detect the offline state
2. WHEN offline, THE ViewModels SHALL queue write operations for later synchronization
3. WHEN THE connection is restored, THE SupabaseManager SHALL sync queued operations automatically
4. THE app SHALL display appropriate error messages when operations fail
5. THE app SHALL provide visual feedback about online/offline status

### Requirement 8: Validação de Schema do Banco

**User Story:** Como desenvolvedor, eu quero validar que o schema do Supabase corresponde aos modelos do app, para evitar erros de sincronização.

#### Acceptance Criteria

1. THE Task model SHALL map correctly to the tasks table schema including new fields (due_date, time_estimate)
2. THE Wisdom model SHALL map correctly to the wisdom_entries table schema including title field
3. THE UserProfile model SHALL map correctly to the profiles table schema including avatar_url and language
4. THE MentalState struct SHALL map correctly to the mental_states table schema with energy as int4
5. ALL enum types (EnergyLevel, Emotion, WisdomCategory, AppTheme) SHALL be stored as strings in Supabase except energy in mental_states which is int4

### Requirement 9: Migração de Dados Mock

**User Story:** Como desenvolvedor, eu quero migrar os dados mock existentes para o formato do Supabase, para facilitar testes e desenvolvimento.

#### Acceptance Criteria

1. THE sample data in Task.sampleTasks SHALL be convertible to Supabase format
2. THE sample data in Wisdom.sampleWisdom SHALL be convertible to Supabase format
3. THE sample data in UserProfile.sampleProfile SHALL be convertible to Supabase format
4. THE migration SHALL preserve all relationships between entities
5. THE migration SHALL handle UUID conversion correctly

### Requirement 10: Segurança e Row Level Security

**User Story:** Como usuário, eu quero que meus dados sejam privados, para que outros usuários não possam acessá-los.

#### Acceptance Criteria

1. THE Supabase tables SHALL implement Row Level Security (RLS) policies
2. WHEN A user queries data, THE Supabase SHALL return only records where user_id matches the authenticated user
3. THE RLS policies SHALL prevent users from reading other users' data
4. THE RLS policies SHALL prevent users from modifying other users' data
5. THE auth.users table SHALL be protected by default Supabase security policies


### Requirement 11: Novos Modelos para Tabelas Existentes

**User Story:** Como desenvolvedor, eu quero criar modelos Swift para as tabelas existentes no Supabase, para ter acesso completo aos dados.

#### Acceptance Criteria

1. THE app SHALL create a TimelineEvent model to map timeline_events table
2. THE app SHALL create a UsageStats model to map usage_stats table
3. THE app SHALL create a Subscription model to map subscriptions table
4. THE new models SHALL follow the same coding patterns as existing models
5. THE new models SHALL include proper Codable conformance for Supabase integration

### Requirement 12: Adaptação de Campos Existentes

**User Story:** Como desenvolvedor, eu quero adaptar os modelos Swift existentes para incluir campos do Supabase, para manter compatibilidade total.

#### Acceptance Criteria

1. THE Task model SHALL add optional dueDate and timeEstimate fields
2. THE Wisdom model SHALL add optional title field
3. THE UserProfile model SHALL add avatarUrl and language fields
4. THE UserProfile model SHALL remove currentEnergyLevel and currentEmotion (moved to mental_states)
5. THE MentalState SHALL be converted to a full model with id, userId, and notes fields

### Requirement 13: Conversão de Energy Level

**User Story:** Como desenvolvedor, eu quero converter corretamente entre os formatos de energia, para manter consistência entre tasks e mental_states.

#### Acceptance Criteria

1. WHEN storing energy in tasks table, THE app SHALL use text format (high/medium/low)
2. WHEN storing energy in mental_states table, THE app SHALL use int4 format (1-10 scale)
3. THE app SHALL provide conversion methods between EnergyLevel enum and int4
4. THE conversion SHALL map: low=1-3, medium=4-7, high=8-10
5. THE conversion SHALL be bidirectional and consistent
