# Como Adicionar Supabase ao Projeto Xcode

## ⚠️ Ação Necessária

O projeto está configurado para usar o Supabase, mas a dependência precisa ser adicionada manualmente no Xcode.

## Passos para Adicionar Supabase Swift SDK:

### 1. Abrir o Projeto no Xcode
```bash
open "Minds Flow.xcodeproj"
```

### 2. Adicionar Swift Package

1. No Xcode, clique no projeto "Minds Flow" no navegador de arquivos (lado esquerdo)
2. Selecione o target "Minds Flow"
3. Vá para a aba **"Package Dependencies"** (ou "Swift Packages" em versões antigas)
4. Clique no botão **"+"** para adicionar um novo package

### 3. Configurar o Package

Na janela que abrir:

**URL do Repositório:**
```
https://github.com/supabase/supabase-swift.git
```

**Versão:**
- Dependency Rule: **"Up to Next Major Version"**
- Version: **2.5.1**

### 4. Selecionar Produtos

Quando perguntado quais produtos adicionar, selecione:
- ✅ **Supabase**

### 5. Adicionar ao Target

Certifique-se de que o package está adicionado ao target "Minds Flow"

### 6. Build do Projeto

Após adicionar o package:
1. Aguarde o Xcode baixar e resolver as dependências
2. Build o projeto: **Cmd + B**
3. Os erros de "Unable to find module dependency: 'Supabase'" devem desaparecer

## Verificação

Após adicionar o package, verifique se os seguintes arquivos compilam sem erros:

- ✅ `Minds Flow/Services/SupabaseManager.swift`
- ✅ `Minds Flow/Services/AuthManager.swift`
- ✅ `Minds Flow/Services/SupabaseConfig.swift`
- ✅ `Minds Flow/Services/SyncManager.swift`

## Troubleshooting

### Se o erro persistir:

1. **Limpar Build Folder:**
   - Menu: Product → Clean Build Folder (Shift + Cmd + K)
   - Depois: Product → Build (Cmd + B)

2. **Resetar Package Cache:**
   - Fechar Xcode
   - Deletar pasta: `~/Library/Developer/Xcode/DerivedData`
   - Reabrir Xcode e fazer build

3. **Verificar Swift Version:**
   - O projeto requer Swift 5.9+
   - Xcode 15.0+ recomendado

4. **Reinstalar Package:**
   - Remover o package das dependências
   - Adicionar novamente seguindo os passos acima

## Alternativa: Usar CocoaPods ou Carthage

Se preferir, você pode usar outros gerenciadores de dependências:

### CocoaPods
```ruby
pod 'Supabase', '~> 2.5'
```

### Carthage
```
github "supabase/supabase-swift" ~> 2.5
```

## Próximos Passos

Após adicionar o Supabase com sucesso:

1. ✅ Build do projeto deve passar sem erros
2. ✅ Todos os imports `import Supabase` devem funcionar
3. ✅ O app está pronto para conectar ao Supabase real
4. 🚀 Pode testar login, cadastro e operações CRUD

## Documentação Oficial

Para mais informações:
- [Supabase Swift Docs](https://supabase.com/docs/reference/swift)
- [Swift Package Manager Guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)
