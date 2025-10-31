import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import '../widgets/fake_button.dart';
import '../services/session_service.dart';
import 'account_screen.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'history_screen.dart';
import 'favorite_screen.dart';
import '../utils/sensor_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cartSrv = CartService();
  final sensorSrv = SensorService();

  final List<Product> _products = [
    Product(id: '1', name: 'Pulsera artesanal', price: 19.99, description: 'Hecha a mano con materiales naturales por artesanos locales.', imageUrl: 'assets/pulsera.png'),
    Product(id: '2', name: 'Sombrero Wayuu', price: 39.50, description: 'Tradicional sombrero tejido por la comunidad Wayuu.', imageUrl: 'assets/sombrero-wayuu.jpg'),
    Product(id: '3', name: 'Mochila tejida', price: 59.00, description: 'Mochila artesanal tejida a mano con diseños únicos.', imageUrl: 'assets/mochila.jpg'),
    Product(id: '4', name: 'Aretes de filigrana', price: 24.90, description: 'Aretes hechos con filigrana de plata por artesanos de Mompox.', imageUrl: 'assets/aretes.png'),
    Product(id: '5', name: 'Camisa bordada', price: 45.00, description: 'Camisa de lino con bordados tradicionales colombianos.', imageUrl: 'assets/camisa.png'),
    Product(id: '6', name: 'Ruana de lana', price: 89.00, description: 'Ruana tejida en lana virgen, ideal para clima frío.', imageUrl: 'assets/ruana.png'),
    Product(id: '7', name: 'Cartera de fique', price: 34.50, description: 'Cartera ecológica hecha con fibras de fique natural.', imageUrl: 'assets/cartera.png'),
    Product(id: '8', name: 'Collar de semillas', price: 22.00, description: 'Collar artesanal elaborado con semillas amazónicas.', imageUrl: 'assets/collar.png'),
    Product(id: '9', name: 'Tapabocas Wayuu', price: 12.99, description: 'Tapabocas con diseño Wayuu, reutilizable y colorido.', imageUrl: 'assets/tapabocas.png'),
    Product(id: '10', name: 'Poncho tradicional', price: 74.00, description: 'Poncho típico colombiano tejido a mano.', imageUrl: 'assets/poncho.png'),
  ];

  late List<Product> _productosVisibles;

  @override
  void initState() {
    super.initState();
    _productosVisibles = _products;
  }

  void _restaurarProductos() {
    setState(() {
      _productosVisibles = _products;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mostrando todos los productos')),
    );
  }

  void _buscarPorVoz() async {
    final resultado = await Navigator.pushNamed(context, '/voz');
    if (resultado != null && resultado is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Buscando: $resultado')),
      );
      setState(() {
        _productosVisibles = _products.where((p) {
          final nombre = p.name.toLowerCase();
          final textoReconocido = resultado.toLowerCase();
          return nombre.contains(textoReconocido);
        }).toList();
      });
    } else {
      _restaurarProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _restaurarProductos,
          child: const Text('Guru Store'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'Ver Favoritos',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: cartSrv.itemCount,
            builder: (context, count, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.deepPurple),
            tooltip: 'Buscar por voz',
            onPressed: _buscarPorVoz,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF8B4513)),
            tooltip: 'Cuenta o Login',
            onPressed: () async {
              final user = await SessionService.getUser();
              if (user != null) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AccountScreen(
                    nombre: user['nombre'] ?? '',
                    correo: user['correo'] ?? '',
                    direccion: user['direccion'] ?? '',
                    rol: user['rol'] ?? 'usuario',
                    telefono: user['telefono'] ?? '',
                    id: user['id'] ?? '',
                  ),
                ));
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              FakeButton(
                text: 'Ver Historial',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._productosVisibles.map(
                (p) => ProductItem(product: p, onAddToCart: () => cartSrv.add(p)),
          ),
        ],
      ),
    );
  }
}