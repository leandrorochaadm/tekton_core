# Changelog

## 0.2.0

**Quebra de compatibilidade.** Três mudanças exigem ajuste nos apps consumidores:

1. `CurrencyInputFormatter` foi renomeado para `UnitInputFormatter` e **não há
   alias de compatibilidade** — o mecanismo sempre foi genérico (menor unidade +
   casas decimais), só o nome dizia o contrário.
2. `AppTextField.currency` passa a exibir `R$` por padrão (o `symbol` antes nem
   chegava ao formatter). Passe `symbol: ''` para voltar ao comportamento antigo.
3. O `maxDigits` da moeda caiu de `12` para `9`, teto único do package — o campo
   monetário agora para em `R$ 9.999.999,99`.

Novidades:

- `UnitSpec` — preset da grandeza, amarrando unidade base, casas decimais,
  prefixo e sufixo num lugar só. Presets `currency` (centavo, 2 casas, `R$`),
  `weight` (grama, 3 casas, `kg`), `length` (centímetro, 2 casas, `m`) e
  `volume` (mililitro, 3 casas, `L`).
- `AppTextField.unit`, `.weight`, `.length` e `.volume` — campos numéricos por
  grandeza, sem nenhum parâmetro de configuração na chamada. `.currency` passa a
  delegar ao `.unit`, de modo que teclado, máscara e unidade são montados num
  ponto só.
- `AppTextField.suffixText` — texto fixo à direita do valor, desenhado pela
  decoração. Fica **fora** do `controller.text`: o usuário não o apaga e ele
  nunca chega ao `parse`.
- `UnitInputFormatter.parse` e `.format` aceitam `maxDigits` opcional e truncam
  no mesmo ponto que a máscara, de modo que o ida-e-volta é fiel dentro do teto.
- Doc comments do package traduzidos para inglês americano, conforme a regra de
  idioma do `CLAUDE.md`.

## 0.1.1

- Cobertura de testes em 100% das linhas (mínimo do package: 80%).

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
