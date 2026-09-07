# Changelog

## 0.1.1

- `CurrencyInputFormatter` passa a reaproveitar as instâncias de `NumberFormat`
  por configuração (`locale`, `symbol`, `decimalDigits`). Ao parametrizar as
  casas decimais na 0.1.0, o formatador deixou de ser estático e era
  reconstruído a cada campo e a cada chamada de `format()`.

## 0.1.0

Primeira versão, extraída do app `limit_spending`.

- `AppTextField` — campo de texto com botão de limpar, rótulo flutuante, erro
  inline (`errorText`), `onSubmitted` distinto de `onChanged` e estado
  desabilitado (`readOnly` sem `onTap`).
  - Novo `disabledFillColor`: a cor do estado desabilitado deixa de ser fixa.
- `AppTextField.currency` — variante monetária com máscara automática.
  - Novos `decimalDigits` (padrão `2`) e `maxDigits`.
- `CurrencyInputFormatter` — máscara de moeda baseada na menor unidade.
  - Novos `decimalDigits`, `locale` e `symbol`; `format` aceita `decimalDigits`.
