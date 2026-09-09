# Changelog

## 0.3.0

Compatível com a 0.2.0: tudo o que entra é opcional e o default repete o
comportamento de hoje — nenhum app existente muda de aparência.

- `AppTextField.focusNode`, `.controller` e `.hintText` deixam de ser
  obrigatórios. Sem `focusNode` ou `controller`, o widget cria o seu e o
  descarta no fim — nunca o que veio de fora. Adotar o campo num formulário
  comum deixa de cobrar um `FocusNode` e um `TextEditingController` criados à
  mão, e de transformar em `StatefulWidget` toda tela que não fosse uma.
- `AppTextField.initialValue` — texto de abertura do campo, quando o
  `controller` é nulo. Passar os dois juntos dispara um `assert`.
- `AppTextField.decoration` — a `InputDecoration` do chamador. O widget
  sobrepõe só o que é dele (rótulo flutuante, preenchimento, botão de limpar,
  `errorText` e `suffixText`); `helperText`, `errorMaxLines`, `prefixText`,
  `prefixIcon`, `border`, `isDense` e `contentPadding` passam a vir daqui. Um
  `suffixIcon` passado por aqui aparece quando o widget não tem sufixo próprio.
- `AppTextField.enabled` — campo indisponível durante um salvamento, **sem** a
  tarja cinza do `readOnly` sem `onTap`. Enquanto `false`, o `✕` não aparece.
- `AppTextField.showClearButton` — desliga o `✕` no campo estreito demais para
  gastar 24 px com ele.
- `AppTextField.autofocus` — o campo pega o foco assim que aparece.
- `AppTextField.textCapitalization` e `.textInputAction` — antes fixos em
  `sentences` e `done`.
- As cinco factories (`unit`, `currency`, `weight`, `length`, `volume`) recebem
  todos os parâmetros acima, com um teste por factory que a constrói sem
  `focusNode`, sem `controller` e sem `hintText`.

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
