import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import '../widgets/fake_button.dart';
import '../services/session_service.dart';
import '../services/auth_service.dart'; // 👈 Importamos AuthService
import 'account_screen.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'history_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await _authService.getUsername();
    setState(() {
      _username = name;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    setState(() {
      _username = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada correctamente')),
    );
  }

  List<Product> get _products => [
    Product(
      id: '1',
      name: 'Pulsera artesanal',
      price: 19.99,
      description:
      'Hecha a mano con materiales naturales por artesanos locales.',
      imageUrl: 'assets/pulsera.png',
    ),
    Product(
      id: '2',
      name: 'Sombrero Wayuu',
      price: 39.50,
      description: 'Tradicional sombrero tejido por la comunidad Wayuu.',
      imageUrl: 'assets/sombrero-wayuu.jpg',
    ),
    Product(
      id: '3',
      name: 'Mochila tejida',
      price: 59.00,
      description: 'Mochila artesanal tejida a mano con diseños únicos.',
      imageUrl: 'assets/mochila.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cartSrv = CartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guru Store'),
        actions: [
          // ❤️ Botón de favoritos
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'Ver Favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteScreen()),
              );
            },
          ),

          // 🛒 Botón de carrito
          ValueListenableBuilder<int>(
            valueListenable: cartSrv.itemCount,
            builder: (context, count, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // 👤 Botón de cuenta con nombre y menú
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Color(0xFF8B4513)),
            tooltip: 'Cuenta',
            onSelected: (value) async {
              if (value == 'account') {
                final user = await SessionService.getUser();
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountScreen(
                        nombre: user['nombre'] ?? '',
                        correo: user['correo'] ?? '',
                        direccion: user['direccion'] ?? '',
                        rol: user['rol'] ?? 'usuario',
                        telefono: user['telefono'] ?? '',
                        id: user['id'] ?? '',
                      ),
                    ),
                  );
                }
              } else if (value == 'logout') {
                _logout();
              } else if (value == 'login') {
                Navigator.pushNamed(context, '/login');
              }
            },
            itemBuilder: (context) {
              if (_username != null) {
                return [
                  PopupMenuItem<String>(
                    value: 'account',
                    child: Text('Ver perfil ($_username)'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Cerrar sesión'),
                  ),
                ];
              } else {
                return [
                  const PopupMenuItem<String>(
                    value: 'login',
                    child: Text('Iniciar sesión'),
                  ),
                ];
              }
            },
          ),

          // 👈 Nombre del usuario al lado del ícono
          if (_username != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Center(
                child: Text(
                  _username!,
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FakeButton(
                text: 'Ir al Carrito',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              FakeButton(
                text: 'Ver Historial',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._products.map(
                (p) => ProductItem(product: p, onAddToCart: () => cartSrv.add(p)),
          ),
        ],
      ),
    );
  }
}
