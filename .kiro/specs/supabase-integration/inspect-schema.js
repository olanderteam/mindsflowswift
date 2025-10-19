// Script para inspecionar o schema do Supabase
// Execute com: node inspect-schema.js

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://txlukdftqiqbpdxuuozp.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4bHVrZGZ0cWlxYnBkeHV1b3pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzU2NzcsImV4cCI6MjA3NTg1MTY3N30.D4DXTknWbq2zHp3UKA_ecohfmP-11mNGhCkv8hYfMks';

const supabase = createClient(supabaseUrl, supabaseKey);

async function inspectSchema() {
  console.log('🔍 Inspecionando schema do Supabase...\n');

  // Listar todas as tabelas públicas
  const tables = [
    'tasks',
    'wisdom',
    'user_profiles',
    'mental_states',
    'users',
    'profiles'
  ];

  for (const table of tables) {
    console.log(`\n📋 Tabela: ${table}`);
    console.log('─'.repeat(50));
    
    try {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(1);

      if (error) {
        console.log(`❌ Erro: ${error.message}`);
      } else if (data && data.length > 0) {
        console.log('✅ Tabela existe!');
        console.log('Colunas:', Object.keys(data[0]).join(', '));
        console.log('Exemplo de registro:', JSON.stringify(data[0], null, 2));
      } else {
        console.log('⚠️  Tabela existe mas está vazia');
      }
    } catch (err) {
      console.log(`❌ Erro ao acessar: ${err.message}`);
    }
  }
}

inspectSchema().catch(console.error);
