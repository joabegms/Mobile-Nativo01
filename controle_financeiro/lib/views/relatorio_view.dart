import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transacao_viewmodel.dart';
import '../utils/formatters.dart';

class RelatorioView extends StatefulWidget {
  @override
  _RelatorioViewState createState() => _RelatorioViewState();
}

class _RelatorioViewState extends State<RelatorioView> {
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Consumer<TransacaoViewModel>(
        builder: (context, transacaoVM, _) {
          // Filtrar transações por data se selecionadas
          List<dynamic> transacoesFiltradas = transacaoVM.transacoes;
          if (_dataInicio != null && _dataFim != null) {
            transacoesFiltradas = transacaoVM.transacoes
                .where((t) =>
                    t.data.isAfter(_dataInicio!) &&
                    t.data.isBefore(_dataFim!.add(const Duration(days: 1))))
                .toList();
          }

          // Calcular dados para o período
          double totalReceitas = 0;
          double totalDespesas = 0;
          Map<String, double> gastosPorCategoria = {};

          for (var t in transacoesFiltradas) {
            if (t.tipo == 'receita') {
              totalReceitas += t.valor;
            } else {
              totalDespesas += t.valor;
              if (t.categoria != null) {
                gastosPorCategoria[t.categoria!] =
                    (gastosPorCategoria[t.categoria!] ?? 0) + t.valor;
              }
            }
          }

          double saldo = totalReceitas - totalDespesas;
          double percentualGasto =
              totalReceitas > 0 ? (totalDespesas / totalReceitas) * 100 : 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Filtro de datas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Período',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dataInicio ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _dataInicio = date);
                                }
                              },
                              child: Text(
                                _dataInicio == null
                                    ? 'Data Início'
                                    : Formatters.formatDate(_dataInicio!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dataFim ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _dataFim = date);
                                }
                              },
                              child: Text(
                                _dataFim == null
                                    ? 'Data Fim'
                                    : Formatters.formatDate(_dataFim!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_dataInicio != null || _dataFim != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _dataInicio = null;
                                _dataFim = null;
                              });
                            },
                            child: const Text('Limpar Filtro'),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                // Cards de resumo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo do Período',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Receitas
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[300]!, width: 2),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total de Receitas',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Formatters.formatCurrency(totalReceitas),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.trending_up, color: Colors.green[700], size: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Despesas
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[300]!, width: 2),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total de Despesas',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Formatters.formatCurrency(totalDespesas),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.trending_down, color: Colors.red[700], size: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Saldo
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[300]!, width: 2),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Formatters.formatCurrency(saldo),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: saldo >= 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              saldo >= 0 ? Icons.check_circle : Icons.warning,
                              color: saldo >= 0 ? Colors.green[700] : Colors.red[700],
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Percentual de gastos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Taxa de Gasto',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${percentualGasto.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: percentualGasto > 80
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentualGasto / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentualGasto > 80 ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Gastos por categoria
                      if (gastosPorCategoria.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Despesas por Categoria',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ...gastosPorCategoria.entries.map((entry) {
                              final percentual =
                                  totalDespesas > 0
                                      ? (entry.value / totalDespesas) * 100
                                      : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(entry.key),
                                        Text(
                                          '${percentual.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentual / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.blue[700]!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
