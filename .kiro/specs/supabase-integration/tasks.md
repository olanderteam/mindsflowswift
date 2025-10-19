# Implementation Plan - Integração Supabase

## Phase 1: Setup e Configuração

- [x] 1. Configurar credenciais e cliente Supabase
  - Criar arquivo de configuração seguro para credenciais do Supabase
  - Atualizar SupabaseManager com URL e anon key reais
  - Inicializar SupabaseClient com configurações corretas
  - Adicionar verificação de conexão na inicialização
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Implementar CacheManager para modo offline
  - Criar classe CacheManager com métodos de cache genéricos
  - Implementar cache em UserDefaults para dados pequenos
  - Implementar cache em FileManager para dados maiores
  - Adicionar enum CacheKey para organizar chaves de cache
  - _Requirements: 7.2, 7.3_

- [x] 3. Implementar SyncManager para sincronização
  - Criar classe SyncManager com fila de operações
  - Implementar struct SyncOperation para representar operações pendentes
  - Adicionar método para enfileirar operações offline
  - Implementar método para sincronizar operações quando voltar online
  - Adicionar estratégias de resolução de conflitos
  - _Requirements: 7.3, 7.4_

- [x] 4. Adicionar monitoramento de rede
  - Implementar NetworkMonitor usando NWPathMonitor
  - Atualizar SupabaseManager.isOnline quando status mudar
  - Disparar sincronização automática quando voltar online
  - _Requirements: 7.1, 7.3_

## Phase 2: Atualização de Modelos

- [x] 5. Atualizar modelo Task
  - Adicionar campos dueDate e timeEstimate opcionais
  - Adicionar CodingKeys para mapear snake_case do Supabase
  - Atualizar método validate() para novos campos
  - Testar serialização/deserialização com Supabase
  - _Requirements: 3.1, 8.1, 12.1_

- [x] 6. Atualizar modelo Wisdom
  - Adicionar campo title opcional
  - Atualizar CodingKeys para emotional_tag
  - Garantir que tags seja array de strings
  - Testar serialização/deserialização com Supabase
  - _Requirements: 4.1, 8.2, 12.2_

- [x] 7. Atualizar modelo UserProfile
  - Adicionar campos avatarUrl e language
  - Remover currentEnergyLevel e currentEmotion
  - Remover isCollapseMode (mover para preferências locais)
  - Atualizar CodingKeys para snake_case
  - _Requirements: 6.1, 8.3, 12.3_

- [x] 8. Converter MentalState para modelo completo
  - Adicionar id e userId ao struct
  - Mudar energy de EnergyLevel para Int (1-10)
  - Adicionar campo notes opcional
  - Implementar computed property energyLevel
  - Adicionar método estático energyToInt()
  - _Requirements: 5.1, 8.4, 12.5, 13.1, 13.2, 13.3, 13.4, 13.5_

- [x] 9. Criar modelo TimelineEvent
  - Criar struct TimelineEvent com todos os campos
  - Implementar Codable e Identifiable
  - Adicionar CodingKeys para snake_case
  - _Requirements: 11.1, 11.4, 11.5_

- [x] 10. Criar modelo UsageStats
  - Criar struct UsageStats com todos os campos
  - Adicionar computed property completionRate
  - Implementar Codable e Identifiable
  - Adicionar CodingKeys para snake_case
  - _Requirements: 11.2, 11.4, 11.5_

- [x] 11. Criar modelo Subscription
  - Criar struct Subscription com todos os campos
  - Criar enum SubscriptionStatus
  - Adicionar computed property isActive
  - Implementar Codable e Identifiable
  - Adicionar CodingKeys para snake_case
  - _Requirements: 11.3, 11.4, 11.5_

## Phase 3: Refatoração do AuthManager

- [x] 12. Implementar autenticação real com Supabase
  - Refatorar método signIn() para usar Supabase Auth
  - Refatorar método signUp() para usar Supabase Auth
  - Implementar signOut() com limpeza de sessão
  - Adicionar resetPassword() e updatePassword()
  - _Requirements: 2.1, 2.2, 2.4, 2.5_

- [x] 13. Implementar gerenciamento de sessão
  - Adicionar checkAuthStatus() para verificar sessão existente
  - Implementar refreshSession() para renovar tokens
  - Salvar tokens no Keychain (não UserDefaults)
  - Carregar sessão automaticamente ao iniciar app
  - _Requirements: 2.3_

- [x] 14. Implementar gerenciamento de perfil
  - Criar método loadUserProfile() para buscar perfil do Supabase
  - Criar método updateUserProfile() para atualizar perfil
  - Criar método createUserProfile() para novos usuários
  - Garantir criação automática de perfil no signup
  - _Requirements: 6.2, 6.3, 6.4_

## Phase 4: Refatoração do SupabaseManager

- [x] 15. Implementar operações CRUD genéricas
  - Criar método fetch<T>() genérico para queries
  - Criar método insert<T>() genérico para inserções
  - Criar método update<T>() genérico para atualizações
  - Criar método delete() genérico para deleções
  - Adicionar tratamento de erros em todos os métodos
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 5.1_

- [x] 16. Implementar queries com filtros
  - Criar struct SupabaseQuery para construir queries
  - Adicionar filtro por userId
  - Adicionar ordenação (orderBy)
  - Adicionar paginação (range)
  - Adicionar limit
  - _Requirements: 3.4, 4.4, 5.3_

- [x] 17. Implementar Realtime subscriptions
  - Criar método subscribe<T>() para subscrições
  - Implementar callback para mudanças em tempo real
  - Adicionar método unsubscribe()
  - Gerenciar lifecycle dos channels
  - _Requirements: 3.4, 4.4_

## Phase 5: Refatoração dos ViewModels

- [ ] 18. Refatorar TasksViewModel
- [x] 18.1 Atualizar método loadTasks() para usar Supabase
  - Substituir dados mock por fetch do Supabase
  - Adicionar fallback para cache em caso de erro
  - Atualizar cache após carregar com sucesso
  - _Requirements: 3.4_

- [x] 18.2 Atualizar método createTask() para usar Supabase
  - Substituir append local por insert no Supabase
  - Enfileirar operação se estiver offline
  - Atualizar cache local
  - _Requirements: 3.1_

- [x] 18.3 Atualizar método updateTask() para usar Supabase
  - Substituir atualização local por update no Supabase
  - Enfileirar operação se estiver offline
  - Atualizar cache local
  - _Requirements: 3.2_

- [x] 18.4 Atualizar método deleteTask() para usar Supabase
  - Substituir remoção local por delete no Supabase
  - Enfileirar operação se estiver offline
  - Atualizar cache local
  - _Requirements: 3.3_

- [x] 18.5 Adicionar subscrição Realtime para tasks
  - Implementar subscribeToChanges() usando Realtime
  - Atualizar lista de tasks quando houver mudanças
  - Unsubscribe quando view desaparecer
  - _Requirements: 3.4_

- [ ] 19. Refatorar WisdomViewModel
- [x] 19.1 Atualizar método loadWisdomEntries() para usar Supabase
  - Substituir dados mock por fetch do Supabase
  - Adicionar fallback para cache em caso de erro
  - Atualizar cache após carregar com sucesso
  - _Requirements: 4.4_

- [x] 19.2 Atualizar método createWisdom() para usar Supabase
  - Substituir append local por insert no Supabase
  - Enfileirar operação se estiver offline
  - Atualizar cache local
  - _Requirements: 4.1_

- [x] 19.3 Atualizar método updateWisdom() para usar Supabase
  - Substituir atualização local por update no Supabase
  - Enfileirar operação se estiver offline
  - Atualizar cache local
  - _Requirements: 4.2_

- [x] 19.4 Atualizar método deleteWisdom() para usar Supabase
  - Substituir remoção local por delete no Supabase
  - Enfileirar operação se estiver offline
  - Atualizar cache local
  - _Requirements: 4.3_

- [ ] 20. Refatorar DashboardViewModel
- [x] 20.1 Atualizar método loadCurrentState() para usar Supabase
  - Buscar estado mental mais recente do Supabase
  - Buscar estatísticas de uso do Supabase
  - Adicionar fallback para cache em caso de erro
  - _Requirements: 5.2, 5.3_

- [x] 20.2 Atualizar método updateMentalState() para usar Supabase
  - Criar novo registro em mental_states no Supabase
  - Converter EnergyLevel para int (1-10)
  - Atualizar estado local após sucesso
  - _Requirements: 5.1, 13.2, 13.3, 13.4_

- [x] 20.3 Implementar carregamento de UsageStats
  - Criar método loadUsageStats() para buscar do Supabase
  - Atualizar dashboard com estatísticas
  - Cachear estatísticas localmente
  - _Requirements: 11.2_

- [x] 20.4 Implementar carregamento de TimelineEvents
  - Criar método loadTimelineEvents() para buscar do Supabase
  - Exibir eventos na timeline do dashboard
  - Cachear eventos localmente
  - _Requirements: 11.1_

## Phase 6: Tratamento de Erros e UX

- [ ] 21. Implementar enum SupabaseError
  - Criar enum com todos os tipos de erro
  - Implementar LocalizedError para mensagens amigáveis
  - Adicionar casos para offline, auth, network, etc
  - _Requirements: 7.4_

- [ ] 22. Adicionar indicadores de loading
  - Atualizar todas as views com ProgressView quando isLoading
  - Adicionar skeleton screens para melhor UX
  - Mostrar feedback visual durante operações
  - _Requirements: 7.4_

- [ ] 23. Adicionar indicador de status online/offline
  - Criar componente visual para mostrar status de conexão
  - Adicionar no topo do app quando offline
  - Mostrar mensagem quando sincronização ocorrer
  - _Requirements: 7.1, 7.5_

- [ ] 24. Melhorar mensagens de erro
  - Substituir mensagens técnicas por mensagens amigáveis
  - Adicionar sugestões de ação para cada tipo de erro
  - Implementar retry automático para erros de rede
  - _Requirements: 7.4_

## Phase 7: Segurança e Validação

- [ ] 25. Implementar validação de dados
  - Adicionar método validate() em Task
  - Adicionar método validate() em Wisdom
  - Adicionar método validate() em UserProfile
  - Validar dados antes de enviar ao Supabase
  - _Requirements: 10.3, 10.4_

- [ ] 26. Implementar armazenamento seguro de tokens
  - Criar KeychainManager para gerenciar tokens
  - Migrar tokens do UserDefaults para Keychain
  - Adicionar criptografia para cache sensível
  - _Requirements: 10.1, 10.2_

- [ ] 27. Verificar políticas RLS no Supabase
  - Confirmar que RLS está habilitado em todas as tabelas
  - Testar que usuários não podem acessar dados de outros
  - Verificar políticas de INSERT, UPDATE, DELETE
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

## Phase 8: Testes

- [ ] 28. Criar testes unitários para SupabaseManager
  - Testar fetch com diferentes queries
  - Testar insert, update, delete
  - Testar comportamento offline
  - Testar tratamento de erros
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 7.2_

- [ ] 29. Criar testes unitários para AuthManager
  - Testar signIn com credenciais válidas e inválidas
  - Testar signUp com dados válidos
  - Testar signOut e limpeza de sessão
  - Testar criação automática de perfil
  - _Requirements: 2.1, 2.2, 2.4, 2.5, 6.4_

- [ ] 30. Criar testes unitários para CacheManager
  - Testar cache de diferentes tipos de dados
  - Testar recuperação de cache
  - Testar limpeza de cache
  - _Requirements: 7.2_

- [ ] 31. Criar testes de integração end-to-end
  - Testar fluxo completo de criação de task
  - Testar fluxo completo de criação de wisdom
  - Testar sincronização offline → online
  - Testar compatibilidade com dados do website
  - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 7.3_

## Phase 9: Otimização e Polish

- [ ] 32. Implementar paginação para listas grandes
  - Adicionar paginação em TasksViewModel
  - Adicionar paginação em WisdomViewModel
  - Implementar infinite scroll nas views
  - _Requirements: 3.4, 4.4_

- [ ] 33. Otimizar Realtime subscriptions
  - Subscrever apenas quando view está ativa
  - Unsubscribe quando view desaparece
  - Debounce updates para evitar flickering
  - _Requirements: 3.4, 4.4_

- [ ] 34. Adicionar analytics e logging
  - Implementar logging de erros
  - Adicionar analytics de uso
  - Monitorar performance de queries
  - _Requirements: 7.4_

- [ ] 35. Documentação final
  - Documentar todos os métodos públicos
  - Criar guia de uso do SupabaseManager
  - Documentar estratégias de cache e sync
  - Atualizar README com instruções de setup
  - _Requirements: 1.1, 1.2_

## Phase 10: Correções de Bugs Críticos

- [x] 36. Corrigir erro de decodificação de time_estimate
  - Atualizar modelo Task para aceitar time_estimate como String ou Int
  - Adicionar custom decoder para converter String para Int
  - Testar com dados existentes no banco
  - _Requirements: 3.1, 8.1_

- [x] 37. Corrigir erro de tags ausente em Wisdom
  - Tornar campo tags opcional no modelo Wisdom
  - Adicionar valor padrão [] quando tags for nil
  - Atualizar custom decoder para lidar com campo ausente
  - Testar com dados existentes no banco
  - _Requirements: 4.1, 8.2_

- [x] 38. Corrigir ProfileView para exibir dados reais
  - Atualizar ProfileView para usar AuthManager.shared.userProfile
  - Exibir nome e email do usuário autenticado
  - Exibir iniciais do nome no avatar
  - Remover dados mockup
  - _Requirements: 6.1, 6.2_

- [x] 39. Corrigir logout não atualizando UI
  - Verificar que AuthManager.isAuthenticated está sendo atualizado
  - Garantir que AuthView está observando AuthManager corretamente
  - Adicionar log para debug do estado de autenticação
  - Testar fluxo completo de logout
  - _Requirements: 2.4_

- [x] 40. Corrigir memory leak em TasksViewModel
  - Remover referências circulares em closures
  - Usar [weak self] em todos os closures assíncronos
  - Cancelar subscriptions no deinit
  - Testar que ViewModel é deallocado corretamente
  - _Requirements: 3.4_

## Phase 11: Validação e Deploy

- [ ] 41. Testes manuais completos
  - Testar login e cadastro
  - Testar CRUD de tasks
  - Testar CRUD de wisdom
  - Testar atualização de estado mental
  - Testar modo offline e sincronização
  - Testar em diferentes dispositivos
  - _Requirements: 2.1, 2.2, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 5.1, 7.1, 7.3_

- [ ] 42. Validar sincronização com website
  - Criar dados no app iOS e verificar no website
  - Criar dados no website e verificar no app iOS
  - Testar edições simultâneas
  - Verificar resolução de conflitos
  - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 4.3_

- [ ] 43. Code review e refatoração final
  - Revisar código para best practices
  - Remover código comentado e debug prints
  - Otimizar imports e dependências
  - Verificar memory leaks
  - _Requirements: Todos_

- [ ] 44. Preparar para produção
  - Configurar diferentes ambientes (dev, staging, prod)
  - Adicionar feature flags se necessário
  - Configurar CI/CD
  - Preparar release notes
  - _Requirements: 1.1, 1.2_
