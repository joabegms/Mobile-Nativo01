import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'controle_financeiro.db';
  static const _databaseVersion = 1;

  // Tabelas
  static const String tableUsuarios = 'usuarios';
  static const String tableTransacoes = 'transacoes';

  // Colunas Usuarios
  static const String usuariosId = 'id';
  static const String usuariosNome = 'nome';
  static const String usuariosEmail = 'email';
  static const String usuariosSenha = 'senha';
  static const String usuariosDataCadastro = 'data_cadastro';

  // Colunas Transacoes
  static const String transacoesId = 'id';
  static const String transacoesUsuarioId = 'usuario_id';
  static const String transacoesTitulo = 'titulo';
  static const String transacoesValor = 'valor';
  static const String transacoesTipo = 'tipo';
  static const String transacoesCategoria = 'categoria';
  static const String transacoesData = 'data';
  static const String transacoesDescricao = 'descricao';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criar tabela de usuários
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsuarios (
        $usuariosId INTEGER PRIMARY KEY AUTOINCREMENT,
        $usuariosNome TEXT NOT NULL,
        $usuariosEmail TEXT UNIQUE NOT NULL,
        $usuariosSenha TEXT NOT NULL,
        $usuariosDataCadastro TEXT NOT NULL
      )
    ''');

    // Criar tabela de transações
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTransacoes (
        $transacoesId INTEGER PRIMARY KEY AUTOINCREMENT,
        $transacoesUsuarioId INTEGER NOT NULL,
        $transacoesTitulo TEXT NOT NULL,
        $transacoesValor REAL NOT NULL,
        $transacoesTipo TEXT NOT NULL,
        $transacoesCategoria TEXT,
        $transacoesData TEXT NOT NULL,
        $transacoesDescricao TEXT,
        FOREIGN KEY($transacoesUsuarioId) REFERENCES $tableUsuarios($usuariosId)
      )
    ''');
  }

  // CRUD para usuários
  Future<int> insertUsuario(Map<String, dynamic> map) async {
    Database db = await instance.database;
    return await db.insert(tableUsuarios, map);
  }

  Future<List<Map<String, dynamic>>> queryAllUsuarios() async {
    Database db = await instance.database;
    return await db.query(tableUsuarios);
  }

  // CRUD para transações
  Future<int> insertTransacao(Map<String, dynamic> map) async {
    Database db = await instance.database;
    return await db.insert(tableTransacoes, map);
  }

  Future<List<Map<String, dynamic>>> queryAllTransacoes() async {
    Database db = await instance.database;
    return await db.query(tableTransacoes, orderBy: '$transacoesData DESC');
  }

  Future<List<Map<String, dynamic>>> queryTransacoesByUsuario(int usuarioId) async {
    Database db = await instance.database;
    return await db.query(
      tableTransacoes,
      where: '$transacoesUsuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: '$transacoesData DESC',
    );
  }

  Future<int> updateTransacao(int id, Map<String, dynamic> map) async {
    Database db = await instance.database;
    return await db.update(
      tableTransacoes,
      map,
      where: '$transacoesId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransacao(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableTransacoes,
      where: '$transacoesId = ?',
      whereArgs: [id],
    );
  }
}
