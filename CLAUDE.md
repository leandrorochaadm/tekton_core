# tekton_core

Kit base compartilhado entre projetos Flutter: widgets, formatters e utilitários
reaproveitados em mais de um app. Publicado por Git (`ref: vX.Y.Z`), sem `pub.dev`.

## Idioma — regra obrigatória

Duas camadas, dois idiomas. Não misture.

### Código: inglês americano

Tudo o que só o desenvolvedor lê é escrito em **inglês americano**:

- nomes de classes, métodos, variáveis, parâmetros, enums, arquivos e diretórios;
- comentários de linha e de bloco;
- doc comments (`///`);
- mensagens de `assert`, nomes de testes e descrições de `group`/`test`;
- mensagens de commit e nomes de branch.

```dart
// ✅ certo
/// Formats the minor unit (1000000) as displayed text ("1.000,000").
///
/// The suffix is drawn by the decoration, never by the controller text.
String format(int value, {bool withSuffix = true}) { ... }

// ❌ errado
/// Formata a menor unidade (1000000) no texto exibido ("1.000,000").
String format(int value, {bool withSuffix = true}) { ... }
```

### Telas: português do Brasil, para leigos

Todo texto que o **usuário final** lê é escrito em **português do Brasil**, em
linguagem que alguém sem conhecimento técnico entende de primeira:

- rótulos, `hintText`, placeholders e títulos;
- textos de botão, mensagens de erro, avisos e confirmações;
- estados vazios e mensagens de carregamento;
- unidades e formatação seguem o padrão brasileiro (`1.000,000 kg`, vírgula
  decimal e ponto de milhar).

```dart
// ✅ certo — código em inglês, texto de tela em português
AppTextField.weight(
  focusNode: focusNode,
  controller: controller,
  hintText: 'Peso',
  errorText: 'Informe um peso maior que zero',
)

// ❌ errado — texto de tela em inglês
AppTextField.weight(hintText: 'Weight', errorText: 'Weight must be positive')
```

Escreva a mensagem que o usuário lê pensando em quem não é da área: prefira
"Não foi possível salvar. Tente de novo." a "Erro 500 na requisição".

### Onde a regra não se aplica

Documentação de projeto voltada a quem desenvolve — `README.md`, `CHANGELOG.md`,
`CLAUDE.md` e os planos em `temp/plan/` — permanece em português, como já está hoje.

## Estrutura

- `lib/tekton_core.dart` — barrel; **único** ponto de `export` do package.
- `lib/src/formatters/` — formatters de entrada (`TextInputFormatter`) e presets.
- `lib/src/widgets/` — widgets reutilizáveis.
- `test/` — espelha a estrutura de `lib/src/`.

Dentro de `lib/src/`, os imports são **relativos**. Só o barrel é importado pelos
apps consumidores.

## Qualidade

- `fvm flutter analyze` sem issues e `fvm flutter test` verde antes de qualquer commit.
- Cobertura de linhas **mínima de 80%** (`fvm flutter test --coverage`).
- Lints ativos em `analysis_options.yaml`: `prefer_const_constructors`,
  `prefer_final_locals`, `require_trailing_commas`.
- Linhas com no máximo 120 caracteres.
- Mudança de API pública sobe a versão no `pubspec.yaml` **e** ganha entrada no
  `CHANGELOG.md`, na mesma alteração.
