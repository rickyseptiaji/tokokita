import 'package:flutter/material.dart';
import 'package:tokokita/presentation/pages/penjualan/penjualan.dart';
import 'package:tokokita/presentation/pages/produk/produk.dart';
import 'package:tokokita/presentation/pages/supplier/supplier.dart';
import 'package:tokokita/shared/buttomnavbar.dart';

class NavbarDrawer extends StatefulWidget {
  const NavbarDrawer({super.key});

  @override
  State<NavbarDrawer> createState() => _NavbarState();
}

class _NavbarState extends State<NavbarDrawer> {
  String selectedPage = 'Dashboard';

  Widget _buildDrawerItem({required String title, required IconData icon}) {
    final bool isSelected = selectedPage == title;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      onTap: () {
        setState(() {
          selectedPage = title;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    switch (selectedPage) {
      case 'Dashboard':
        return const Text('Dashboard Page');
      case 'Produk':
        return const ProdukPage();
      case 'Supplier':
        return const SupplierPage();
      case 'Penjualan':
        return const PenjualanPage();
      case 'Riwayat':
        return const BottomNavbar();
      default:
        return const Text('Unknown Page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Toko Kita',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            _buildDrawerItem(title: 'Dashboard', icon: Icons.dashboard),

            _buildDrawerItem(title: 'Produk', icon: Icons.shopping_cart),

            _buildDrawerItem(title: 'Supplier', icon: Icons.local_shipping),

            _buildDrawerItem(title: 'Penjualan', icon: Icons.shopping_basket),

            _buildDrawerItem(title: 'Riwayat', icon: Icons.history),
          ],
        ),
      ),

      body: Center(child: _buildBody()),
    );
  }
}
