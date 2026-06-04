import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/transacao_viewmodel.dart';
import '../utils/chart_data.dart';
import '../utils/formatters.dart';

class GraficosView extends StatefulWidget {
  @override
  _GraficosViewState createState() => _GraficosViewState();
}

class _GraficosViewState extends State<GraficosView> {
  int _tipoGrafico = 0; // 0: Pizza, 1: Barras, 2: Linha

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Consumer<TransacaoViewModel>(
        builder: (context, transacaoVM, _) {
          if (transacaoVM.transacoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação para exibir gráficos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Seletor de tipo de gráfico
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Pizza'),
                          selected: _tipoGrafico == 0,
                          onSelected: (selected) {
                            setState(() => _tipoGrafico = 0);
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Barras'),
                          selected: _tipoGrafico == 1,
                          onSelected: (selected) {
                            setState(() => _tipoGrafico = 1);
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Linha'),
                          selected: _tipoGrafico == 2,
                          onSelected: (selected) {
                            setState(() => _tipoGrafico = 2);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                // Gráfico
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _construirGrafico(transacaoVM, _tipoGrafico),
                ),
                // Legenda e informações
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _construirLegenda(transacaoVM),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construirGrafico(TransacaoViewModel transacaoVM, int tipo) {
    switch (tipo) {
      case 0:
        // Gráfico de Pizza
        return SizedBox(
          height: 300,
          child: PieChart(
            ChartData.gerarGraficoPizza(transacaoVM.transacoes),
            swapAnimationDuration: const Duration(milliseconds: 750),
          ),
        );
      case 1:
        // Gráfico de Barras
        return SizedBox(
          height: 300,
          child: BarChart(
            ChartData.gerarGraficoBarras(transacaoVM.transacoes),
          ),
        );
      case 2:
        // Gráfico de Linha
        return SizedBox(
          height: 300,
          child: LineChart(
            ChartData.gerarGraficoLinha(transacaoVM.transacoes),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _construirLegenda(TransacaoViewModel transacaoVM) {
    final gastosPorCategoria = <String, double>{};

    for (var t in transacaoVM.transacoes) {
      if (t.tipo == 'despesa' && t.categoria != null) {
        gastosPorCategoria[t.categoria!] =
            (gastosPorCategoria[t.categoria!] ?? 0) + t.valor;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[300]!),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total de Receitas'),
              Text(
                Formatters.formatCurrency(transacaoVM.totalReceitas),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[300]!),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total de Despesas'),
              Text(
                Formatters.formatCurrency(transacaoVM.totalDespesas),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Despesas por Categoria',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...gastosPorCategoria.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key),
                Text(
                  Formatters.formatCurrency(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
