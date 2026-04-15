import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MApp());
}

// ============================================
// MODELOS DE DADOS
// ============================================

enum TipoCartao { visa, mastercard, nubank }

class CartaoModel {
  final Color cor;
  final String banco;
  final String numero;
  final String titular;
  final String validade;
  final String cvv;
  final TipoCartao tipo;

  const CartaoModel({
    required this.cor,
    required this.banco,
    required this.numero,
    required this.titular,
    required this.validade,
    required this.cvv,
    required this.tipo,
  });
}

// ============================================
// CONSTANTES DE ESTILO
// ============================================

abstract class AppColors {
  static const background = Color(0xFFF8FAFC);
  static const cardSenai = Color(0xFF1E3A8A);
  static const cardSesi = Color(0xFF7C2D12);
  static const cardNubank = Color(0xFF1F2937);
}

// ============================================
// DADOS MOCK
// ============================================

final List<CartaoModel> cartoesExemplo = const [
  CartaoModel(
    cor: AppColors.cardSenai,
    banco: "Banco SENAI",
    numero: "1111 2222 3333 4444",
    titular: "Samuel Dias",
    validade: "10/30",
    cvv: "123",
    tipo: TipoCartao.visa,
  ),
  CartaoModel(
    cor: AppColors.cardSesi,
    banco: "Banco SESI",
    numero: "5555 6666 7777 8888",
    titular: "Maria Silva",
    validade: "12/30",
    cvv: "456",
    tipo: TipoCartao.mastercard,
  ),
  CartaoModel(
    cor: AppColors.cardNubank,
    banco: "Nubank",
    numero: "9999 0000 1111 2222",
    titular: "João Oliveira",
    validade: "08/30",
    cvv: "789",
    tipo: TipoCartao.nubank,
  ),
];

// ============================================
// APP PRINCIPAL
// ============================================

class MApp extends StatelessWidget {
  const MApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================
// TELA PRINCIPAL
// ============================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Carteira Digital",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: cartoesExemplo.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          return CartaoFlipWidget(cartao: cartoesExemplo[index]);
        },
      ),
    );
  }
}

// ============================================
// WIDGET DO CARTÃO COM FLIP
// ============================================

class CartaoFlipWidget extends StatefulWidget {
  final CartaoModel cartao;

  const CartaoFlipWidget({super.key, required this.cartao});

  @override
  State<CartaoFlipWidget> createState() => _CartaoFlipWidgetState();
}

class _CartaoFlipWidgetState extends State<CartaoFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _showCvv = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFrontVisible = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontVisible
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      height: 232,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.cartao.cor,
            Color.fromRGBO(
              widget.cartao.cor.red,
              widget.cartao.cor.green,
              widget.cartao.cor.blue,
              0.85,
            ),
            Color.fromRGBO(
              widget.cartao.cor.red,
              widget.cartao.cor.green,
              widget.cartao.cor.blue,
              0.7,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              widget.cartao.cor.red,
              widget.cartao.cor.green,
              widget.cartao.cor.blue,
              0.4,
            ),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cartao.banco,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "**** Débito",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildCardTypeIcon(),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contactless,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chip
          Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.orangeAccent],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sim_card, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 15),
          // Número do cartão
          Text(
            widget.cartao.numero,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Titular e Validade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Titular",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.cartao.titular.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Validade",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.cartao.validade,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      height: 232,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(
              widget.cartao.cor.red,
              widget.cartao.cor.green,
              widget.cartao.cor.blue,
              0.9,
            ),
            widget.cartao.cor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              widget.cartao.cor.red,
              widget.cartao.cor.green,
              widget.cartao.cor.blue,
              0.4,
            ),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 25),
          // Tarja magnética
          Container(
            height: 45,
            color: Colors.black87,
          ),
          const SizedBox(height: 20),
          // Área de assinatura e CVV
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.cartao.titular,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCvv = !_showCvv;
                      });
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showCvv ? widget.cartao.cvv : "***",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showCvv ? Icons.visibility : Icons.visibility_off,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "CVV",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Ícones de segurança
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Cartão protegido",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                _buildCardTypeIcon(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCardTypeIcon() {
    final config = switch (widget.cartao.tipo) {
      TipoCartao.visa => (
        colors: [Colors.blue, Colors.blueAccent],
        icon: Icons.credit_card,
      ),
      TipoCartao.mastercard => (
        colors: [Colors.orange, Colors.red],
        icon: Icons.payment,
      ),
      TipoCartao.nubank => (
        colors: [Colors.purple, Colors.pink],
        icon: Icons.account_balance_wallet,
      ),
    };

    return Container(
      width: 40,
      height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: config.colors),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(config.icon, color: Colors.white, size: 18),
    );
  }
}