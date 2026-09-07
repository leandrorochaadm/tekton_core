# tekton_core

Kit base compartilhado entre projetos Flutter: widgets, formatters e utilitários
reaproveitados em mais de um app.

## Instalação

```yaml
dependencies:
  tekton_core:
    git:
      url: https://github.com/leandrorochaadm/tekton_core.git
      ref: v0.1.1
```

```dart
import 'package:tekton_core/tekton_core.dart';
```

## Conteúdo

| Símbolo | O que é |
|---|---|
| `AppTextField` | Campo de texto com botão de limpar, rótulo flutuante, erro inline e estado desabilitado |
| `AppTextField.currency` | Variante monetária com máscara automática |
| `CurrencyInputFormatter` | Máscara de moeda pt_BR baseada na menor unidade (centavos) |

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

## `AppTextField.currency`

O usuário digita **só dígitos**; a máscara insere separador de milhar e vírgula
decimal. Nunca é possível digitar um formato inválido.

```dart
AppTextField.currency(
  focusNode: focusNode,
  controller: controller,
  hintText: 'Valor',
)                              // digita 100000 -> "1.000,00"

AppTextField.currency(
  focusNode: focusNode,
  controller: controller,
  hintText: 'Quantidade',
  decimalDigits: 0,
)                              // digita 1000   -> "1.000"
```

Leia e escreva o valor sempre na **menor unidade** (`int`):

```dart
final cents = CurrencyInputFormatter.parse(controller.text);      // "1.000,00" -> 100000
controller.text = CurrencyInputFormatter.format(100000);          // 100000 -> "1.000,00"
controller.text = CurrencyInputFormatter.format(1000, decimalDigits: 0); // -> "1.000"
```

> `parse` independe de `decimalDigits` (só extrai os dígitos). `format` precisa
> receber o **mesmo** `decimalDigits` usado no campo.

### Parâmetros do `CurrencyInputFormatter`

| Parâmetro | Padrão | Para quê |
|---|---|---|
| `decimalDigits` | `2` | Casas decimais. `0` = valor inteiro |
| `maxDigits` | `12` | Teto de dígitos, evita overflow numérico |
| `locale` | `'pt_BR'` | Separadores de milhar e decimal |
| `symbol` | `''` | Prefixo de moeda (o rótulo do campo costuma bastar) |

## Desenvolvimento

Versão do Flutter fixada em `.fvmrc` (3.41.9).

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```
