import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transacao_viewmodel.dart';
import '../models/transacao.dart';
import '../utils/validators.dart';

class TransacaoFormView extends StatefulWidget {
  final Transacao? transacao;

  const TransacaoFormView({this.transacao});

  @override
  _TransacaoFormViewState createState() => _TransacaoFormViewState();
}

class _TransacaoFormViewState extends State<TransacaoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _valorController;
  late TextEditingController _descricaoController;
  late TextEditingController _dataController;
  String _tipo = 'despesa';
  String? _categoria;
  DateTime _dataSelecionada = DateTime.now();

  final List<String> _categoriasDespesa = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Educação',
    'Lazer',
    'Moradia',
    'Utilitários',
    'Outros',
  ];

  final List<String> _categoriasReceita = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Prêmios',
    'Vendas',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.transacao?.titulo ?? '');
    _valorController = TextEditingController(text: widget.transacao?.valor.toString() ?? '');
    _descricaoController = TextEditingController(text: widget.transacao?.descricao ?? '');
    _tipo = widget.transacao?.tipo ?? 'despesa';
    _categoria = widget.transacao?.categoria;
    _dataSelecionada = widget.transacao?.data ?? DateTime.now();
    _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);
  }

  late final TextEditingController _dataController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(_dataSelecionada),
  );

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);
      });
    }
  }

  void _salvarTransacao() async {
    if (_formKey.currentState!.validate()) {
      if (_categoria == null || _categoria!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma categoria'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final transacaoVM = Provider.of<TransacaoViewModel>(context, listen: false);

      final novaTransacao = Transacao(
        id: widget.transacao?.id,
        usuarioId: authVM.usuarioLogado!.id!,
        titulo: _tituloController.text,
        valor: double.parse(_valorController.text),
        tipo: _tipo,
        categoria: _categoria,
        data: _dataSelecionada,
        descricao: _descricaoController.text,
      );

      bool sucesso;
      if (widget.transacao == null) {
        sucesso = await transacaoVM.adicionarTransacao(novaTransacao);
      } else {
        sucesso = await transacaoVM.atualizarTransacao(novaTransacao);
      }

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transacao == null ? 'Transação adicionada!' : 'Transação atualizada!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar transação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = _tipo == 'receita' ? _categoriasReceita : _categoriasDespesa;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transacao == null ? 'Nova Transação' : 'Editar Transação'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seletor de Tipo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Receita'),
                            selected: _tipo == 'receita',
                            onSelected: (selected) {
                              setState(() {
                                _tipo = 'receita';
                                _categoria = null;
                              });
                            },
                            selectedColor: Colors.green[300],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Despesa'),
                            selected: _tipo == 'despesa',
                            onSelected: (selected) {
                              setState(() {
                                _tipo = 'despesa';
                                _categoria = null;
                              });
                            },
                            selectedColor: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Título'),
                ),
                const SizedBox(height: 16),

                // Valor
                TextFormField(
                  controller: _valorController,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => Validators.validateNumericValue(value),
                ),
                const SizedBox(height: 16),

                // Categoria
                DropdownButtonFormField<String>(
                  value: _categoria,
                  items: categorias
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _categoria = value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) => value == null ? 'Selecione uma categoria' : null,
                ),
                const SizedBox(height: 16),

                // Data
                TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(
                    labelText: 'Data',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  readOnly: true,
                  onTap: _selecionarData,
                  validator: (value) => Validators.validateRequired(value, 'Data'),
                ),
                const SizedBox(height: 16),

                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    labelText: 'Descrição (opcional)',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                // Botão Salvar
                ElevatedButton(
                  onPressed: _salvarTransacao,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue[700],
                  ),
                  child: Text(
                    widget.transacao == null ? 'Adicionar' : 'Atualizar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
