# tekton_core

Kit base compartilhado entre projetos Flutter: widgets, formatters e utilitários
reaproveitados em mais de um app.

## Instalação

```yaml
dependencies:
  tekton_core:
    git:
      url: https://github.com/leandrorochaadm/tekton_core.git
      ref: v0.2.0
```

```dart
import 'package:tekton_core/tekton_core.dart';
```

## Conteúdo

| Símbolo | O que é |
|---|---|
| `AppTextField` | Campo de texto com botão de limpar, rótulo flutuante, erro inline e estado desabilitado |
| `AppTextField.unit` | Campo numérico de qualquer grandeza, configurado por um `UnitSpec` |
| `AppTextField.currency` | Campo monetário — digita centavos, exibe `R$ 1.000,00` |
| `AppTextField.weight` | Campo de peso — digita gramas, exibe `1.000,000 kg` |
| `AppTextField.length` | Campo de comprimento — digita centímetros, exibe `1.000,00 m` |
| `AppTextField.volume` | Campo de volume — digita mililitros, exibe `1.000,000 L` |
| `UnitSpec` | Preset da grandeza: amarra unidade base, casas decimais, prefixo e sufixo |
| `UnitInputFormatter` | Máscara pt_BR baseada na menor unidade da grandeza |

## `AppTextField`

```dart
AppTextField(
  focusNode: focusNode,
  controller: controller,
  hintText: 'Descrição',
  errorText: state.descriptionError,
  onChanged: controller.onDescriptionChanged,
)
```

- **Botão de limpar** aparece sozinho quando há texto; some quando o campo está
  desabilitado.
- **Desabilitado** é `readOnly: true` **sem** `onTap`. Com `onTap`, o campo vira
  "toque para selecionar" e continua interativo.
- **`onSubmitted`** dispara só na ação "done" do teclado; `onChanged` dispara a
  cada tecla. Sem `onSubmitted`, o submit também chama `onChanged`.
- **`onTapOutside: (_) {}`** impede que toques na tela tirem o foco — útil quando
  a perda de foco é usada como sinal (ex.: "OK" do teclado numérico no iPhone).
- **`disabledFillColor`** ajusta o fundo do estado desabilitado (padrão
  `Colors.grey.shade800`, pensado para tema escuro).

## Campos por unidade

O usuário digita **só dígitos**, sempre na **menor unidade** da grandeza; a
máscara insere separador de milhar e vírgula decimal, e a unidade é desenhada
pela decoração do campo — nunca entra no `controller.text`. Nunca é possível
digitar um formato inválido.

| Factory | Unidade digitada (e armazenada) | Exibição | Casas | Unidade na tela |
|---|---|---|---|---|
| `AppTextField.currency` | centavo | `R$ 1.000,00` | 2 | prefixo `R$` |
| `AppTextField.weight` | grama | `1.000,000 kg` | 3 | sufixo `kg` |
| `AppTextField.length` | centímetro | `1.000,00 m` | 2 | sufixo `m` |
| `AppTextField.volume` | mililitro | `1.000,000 L` | 3 | sufixo `L` |

```dart
AppTextField.currency(focusNode: f, controller: c, hintText: 'Valor');   // R$ 1.000,00
AppTextField.weight(focusNode: f, controller: c, hintText: 'Peso');      // 1.000,000  kg
AppTextField.length(focusNode: f, controller: c, hintText: 'Altura');    // 1.000,00   m
AppTextField.volume(focusNode: f, controller: c, hintText: 'Volume');    // 1.000,000  L
```

Nenhum deles expõe `decimalDigits`, `maxDigits` ou a unidade: a grandeza é
fechada pelo preset, então combinar grama com 2 casas deixa de ser possível.
Para uma grandeza fora da lista, use `AppTextField.unit` com um `UnitSpec`
próprio.

### Ler e escrever o valor

Sempre na **menor unidade** (`int`), pelo preset da grandeza:

```dart
final grams = UnitSpec.weight.parse(controller.text);   // "1.000,000" -> 1000000
controller.text = UnitSpec.weight.format(1000000);      // 1000000 -> "1.000,000"

final cents = UnitSpec.currency.parse(controller.text); // "R$ 1.000,00" -> 100000
controller.text = UnitSpec.currency.format(100000);     // 100000 -> "R$ 1.000,00"
```

> **Pré-preencha com `UnitSpec.currency.format(v)`**, não com
> `UnitInputFormatter.format(v)`: o padrão de `symbol` no formatter é `''`, então
> o campo abriria em `1.000,00` e o texto saltaria para `R$ 1.000,00` na primeira
> tecla.

### `symbol` é prefixo, e o separador é NBSP

O `symbol` sai à **esquerda** do número (é assim que o padrão `pt_BR` do `intl`
funciona) e **não** leva espaço à direita — o padrão do locale já insere o
separador. Uma unidade à direita, como `kg`, não passa por `symbol`: ela é o
`suffix` do preset, desenhado pela decoração.

Esse separador é um **NO-BREAK SPACE** (`U+00A0`), não o espaço da barra. Todo
literal comparado com o texto do campo precisa do escape:

```dart
expect(UnitSpec.currency.format(100000), 'R\$\u{A0}1.000,00');   // ✅ passa
expect(UnitSpec.currency.format(100000), r'R$ 1.000,00');        // ❌ falha
```

### `UnitSpec`

| Parâmetro | Padrão | Para quê |
|---|---|---|
| `decimalDigits` | — | Casas decimais; o expoente entre a menor unidade e a exibida. `0` = valor inteiro |
| `symbol` | `''` | Prefixo, à esquerda do número. Sem espaço à direita |
| `suffix` | `null` | Sufixo, à direita do número. Fica fora do `controller.text` |
| `maxDigits` | `9` | Teto de dígitos, evita overflow numérico |

`format` e `parse` aplicam o mesmo teto de `maxDigits`, então
`spec.parse(spec.format(v))` devolve `v` dentro do teto e o valor truncado acima
dele — nunca um terceiro número.

### Migrando da 0.1.x

`CurrencyInputFormatter` foi **removido** na 0.2.0:

| 0.1.x | 0.2.0 |
|---|---|
| `CurrencyInputFormatter(...)` | `UnitInputFormatter(...)`, ou `UnitSpec.currency.formatter()` |
| `CurrencyInputFormatter.parse(text)` | `UnitSpec.currency.parse(text)` |
| `CurrencyInputFormatter.format(v)` | `UnitSpec.currency.format(v)` |

Atenção às outras duas quebras: `AppTextField.currency` passa a exibir `R$` por
padrão (passe `symbol: ''` para voltar ao comportamento antigo) e o `maxDigits`
da moeda caiu de `12` para `9` (teto `R$ 9.999.999,99`).

## Desenvolvimento

Versão do Flutter fixada em `.fvmrc` (3.41.9).

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter test --coverage   # cobertura mínima: 80% (hoje em 100%)
```

Cobertura é requisito do package: **mínimo de 80% de linhas**. Leia o resultado
com `lcov --summary coverage/lcov.info` ou `genhtml coverage/lcov.info -o coverage/html`.
