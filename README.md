# PawCare – Gestão Pet (Trabalho V2)

Projeto Flutter para demonstração acadêmica. Os dados são mantidos em memória (mockados), sem API ou banco de dados.

## Funcionalidades
- Dashboard com indicadores e atalhos.
- Cadastro, listagem, pesquisa e filtro de animais.
- Detalhes, edição e exclusão de animais (CRUD).
- Catálogo de serviços com preços ilustrativos.
- Criação, edição e cancelamento de agendamentos.
- Navegação inferior entre Início, Animais, Serviços e Agenda.
- Formulários com validação básica.

## Executar
No terminal, dentro da pasta `pawcare`:

```bash
flutter pub get
flutter run -d chrome
```

Para analisar o código:

```bash
flutter analyze
```

Os registros de exemplo são reiniciados quando o aplicativo é fechado/recarregado, pois não há persistência em banco de dados.
