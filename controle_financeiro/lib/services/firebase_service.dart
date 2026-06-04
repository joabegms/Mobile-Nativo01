import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import '../models/transacao.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inicializar Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Erro ao inicializar Firebase: $e');
    }
  }

  // Autenticação - Registrar
  static Future<bool> registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar dados do usuário no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': name,
        'email': email,
        'uid': userCredential.user!.uid,
        'dataCadastro': DateTime.now().toIso8601String(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print('Erro ao registrar: ${e.message}');
      return false;
    }
  }

  // Autenticação - Login
  static Future<bool> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Erro ao fazer login: ${e.message}');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Obter usuário atual
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Adicionar transação ao Firestore
  static Future<bool> addTransacao(Transacao transacao, String uid) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('transacoes')
          .add({
        'titulo': transacao.titulo,
        'valor': transacao.valor,
        'tipo': transacao.tipo,
        'categoria': transacao.categoria,
        'data': transacao.data.toIso8601String(),
        'descricao': transacao.descricao,
        'criadoEm': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      return false;
    }
  }

  // Obter transações do Firestore
  static Future<List<Transacao>> getTransacoes(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('transacoes')
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Transacao(
          id: doc.hashCode,
          usuarioId: uid.hashCode,
          titulo: doc['titulo'] ?? '',
          valor: (doc['valor'] ?? 0.0).toDouble(),
          tipo: doc['tipo'] ?? 'despesa',
          categoria: doc['categoria'],
          data: DateTime.parse(doc['data'] ?? DateTime.now().toIso8601String()),
          descricao: doc['descricao'],
        );
      }).toList();
    } catch (e) {
      print('Erro ao obter transações: $e');
      return [];
    }
  }

  // Atualizar transação
  static Future<bool> updateTransacao(
    String uid,
    String docId,
    Transacao transacao,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('transacoes')
          .doc(docId)
          .update({
        'titulo': transacao.titulo,
        'valor': transacao.valor,
        'tipo': transacao.tipo,
        'categoria': transacao.categoria,
        'data': transacao.data.toIso8601String(),
        'descricao': transacao.descricao,
        'atualizadoEm': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar transação: $e');
      return false;
    }
  }

  // Deletar transação
  static Future<bool> deleteTransacao(String uid, String docId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('transacoes')
          .doc(docId)
          .delete();
      return true;
    } catch (e) {
      print('Erro ao deletar transação: $e');
      return false;
    }
  }

  // Stream de transações em tempo real
  static Stream<List<Transacao>> getTransacoesStream(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('transacoes')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Transacao(
          id: doc.hashCode,
          usuarioId: uid.hashCode,
          titulo: doc['titulo'] ?? '',
          valor: (doc['valor'] ?? 0.0).toDouble(),
          tipo: doc['tipo'] ?? 'despesa',
          categoria: doc['categoria'],
          data: DateTime.parse(doc['data'] ?? DateTime.now().toIso8601String()),
          descricao: doc['descricao'],
        );
      }).toList();
    });
  }
}
