import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahya_new_app/Controlls/apiCoolor.dart';
import 'package:yahya_new_app/Controlls/apiInventory.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yahya_new_app/Controlls/apiProduct.dart';
import 'package:yahya_new_app/Controlls/apiSiize.dart';
import 'package:yahya_new_app/Controlls/apiStock.dart';
import 'package:yahya_new_app/cubit-state/color-Cub-State%20copy/coolor-cub.dart';
import 'package:yahya_new_app/cubit-state/inventory-Cub-State/inventory-cub.dart';
import 'package:yahya_new_app/cubit-state/inventory-Cub-State/inventory-state.dart';

import 'package:yahya_new_app/cubit-state/product-Cub-State/product-cub.dart';
import 'package:yahya_new_app/cubit-state/category-Cub-State/category-cub.dart';
import 'package:yahya_new_app/cubit-state/product-Cub-State/product-state.dart';
import 'package:yahya_new_app/cubit-state/size-Cub-State/siize-cub.dart';
import 'package:yahya_new_app/cubit-state/stock-Cub-State/stock-cub.dart';
import 'package:yahya_new_app/model/inventory.dart';

import 'package:yahya_new_app/pages/category.dart';
import 'package:yahya_new_app/pages/color.dart';
import 'package:yahya_new_app/pages/inventory.dart';
import 'package:yahya_new_app/pages/login-register.dart';
import 'package:yahya_new_app/pages/product.dart';
import 'package:yahya_new_app/Controlls/apiCategory.dart';
import 'package:yahya_new_app/pages/size.dart';
import 'package:yahya_new_app/pages/stock.dart';

class HomePage extends StatelessWidget {
  final String name;
  final String email;
  final String profileImagePath;

  const HomePage({
    super.key,
    required this.name,
    required this.email,
    required this.profileImagePath,
  });

  String get fullImageUrl {
    if (profileImagePath.isEmpty) return '';
    if (profileImagePath.startsWith('http')) return profileImagePath;

    const serverBaseUrl = 'http://192.168.18.3:7045/';

    if (profileImagePath.startsWith('uploads/')) {
      return serverBaseUrl + profileImagePath;
    }

    final normalizedPath = profileImagePath.startsWith('/')
        ? profileImagePath.substring(1)
        : profileImagePath;

    return serverBaseUrl + 'uploads/' + normalizedPath;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductCubit>(
      create: (_) => ProductCubit()..loadProducts(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF232F34),
          appBar: AppBar(
            title: const Text(
              '  TaJ Clothes ',
              style: TextStyle(color: Color.fromARGB(255, 232, 230, 224)),
            ),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 24, 40, 45),
            elevation: 4,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              BlocProvider(
                create: (_) => InventoryCubit()..loadInventories(),
                child: BlocBuilder<InventoryCubit, InventoryState>(
                  builder: (context, state) {
                    final cubit = context.read<InventoryCubit>();
                    final lowStockCount = cubit.lowStockItems.length;

                    return IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications, color: Colors.white),
                          if (lowStockCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: Text(
                                  lowStockCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        if (lowStockCount > 0) {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFF344955),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                            ),
                            builder: (_) =>
                                _buildLowStockList(cubit.lowStockItems),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('لا يوجد نقص في المخزون')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
            iconTheme: IconThemeData(
              color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
            ),
          ),
          drawer: Drawer(
            backgroundColor: Color.fromARGB(255, 38, 54, 63),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: fullImageUrl.isNotEmpty
                        ? NetworkImage(fullImageUrl)
                        : null,
                    child: fullImageUrl.isEmpty
                        ? Text(
                            name.isNotEmpty ? name[0] : '',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.indigo.shade700,
                            ),
                          )
                        : null,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 38, 54, 63),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.production_quantity_limits,
                      color: Color.fromARGB(255, 218, 230, 237)),
                  title: const Text('المنتجات',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => ProductCubit()..loadProducts(),
                          child: const ProductPage(),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory,
                      color: Color.fromARGB(255, 218, 230, 237)),
                  title: const Text('المخزون',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () async {
                    Navigator.pop(context);

                    // تحميل الأصناف
                    final categories =
                        await ApiCategory().getAllCategoriesFromApi();

                    // تحميل المنتجات
                    final products = await ApiProduct.fetchProducts();

                    // تحميل المقاسات
                    final siizes = await ApiSiize().getAllSizeFromApi();
                    final coolors = await ApiCoolor().getAllCoolorFromApi();

                    final inventoryCubit =
                        InventoryCubit(); // إنشاء الكيوبت مرة واحدة

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<InventoryCubit>(
                              create: (_) => inventoryCubit..loadInventories(),
                            ),
                            // إذا تحتاج Providers أخرى ضفها هنا
                          ],
                          child: InventoryPage(
                            inventoryCubit:
                                inventoryCubit, // تمرير الكيوبت صراحة
                            categories: categories,
                            products: products,
                            siizes: siizes,
                            coolors: coolors,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart,
                      color: Color.fromARGB(255, 218, 230, 237)),
                  title: const Text('الحركات',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () async {
                    final inventoryList = await ApiInventory.fetchInventories();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => StockCubit(apiStock: ApiStock()),
                          child: StockPage(
                            inventory: inventoryList,
                          ), // تأكد أن StockPage تستقبل inventory وليس products
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category,
                      color: Color.fromARGB(255, 218, 230, 237)),
                  title: const Text('التصنيفات',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => CategoryCubit(ApiCategory())
                            ..getCategoriesToFront(),
                          child: const CategoryListPage(),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sanitizer,
                      color: Color.fromARGB(255, 218, 230, 237)),
                  title: const Text('القياسات',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) =>
                              SiizeCubit(ApiSiize())..getSizeToFront(),
                          child: const SizeListPage(),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.sanitizer,
                    color: Color.fromARGB(255, 218, 230, 237),
                  ),
                  title: const Text('الالوان',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) =>
                              CoolorCubit(ApiCoolor())..getcoolorToFront(),
                          child: const ColorListPage(),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout,
                      color: Color.fromARGB(255, 218, 230, 237)),
                  title: const Text('تسجيل الخروج',
                      style:
                          TextStyle(color: Color.fromARGB(255, 218, 230, 237))),
                  onTap: () async {
                    Navigator.pop(context);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const LoginRegisterPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(1),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // سلايدر صور
                  BlocBuilder<ProductCubit, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoaded && state.products.isNotEmpty) {
                        final productsWithImages = state.products
                            .where((p) =>
                                p.fullImageUrl != null &&
                                p.fullImageUrl!.isNotEmpty &&
                                p.name != null)
                            .toList();

                        return CarouselSlider(
                          items: productsWithImages.map((product) {
                            final fullImageUrl = product.fullImageUrl!
                                    .startsWith('http')
                                ? product.fullImageUrl!
                                : 'http://192.168.18.3:7045/${product.fullImageUrl}';

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                fullImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                      child: Icon(Icons.image_not_supported)),
                                ),
                              ),
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: 450,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.75,
                          ),
                        );
                      } else if (state is ProductLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const Text("لا توجد صور منتجات متاحة.");
                      }
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // الكروت الرئيسية
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildCard(context, 'المنتجات', Icons.shopping_bag,
                          Color.fromARGB(255, 105, 27, 177), () {
                        Navigator.pushNamed(context, '/ProductPage');
                      }),
                      _buildCard(context, 'المخزون', Icons.store,
                          Color.fromARGB(255, 217, 131, 187), () {
                        Navigator.pushNamed(context, '/inventory');
                      }),
                      _buildCard(context, 'الحركات',
                          FontAwesomeIcons.exchangeAlt, Colors.blue, () {
                        Navigator.pushNamed(context, '/stock');
                      }),
                      _buildCard(
                          context, 'التصنيفات', Icons.category, Colors.indigo,
                          () {
                        Navigator.pushNamed(context, '/categories');
                      }),
                      _buildCard(
                          context, 'القياسات', Icons.straighten, Colors.green,
                          () {
                        Navigator.pushNamed(context, '/sizes');
                      }),
                      _buildCard(
                          context, 'الألوان', Icons.color_lens, Colors.pink,
                          () {
                        Navigator.pushNamed(context, '/colors');
                      }),
                      _buildCard(context, 'التقارير', Icons.bar_chart,
                          Colors.deepPurple, () {
                        Navigator.pushNamed(context, '/reports');
                      }),
                      _buildCard(
                          context, 'الإعدادات', Icons.settings, Colors.grey,
                          () {
                        Navigator.pushNamed(context, '/settings');
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 38) / 2,
        height: 110,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: color.withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildLowStockList(List<Inventory> items) {
  return SizedBox(
    height: 400,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المنتجات ذات الكمية القليلة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item.productName ?? 'اسم غير معروف',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'الكمية: ${item.quantity}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: item.fullImageUrl != null
                      ? Image.network(
                          item.fullImageUrl!,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : const Icon(Icons.image_not_supported,
                          color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
