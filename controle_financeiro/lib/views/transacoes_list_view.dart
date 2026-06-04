import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transacao_viewmodel.dart';
import '../utils/formatters.dart';
import 'transacao_form_view.dart';

class TransacoesListView extends StatefulWidget {
  @override
  _TransacoesListViewState createState() => _TransacoesListViewState();
}

class _TransacoesListViewState extends State<TransacoesListView> {
  String _filtroTipo = 'todas';
  String? _filtroCategoria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Transações'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Consumer2<AuthViewModel, TransacaoViewModel>(
        builder: (context, authVM, transacaoVM, _) {
          List transacoesFiltradas = transacaoVM.transacoes;

          if (_filtroTipo == 'receita') {
            transacoesFiltradas = transacaoVM.filtrarPorTipo('receita');
          } else if (_filtroTipo == 'despesa') {
            transacoesFiltradas = transacaoVM.filtrarPorTipo('despesa');
          }

          if (_filtroCategoria != null && _filtroCategoria!.isNotEmpty) {
            transacoesFiltradas =
                transacoesFiltradas.where((t) => t.categoria == _filtroCategoria).toList();
          }

          return Column(
            children: [
              // Filtros
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Todas'),
                            selected: _filtroTipo == 'todas',
                            onSelected: (selected) {
                              setState(() => _filtroTipo = 'todas');
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Receitas'),
                            selected: _filtroTipo == 'receita',
                            onSelected: (selected) {
                              setState(() => _filtroTipo = 'receita');
                            },
                            backgroundColor: Colors.green[100],
                            selectedColor: Colors.green[300],
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Despesas'),
                            selected: _filtroTipo == 'despesa',
                            onSelected: (selected) {
                              setState(() => _filtroTipo = 'despesa');
                            },
                            backgroundColor: Colors.red[100],
                            selectedColor: Colors.red[300],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String?>(
                      value: _filtroCategoria,
                      hint: const Text('Filtrar por categoria'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas as categorias'),
                        ),
                        ...transacaoVM.categoriasUnicas
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _filtroCategoria = value);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Lista
              Expanded(
                child: transacoesFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma transação encontrada',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: transacoesFiltradas.length,
                        itemBuilder: (context, index) {
                          final transacao = transacoesFiltradas[index];
                          final isReceita = transacao.tipo == 'receita';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Icon(
                                isReceita ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isReceita ? Colors.green : Colors.red,
                              ),
                              title: Text(transacao.titulo),
                              subtitle: Text(
                                '${transacao.categoria ?? 'Sem categoria'} • ${Formatters.formatDate(transacao.data)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.formatCurrency(transacao.valor),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isReceita ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TransacaoFormView(transacao: transacao),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Deletar Transação'),
                                    content: const Text('Tem certeza?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          transacaoVM.removerTransacao(
                                            transacao.id,
                                            usuarioId: authVM.usuarioLogado?.id,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Deletar',
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TransacaoFormView()),
          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
