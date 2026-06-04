import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transacao.dart';

class ChartData {
  // Preparar dados para gráfico de pizza (Receitas vs Despesas)
  static PieChartData gerarGraficoPizza(List<Transacao> transacoes) {
    double totalReceitas = 0;
    double totalDespesas = 0;

    for (var t in transacoes) {
      if (t.tipo == 'receita') {
        totalReceitas += t.valor;
      } else {
        totalDespesas += t.valor;
      }
    }

    return PieChartData(
      sections: [
        PieChartSectionData(
          color: Colors.green,
          value: totalReceitas,
          title: totalReceitas > 0 ? 'R\$ ${totalReceitas.toStringAsFixed(0)}' : '',
          radius: 100,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        PieChartSectionData(
          color: Colors.red,
          value: totalDespesas,
          title: totalDespesas > 0 ? 'R\$ ${totalDespesas.toStringAsFixed(0)}' : '',
          radius: 100,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Preparar dados para gráfico de barras (Gastos por categoria)
  static BarChartData gerarGraficoBarras(List<Transacao> transacoes) {
    Map<String, double> gastosPorCategoria = {};

    for (var t in transacoes) {
      if (t.tipo == 'despesa' && t.categoria != null) {
        gastosPorCategoria[t.categoria!] = (gastosPorCategoria[t.categoria!] ?? 0) + t.valor;
      }
    }

    List<String> categorias = gastosPorCategoria.keys.toList();
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < categorias.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: gastosPorCategoria[categorias[i]]!,
              color: Colors.blue[700],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      barGroups: barGroups,
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if (index >= 0 && index < categorias.length) {
                return Text(
                  categorias[index],
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
    );
  }

  // Preparar dados para gráfico de linha (Saldo ao longo do tempo)
  static LineChartData gerarGraficoLinha(List<Transacao> transacoes) {
    List<FlSpot> spots = [];
    double saldoAcumulado = 0;

    // Ordenar transações por data
    final transacoesOrdenadas = [...transacoes];
    transacoesOrdenadas.sort((a, b) => a.data.compareTo(b.data));

    for (int i = 0; i < transacoesOrdenadas.length; i++) {
      final t = transacoesOrdenadas[i];
      if (t.tipo == 'receita') {
        saldoAcumulado += t.valor;
      } else {
        saldoAcumulado -= t.valor;
      }
      spots.add(FlSpot(i.toDouble(), saldoAcumulado));
    }

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: transacoesOrdenadas.length <= 10,
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
          isCurved: true,
          color: Colors.blue[700],
          barWidth: 3,
          dotData: FlDotData(show: spots.length <= 10),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
