
import 'package:flutter/material.dart';

void main() => runApp(const PawCareApp());

const verde = Color(0xFF183C32);
const dourado = Color(0xFFC5A46D);
const areia = Color(0xFFE9E1D4);
const fundo = Color(0xFFF7F5F0);
const grafite = Color(0xFF242824);

class PawCareApp extends StatelessWidget {
  const PawCareApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PawCare – Gestão Pet',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: fundo,
          colorScheme: ColorScheme.fromSeed(seedColor: verde),
          appBarTheme: const AppBarTheme(
            backgroundColor: fundo,
            foregroundColor: verde,
            centerTitle: false,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: verde, fontSize: 21, fontWeight: FontWeight.w700,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: areia),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: areia),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: verde, width: 1.5),
            ),
          ),
        ),
        home: const MainShell(),
      );
}

class Pet {
  String nome, especie, raca, idade, tutor, telefone, observacoes;
  Pet({
    required this.nome, required this.especie, required this.raca,
    required this.idade, required this.tutor, required this.telefone,
    this.observacoes = '',
  });
}

class PetService {
  final String nome, descricao;
  final double preco;
  final IconData icon;
  const PetService(this.nome, this.descricao, this.preco, this.icon);
}

class Appointment {
  Pet pet;
  String servico, data, horario, status;
  double valor;
  Appointment({
    required this.pet, required this.servico, required this.data,
    required this.horario, required this.status, required this.valor,
  });
}

const servicos = <PetService>[
  PetService('Banho', 'Higienização completa e secagem', 45, Icons.shower_outlined),
  PetService('Tosa', 'Tosa higiênica ou na tesoura', 65, Icons.content_cut),
  PetService('Banho e tosa', 'Cuidado completo para seu pet', 95, Icons.spa_outlined),
  PetService('Hidratação', 'Tratamento especial para os pelos', 35, Icons.water_drop_outlined),
  PetService('Corte de unhas', 'Cuidado delicado das patinhas', 20, Icons.pets_outlined),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int aba = 0;
  late final List<Pet> pets = [
    Pet(nome: 'Thor', especie: 'Cachorro', raca: 'Golden Retriever',
      idade: '3 anos', tutor: 'Mariana Costa', telefone: '(34) 99999-1111',
      observacoes: 'Muito dócil. Gosta de brincar.'),
    Pet(nome: 'Luna', especie: 'Gato', raca: 'Persa', idade: '2 anos',
      tutor: 'Rafael Mendes', telefone: '(34) 98888-2222',
      observacoes: 'Sensível a barulhos altos.'),
    Pet(nome: 'Mel', especie: 'Cachorro', raca: 'Shih-tzu', idade: '5 anos',
      tutor: 'Camila Alves', telefone: '(34) 97777-3333'),
  ];
  late final List<Appointment> agenda = [
    Appointment(pet: pets[0], servico: 'Banho e tosa', data: '07/11/2026',
      horario: '10:00', status: 'Confirmado', valor: 95),
    Appointment(pet: pets[1], servico: 'Hidratação', data: '07/11/2026',
      horario: '14:30', status: 'Pendente', valor: 35),
  ];

  void abrirFormulario({Pet? pet}) async {
    final resultado = await Navigator.push<Pet>(context,
      MaterialPageRoute(builder: (_) => PetFormScreen(pet: pet)));
    if (resultado != null) {
      setState(() {
        if (pet == null) { pets.add(resultado); }
        else {
          final i = pets.indexOf(pet);
          if (i >= 0) pets[i] = resultado;
          for (final a in agenda) {
            if (identical(a.pet, pet)) a.pet = resultado;
          }
        }
      });
    }
  }

  void abrirDetalhes(Pet pet) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PetDetailsScreen(
      pet: pet,
      onEdit: () { Navigator.pop(context); abrirFormulario(pet: pet); },
      onDelete: () {
        setState(() {
          pets.remove(pet);
          agenda.removeWhere((a) => identical(a.pet, pet));
        });
        Navigator.pop(context);
      },
      onSchedule: () { Navigator.pop(context); setState(() => aba = 3); _novoAgendamento(pet); },
    )));
  }

  Future<void> _novoAgendamento([Pet? pet, String? servicoInicial]) async {
    if (pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um animal antes de agendar.')));
      setState(() => aba = 1);
      return;
    }
    final novo = await Navigator.push<Appointment>(context,
      MaterialPageRoute(builder: (_) => AppointmentFormScreen(pets: pets, petInicial: pet, servicoInicial: servicoInicial)));
    if (novo != null) setState(() => agenda.add(novo));
  }

  Future<void> _editarAgendamento(Appointment item) async {
    final atualizado = await Navigator.push<Appointment>(context,
      MaterialPageRoute(builder: (_) => AppointmentFormScreen(pets: pets, existente: item)));
    if (atualizado != null) setState(() {
      final i = agenda.indexOf(item);
      if (i >= 0) agenda[i] = atualizado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      DashboardScreen(pets: pets, agenda: agenda,
        irPara: (i) => setState(() => aba = i),
        novoPet: () { setState(() => aba = 1); abrirFormulario(); }),
      PetsScreen(pets: pets, onAdd: () => abrirFormulario(),
        onDetails: abrirDetalhes),
      ServicesScreen(onSchedule: (s) {
        if (pets.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastre um pet antes de agendar.')));
          setState(() => aba = 1);
        } else {
          _novoAgendamento(null, s.nome);
        }
      }),
      AppointmentsScreen(agenda: agenda, onAdd: () => _novoAgendamento(),
        onEdit: _editarAgendamento, onCancel: (a) {
          setState(() => a.status = 'Cancelado');
        }),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: aba, children: paginas)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: aba,
        onDestinationSelected: (i) => setState(() => aba = i),
        backgroundColor: Colors.white,
        indicatorColor: areia,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Animais'),
          NavigationDestination(icon: Icon(Icons.spa_outlined), label: 'Serviços'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Agenda'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final List<Pet> pets;
  final List<Appointment> agenda;
  final ValueChanged<int> irPara;
  final VoidCallback novoPet;
  const DashboardScreen({super.key, required this.pets, required this.agenda,
    required this.irPara, required this.novoPet});

  @override
  Widget build(BuildContext context) {
    final ativos = agenda.where((a) => a.status != 'Cancelado').length;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PAWCARE  /  GESTÃO PET', style: TextStyle(
            color: dourado, fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          const Text('Olá, seja bem-vindo', style: TextStyle(
            color: verde, fontSize: 25, fontWeight: FontWeight.w800)),
          Text('Organize os cuidados com carinho.', style: TextStyle(color: grafite.withOpacity(.6))),
        ])),
        const CircleAvatar(radius: 25, backgroundColor: verde,
          child: Icon(Icons.pets, color: dourado, size: 25)),
      ]),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: verde, borderRadius: BorderRadius.circular(22)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome, color: dourado, size: 25),
          SizedBox(height: 15),
          Text('Cuidado que transforma.', style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 7),
          Text('Uma gestão simples e elegante para cada momento do seu pet.',
            style: TextStyle(color: Colors.white70, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _statCard('Animais', '${pets.length}', Icons.pets_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Na agenda', '$ativos', Icons.event_available_outlined)),
      ]),
      const SizedBox(height: 25),
      _sectionTitle('Acesso rápido', 'Explore o PawCare'),
      const SizedBox(height: 12),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 11, crossAxisSpacing: 11,
        childAspectRatio: 2.25, children: [
          _quickAction(Icons.pets_outlined, 'Animais', () => irPara(1)),
          _quickAction(Icons.spa_outlined, 'Serviços', () => irPara(2)),
          _quickAction(Icons.calendar_month_outlined, 'Agendamentos', () => irPara(3)),
          _quickAction(Icons.add_circle_outline, 'Novo animal', novoPet),
        ]),
      const SizedBox(height: 25),
      _sectionTitle('Próximos atendimentos', 'Compromissos cadastrados'),
      const SizedBox(height: 10),
      if (agenda.where((a) => a.status != 'Cancelado').isEmpty)
        const _EmptyState(text: 'Nenhum atendimento agendado.')
      else
        ...agenda.where((a) => a.status != 'Cancelado').take(3).map((a) =>
          _AppointmentTile(item: a, onTap: () => irPara(3))),
    ]);
  }
}

Widget _statCard(String label, String value, IconData icon) => Container(
  padding: const EdgeInsets.all(17),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17),
    border: Border.all(color: areia)),
  child: Row(children: [
    Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(
      color: fundo, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: verde, size: 21)),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: verde, fontSize: 22, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: grafite.withOpacity(.6), fontSize: 12)),
    ]),
  ]),
);

Widget _sectionTitle(String title, String subtitle) => Column(
  crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: verde, fontSize: 19, fontWeight: FontWeight.bold)),
    const SizedBox(height: 3),
    Text(subtitle, style: TextStyle(color: grafite.withOpacity(.55), fontSize: 12)),
  ]);

Widget _quickAction(IconData icon, String label, VoidCallback onTap) => Material(
  color: Colors.white, borderRadius: BorderRadius.circular(15),
  child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
        border: Border.all(color: areia)),
      child: Row(children: [
        Icon(icon, color: dourado, size: 22), const SizedBox(width: 9),
        Expanded(child: Text(label, style: const TextStyle(
          color: grafite, fontWeight: FontWeight.w600, fontSize: 13))),
        const Icon(Icons.chevron_right, color: verde, size: 18),
      ]),
    )),
);

class PetsScreen extends StatefulWidget {
  final List<Pet> pets;
  final VoidCallback onAdd;
  final ValueChanged<Pet> onDetails;
  const PetsScreen({super.key, required this.pets, required this.onAdd, required this.onDetails});
  @override
  State<PetsScreen> createState() => _PetsScreenState();
}
class _PetsScreenState extends State<PetsScreen> {
  String busca = 'Todos';
  String termo = '';
  @override
  Widget build(BuildContext context) {
    final lista = widget.pets.where((p) =>
      (busca == 'Todos' || p.especie == busca) &&
      p.nome.toLowerCase().contains(termo.toLowerCase())).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nossos animais', style: TextStyle(color: verde, fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Cadastre e acompanhe cada pet.', style: TextStyle(color: grafite.withOpacity(.6))),
          const SizedBox(height: 15),
          TextField(onChanged: (v) => setState(() => termo = v),
            decoration: const InputDecoration(hintText: 'Buscar pelo nome...', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: ['Todos', 'Cachorro', 'Gato', 'Outro'].map((f) =>
            ChoiceChip(label: Text(f), selected: busca == f,
              selectedColor: areia, onSelected: (_) => setState(() => busca = f))).toList()),
        ],
      )),
      Expanded(child: lista.isEmpty
        ? const _EmptyState(text: 'Nenhum animal encontrado.')
        : ListView.builder(padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
          itemCount: lista.length, itemBuilder: (_, i) {
            final pet = lista[i];
            return Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: areia)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: CircleAvatar(radius: 25, backgroundColor: areia,
                  child: Icon(pet.especie == 'Gato' ? Icons.cruelty_free : Icons.pets, color: verde)),
                title: Text(pet.nome, style: const TextStyle(color: verde, fontWeight: FontWeight.bold)),
                subtitle: Text('${pet.especie} • ${pet.raca}\nTutor: ${pet.tutor}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right, color: dourado),
                onTap: () => widget.onDetails(pet),
              ));
          })),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: SizedBox(
        width: double.infinity, child: FilledButton.icon(
          onPressed: widget.onAdd, icon: const Icon(Icons.add),
          label: const Text('Cadastrar novo animal'),
          style: FilledButton.styleFrom(backgroundColor: verde, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14)),
        ))),
    ]);
  }
}

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;
  final VoidCallback onEdit, onDelete, onSchedule;
  const PetDetailsScreen({super.key, required this.pet, required this.onEdit,
    required this.onDelete, required this.onSchedule});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalhes do animal')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: verde, borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          const CircleAvatar(radius: 38, backgroundColor: areia,
            child: Icon(Icons.pets, color: verde, size: 38)),
          const SizedBox(height: 12),
          Text(pet.nome, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text('${pet.especie} • ${pet.raca}', style: const TextStyle(color: Colors.white70)),
        ])),
      const SizedBox(height: 22),
      _sectionTitle('Informações do pet', 'Dados cadastrados'),
      const SizedBox(height: 10),
      _detail('Idade', pet.idade, Icons.cake_outlined),
      _detail('Tutor', pet.tutor, Icons.person_outline),
      _detail('Telefone', pet.telefone, Icons.phone_outlined),
      _detail('Observações', pet.observacoes.isEmpty ? 'Nenhuma observação.' : pet.observacoes, Icons.notes),
      const SizedBox(height: 22),
      FilledButton.icon(onPressed: onSchedule, icon: const Icon(Icons.calendar_month),
        label: const Text('Agendar serviço'), style: FilledButton.styleFrom(
          backgroundColor: verde, foregroundColor: Colors.white, padding: const EdgeInsets.all(14))),
      const SizedBox(height: 9),
      OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar cadastro'), style: OutlinedButton.styleFrom(
          foregroundColor: verde, padding: const EdgeInsets.all(14))),
      const SizedBox(height: 9),
      TextButton.icon(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Excluir animal?'),
        content: Text('Deseja realmente excluir ${pet.nome}? Os agendamentos dele também serão removidos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Voltar')),
          FilledButton(onPressed: () { Navigator.pop(context); onDelete(); },
            style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Excluir')),
        ],
      )), icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text('Excluir cadastro', style: TextStyle(color: Colors.red))),
    ]),
  );
}

Widget _detail(String label, String value, IconData icon) => Container(
  margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
    border: Border.all(color: areia)),
  child: Row(children: [
    Icon(icon, color: dourado), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: grafite.withOpacity(.55), fontSize: 12)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(color: grafite, fontWeight: FontWeight.w600)),
    ])),
  ]),
);

class PetFormScreen extends StatefulWidget {
  final Pet? pet;
  const PetFormScreen({super.key, this.pet});
  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}
class _PetFormScreenState extends State<PetFormScreen> {
  final keyForm = GlobalKey<FormState>();
  late final TextEditingController nome, raca, idade, tutor, telefone, obs;
  String especie = 'Cachorro';
  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    nome = TextEditingController(text: p?.nome ?? '');
    raca = TextEditingController(text: p?.raca ?? '');
    idade = TextEditingController(text: p?.idade ?? '');
    tutor = TextEditingController(text: p?.tutor ?? '');
    telefone = TextEditingController(text: p?.telefone ?? '');
    obs = TextEditingController(text: p?.observacoes ?? '');
    especie = p?.especie ?? 'Cachorro';
  }
  @override
  void dispose() {
    nome.dispose(); raca.dispose(); idade.dispose(); tutor.dispose();
    telefone.dispose(); obs.dispose(); super.dispose();
  }
  Widget campo(String label, TextEditingController c, {bool obrigatorio = true,
    TextInputType tipo = TextInputType.text}) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(controller: c, keyboardType: tipo, maxLines: label == 'Observações' ? 3 : 1,
        decoration: InputDecoration(labelText: label),
        validator: (v) => obrigatorio && (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null));
  void salvar() {
    if (!keyForm.currentState!.validate()) return;
    if (telefone.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um telefone válido.')));
      return;
    }
    Navigator.pop(context, Pet(nome: nome.text.trim(), especie: especie,
      raca: raca.text.trim(), idade: idade.text.trim(), tutor: tutor.text.trim(),
      telefone: telefone.text.trim(), observacoes: obs.text.trim()));
  }
  @override
  Widget build(BuildContext context) {
    final editando = widget.pet != null;
    return Scaffold(appBar: AppBar(title: Text(editando ? 'Editar animal' : 'Novo animal')),
      body: Form(key: keyForm, child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Dados do animal', style: TextStyle(color: verde, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        campo('Nome do animal', nome),
        DropdownButtonFormField<String>(value: especie, decoration: const InputDecoration(labelText: 'Espécie'),
          items: const ['Cachorro', 'Gato', 'Outro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) { if (v != null) setState(() => especie = v); }),
        const SizedBox(height: 13),
        campo('Raça', raca), campo('Idade', idade),
        const SizedBox(height: 5),
        const Text('Dados do tutor', style: TextStyle(color: verde, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        campo('Nome do tutor', tutor),
        campo('Telefone / WhatsApp', telefone, tipo: TextInputType.phone),
        campo('Observações', obs, obrigatorio: false),
        const SizedBox(height: 8),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: salvar,
          icon: const Icon(Icons.save_outlined),
          label: Text(editando ? 'Salvar alterações' : 'Cadastrar animal'),
          style: FilledButton.styleFrom(backgroundColor: verde, foregroundColor: Colors.white))),
      ])));
  }
}

class ServicesScreen extends StatelessWidget {
  final ValueChanged<PetService> onSchedule;
  const ServicesScreen({super.key, required this.onSchedule});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Nossos serviços', style: TextStyle(color: verde, fontSize: 25, fontWeight: FontWeight.w800)),
    const SizedBox(height: 5),
    Text('Cuidado especial em cada detalhe.', style: TextStyle(color: grafite.withOpacity(.6))),
    const SizedBox(height: 18),
    ...servicos.map((s) => Container(margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(17), border: Border.all(color: areia)),
      child: Row(children: [
        Container(width: 49, height: 49, decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(14)),
          child: Icon(s.icon, color: verde, size: 25)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.nome, style: const TextStyle(color: verde, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 3),
          Text(s.descricao, style: TextStyle(color: grafite.withOpacity(.6), fontSize: 12)),
          const SizedBox(height: 6),
          Text('R\$ ${s.preco.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(color: dourado, fontWeight: FontWeight.bold, fontSize: 16)),
        ])),
        IconButton(onPressed: () => onSchedule(s), icon: const Icon(Icons.add_circle, color: verde)),
      ]))),
    const SizedBox(height: 8),
    Text('Valores ilustrativos para a apresentação do projeto.',
      style: TextStyle(color: grafite.withOpacity(.5), fontSize: 11)),
  ]);
}

class AppointmentsScreen extends StatelessWidget {
  final List<Appointment> agenda;
  final VoidCallback onAdd;
  final ValueChanged<Appointment> onEdit, onCancel;
  const AppointmentsScreen({super.key, required this.agenda, required this.onAdd,
    required this.onEdit, required this.onCancel});
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 14), child: Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Agendamentos', style: TextStyle(color: verde, fontSize: 25, fontWeight: FontWeight.w800)),
        SizedBox(height: 4), Text('Gerencie os próximos atendimentos.'),
      ])),
      IconButton.filled(onPressed: onAdd, icon: const Icon(Icons.add),
        style: IconButton.styleFrom(backgroundColor: verde, foregroundColor: Colors.white)),
    ])),
    Expanded(child: agenda.isEmpty ? const _EmptyState(text: 'Nenhum agendamento cadastrado.')
      : ListView.builder(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: agenda.length, itemBuilder: (_, i) {
          final a = agenda[i];
          return Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: areia)),
            child: Padding(padding: const EdgeInsets.all(13), child: Column(children: [
              _AppointmentTile(item: a),
              const Divider(color: areia),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: a.status == 'Cancelado' ? null : () => onEdit(a),
                  child: const Text('Editar')),
                TextButton(onPressed: a.status == 'Cancelado' ? null : () => showDialog(
                  context: context, builder: (_) => AlertDialog(
                    title: const Text('Cancelar agendamento?'),
                    content: Text('Deseja cancelar o atendimento de ${a.pet.nome}?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Voltar')),
                      FilledButton(onPressed: () { Navigator.pop(context); onCancel(a); },
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Cancelar')),
                    ],
                  )),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red))),
              ]),
            ])));
        })),
  ]);
}

class AppointmentFormScreen extends StatefulWidget {
  final List<Pet> pets;
  final Pet? petInicial;
  final String? servicoInicial;
  final Appointment? existente;
  const AppointmentFormScreen({super.key, required this.pets, this.petInicial, this.servicoInicial, this.existente});
  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}
class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final formKey = GlobalKey<FormState>();
  late Pet pet;
  late String servico, data, horario;
  @override
  void initState() {
    super.initState();
    pet = widget.existente?.pet ?? widget.petInicial ?? widget.pets.first;
    servico = widget.existente?.servico ?? widget.servicoInicial ?? servicos.first.nome;
    data = widget.existente?.data ?? '07/11/2026';
    horario = widget.existente?.horario ?? '09:00';
  }
  Future<void> escolherData() async {
    final agora = DateTime.now();
    final inicial = widget.existente == null ? agora : _parseDate(data);
    final d = await showDatePicker(context: context,
      initialDate: inicial.isBefore(DateTime(2020)) ? agora : inicial,
      firstDate: DateTime(2020), lastDate: DateTime(2035),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: verde)), child: child!));
    if (d != null) setState(() => data = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
  }
  DateTime _parseDate(String s) {
    final p = s.split('/');
    if (p.length != 3) return DateTime.now();
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }
  Future<void> escolherHorario() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(
      hour: int.parse(horario.split(':')[0]), minute: int.parse(horario.split(':')[1])));
    if (t != null) setState(() => horario = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
  }
  @override
  Widget build(BuildContext context) {
    final existente = widget.existente != null;
    final selecionado = servicos.firstWhere((s) => s.nome == servico);
    return Scaffold(appBar: AppBar(title: Text(existente ? 'Editar agendamento' : 'Novo agendamento')),
      body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Dados do atendimento', style: TextStyle(color: verde, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<Pet>(value: pet, decoration: const InputDecoration(labelText: 'Animal'),
          items: widget.pets.map((p) => DropdownMenuItem(value: p, child: Text('${p.nome} • ${p.tutor}'))).toList(),
          onChanged: (v) { if (v != null) setState(() => pet = v); }),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(value: servico, decoration: const InputDecoration(labelText: 'Serviço'),
          items: servicos.map((s) => DropdownMenuItem(value: s.nome,
            child: Text('${s.nome} — R\$ ${s.preco.toStringAsFixed(2).replaceAll('.', ',')}'))).toList(),
          onChanged: (v) { if (v != null) setState(() => servico = v); }),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: escolherData, icon: const Icon(Icons.calendar_today),
          label: Text('Data: $data'), style: OutlinedButton.styleFrom(foregroundColor: verde, padding: const EdgeInsets.all(14))),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: escolherHorario, icon: const Icon(Icons.access_time),
          label: Text('Horário: $horario'), style: OutlinedButton.styleFrom(foregroundColor: verde, padding: const EdgeInsets.all(14))),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: areia, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Valor do serviço', style: TextStyle(color: verde, fontWeight: FontWeight.w600)),
            Text('R\$ ${selecionado.preco.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(color: verde, fontWeight: FontWeight.bold, fontSize: 18)),
          ])),
        const SizedBox(height: 22),
        SizedBox(height: 52, child: FilledButton.icon(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(context, Appointment(pet: pet, servico: servico, data: data,
              horario: horario, status: 'Confirmado', valor: selecionado.preco));
          },
          icon: const Icon(Icons.check), label: Text(existente ? 'Salvar alterações' : 'Confirmar agendamento'),
          style: FilledButton.styleFrom(backgroundColor: verde, foregroundColor: Colors.white))),
      ])));
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment item;
  final VoidCallback? onTap;
  const _AppointmentTile({required this.item, this.onTap});
  @override
  Widget build(BuildContext context) {
    final cancelado = item.status == 'Cancelado';
    return ListTile(contentPadding: EdgeInsets.zero, onTap: onTap,
      leading: CircleAvatar(backgroundColor: areia, child: Icon(Icons.event, color: verde)),
      title: Text(item.pet.nome, style: const TextStyle(color: verde, fontWeight: FontWeight.bold)),
      subtitle: Text('${item.servico} • ${item.data} às ${item.horario}\nTutor: ${item.pet.tutor}'),
      isThreeLine: true,
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('R\$ ${item.valor.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(color: verde, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(item.status, style: TextStyle(fontSize: 11,
            color: cancelado ? Colors.red : item.status == 'Pendente' ? Colors.orange.shade800 : Colors.green.shade700)),
        ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.pets_outlined, color: dourado, size: 48),
      const SizedBox(height: 12),
      Text(text, textAlign: TextAlign.center, style: const TextStyle(color: verde, fontWeight: FontWeight.w600)),
    ])));
}
