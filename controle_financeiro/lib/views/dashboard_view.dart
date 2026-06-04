import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transacao_viewmodel.dart';
import '../utils/formatters.dart';
import 'login_view.dart';
import 'transacao_form_view.dart';
import 'transacoes_list_view.dart';
import 'graficos_view.dart';
import 'noticias_view.dart';
import 'relatorio_view.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.usuarioLogado != null) {
        Provider.of<TransacaoViewModel>(context, listen: false)
            .carregarTransacoes(usuarioId: authVM.usuarioLogado!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthViewModel>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginView()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TransacaoFormView()),
                );
              },
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Gráficos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Notícias',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return GraficosView();
      case 2:
        return RelatorioView();
      case 3:
        return NoticiasView();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Consumer2<AuthViewModel, TransacaoViewModel>(
      builder: (context, authVM, transacaoVM, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Boas-vindas
                Text(
                  'Bem-vindo, ${authVM.usuarioLogado?.nome.split(' ').first}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Card de Saldo
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo Total',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(transacaoVM.saldoTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cards de Receitas e Despesas
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[300]!, width: 2),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_downward,
                                color: Colors.green[700], size: 28),
                            const SizedBox(height: 8),
                            const Text(
                              'Receitas',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(
                                  transacaoVM.totalReceitas),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[300]!, width: 2),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.red[700],
                                size: 28),
                            const SizedBox(height: 8),
                            const Text(
                              'Despesas',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(
                                  transacaoVM.totalDespesas),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Últimas Transações
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimas Transações',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TransacoesListView()),
                        );
                      },
                      child: const Text('Ver Todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lista de Transações
                if (transacaoVM.transacoes.isEmpty)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma transação cadastrada',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transacaoVM.transacoes.length > 5
                        ? 5
                        : transacaoVM.transacoes.length,
                    itemBuilder: (context, index) {
                      final transacao = transacaoVM.transacoes[index];
                      return _buildTransacaoTile(
                          context, transacao, transacaoVM);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransacaoTile(
    BuildContext context,
    dynamic transacao,
    TransacaoViewModel transacaoVM,
  ) {
    final isReceita = transacao.tipo == 'receita';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Deletar Transação'),
              content: const Text(
                  'Tem certeza que deseja deletar esta transação?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    transacaoVM.removerTransacao(
                      transacao.id,
                      usuarioId: Provider.of<AuthViewModel>(context,
                              listen: false)
                          .usuarioLogado
                          ?.id,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transação deletada!'),
                        backgroundColor: Colors.green,
                      ),
                    );
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
  }
}
