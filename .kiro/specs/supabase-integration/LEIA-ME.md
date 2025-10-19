# Como Inspecionar o Schema do Supabase

## Opção 1: Via Dashboard do Supabase (Recomendado)

1. Acesse: https://supabase.com/dashboard/project/txlukdftqiqbpdxuuozp
2. Vá em **Table Editor** no menu lateral
3. Liste todas as tabelas existentes
4. Para cada tabela, anote:
   - Nome da tabela
   - Colunas (nome, tipo, nullable, default)
   - Chaves primárias
   - Chaves estrangeiras
   - Índices

## Opção 2: Via SQL Editor

1. Acesse: https://supabase.com/dashboard/project/txlukdftqiqbpdxuuozp/sql
2. Execute este SQL para listar todas as tabelas:

```sql
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_schema = 'public'
ORDER BY 
    table_name, ordinal_position;
```

3. Para ver as relações entre tabelas:

```sql
SELECT
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public';
```

## Opção 3: Via Script Node.js

Se você tiver Node.js instalado:

```bash
cd .kiro/specs/supabase-integration
npm install @supabase/supabase-js
node inspect-schema.js
```

## O que preciso saber:

Por favor, me informe:

1. **Quais tabelas existem?** (ex: tasks, wisdom, users, etc)
2. **Estrutura de cada tabela** (colunas e tipos)
3. **Como os dados estão relacionados?** (foreign keys)
4. **Exemplos de dados** (se possível, 1-2 registros de cada tabela)

Com essas informações, vou:
- Mapear as tabelas existentes para os modelos Swift
- Adaptar os ViewModels para usar o schema real
- Garantir sincronização entre iOS e web
