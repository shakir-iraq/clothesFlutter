import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/components/inventory-popup.dart';
import 'package:yahya_new_app/cubit-state/inventory-Cub-State/inventory-cub.dart';
import 'package:yahya_new_app/cubit-state/inventory-Cub-State/inventory-state.dart';
import 'package:yahya_new_app/model/Coolor.dart';
import 'package:yahya_new_app/model/product.dart';
import 'package:yahya_new_app/model/size.dart';
import 'package:yahya_new_app/model/category.dart';

class InventoryPage extends StatefulWidget {
  final List<Categorys> categories;
  final List<Product> products;
  final List<Siize> siizes;
  final List<Coolor> coolors;

  const InventoryPage({
    super.key,
    required this.categories,
    required this.products,
    required this.siizes,
    required this.coolors,
    required InventoryCubit inventoryCubit,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  int? selectedCategoryId;
  int? selectedProductId;
  int? selectedSizeId;
  int? selectedInventoryId;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<Product> get filteredProducts {
    if (selectedCategoryId == null) {
      return widget.products;
    } else {
      return widget.products
          .where((p) => p.categoryId == selectedCategoryId)
          .toList();
    }
  }

  Widget _buildTabFilter<T>({
    required String title,
    required List<T> items,
    required int? selectedValue,
    required String Function(T) getLabel,
    required int? Function(T) getValue,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 1,
              color: Color.fromARGB(255, 216, 185, 84),
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF232F34),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 131, 101, 4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedValue == null;
                return _buildChip(
                  label: 'الكل',
                  selected: isSelected,
                  onTap: () => onChanged(null),
                );
              } else {
                final item = items[index - 1];
                final value = getValue(item);
                final label = getLabel(item);
                final isSelected = selectedValue == value;

                return _buildChip(
                  label: label,
                  selected: isSelected,
                  onTap: () => onChanged(value),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 180, 128, 33),
                    Color.fromARGB(255, 221, 187, 86)
                  ],
                )
              : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 217, 204, 169),
                    Color.fromARGB(255, 209, 183, 120)
                  ],
                ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Color.fromARGB(255, 181, 157, 63).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232F34),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
        ),
        title: Center(
          child: Text(
            'ادارة المخزون',
            style: TextStyle(
              color: Color.fromARGB(255, 248, 247, 246),
              // لا يوجد خاصية textBaseline: Center(child: ...)
              // textBaseline تستخدم لموازنة النصوط وليست للتمركز
            ),
          ),
        ),
        backgroundColor: const Color(0xFF232F34),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                final cubit = context.read<InventoryCubit>();
                showDialog(
                  context: context,
                  builder: (_) => AddInventoryPopup(
                    existingInventory: null,
                    products: widget.products,
                    coolors: widget.coolors,
                    siizes: widget.siizes,
                    inventoryCubit: cubit,
                  ),
                );
              },
              splashColor: const Color.fromARGB(255, 166, 42, 86),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [const Color(0xFF344955), const Color(0xFF344955)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: TabBar(
              controller: _tabController,
              labelColor: Color.fromARGB(255, 179, 129, 13),
              unselectedLabelColor: Color.fromARGB(255, 191, 151, 30),
              indicatorColor: Color.fromARGB(255, 172, 144, 19),
              indicatorWeight: 5,
              tabs: const [
                Tab(text: "الأصناف"),
                Tab(text: "المنتجات"),
                Tab(text: "المقاسات"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: _buildTabFilter<Categorys>(
                    title: "", // إلغاء "فلترة بالصنف"
                    items: widget.categories,
                    selectedValue: selectedCategoryId,
                    getLabel: (c) => c.name,
                    getValue: (c) => c.id,
                    onChanged: (val) {
                      setState(() {
                        selectedCategoryId = val;
                        selectedProductId = null;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: _buildTabFilter<Product>(
                    title: "", // إلغاء "فلترة بالمنتج"
                    items: filteredProducts,
                    selectedValue: selectedProductId,
                    getLabel: (p) => p.name,
                    getValue: (p) => p.id,
                    onChanged: (val) {
                      setState(() {
                        selectedProductId = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: _buildTabFilter<Siize>(
                    title: "", // إلغاء "فلترة بالمقاس"
                    items: widget.siizes,
                    selectedValue: selectedSizeId,
                    getLabel: (s) => s.name,
                    getValue: (s) => s.id,
                    onChanged: (val) {
                      setState(() {
                        selectedSizeId = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InventoryLoaded) {
                  final filtered = state.inventories.where((inv) {
                    final matchesCategory = selectedCategoryId == null ||
                        widget.products.any((p) =>
                            p.id == inv.productId &&
                            p.categoryId == selectedCategoryId);
                    final matchesProduct = selectedProductId == null ||
                        inv.productId == selectedProductId;
                    final matchesSize =
                        selectedSizeId == null || inv.siizeId == selectedSizeId;
                    return matchesCategory && matchesProduct && matchesSize;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("لا توجد عناصر."));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(1),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final inv = filtered[index];
                      final isSelected = selectedInventoryId == inv.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedInventoryId =
                                isSelected ? null : inv.id; // toggle
                          });
                        },
                        child: Stack(
                          children: [
                            Card(
                              color: Color.fromARGB(255, 246, 214, 88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (inv.imageUrl != null &&
                                        inv.imageUrl!.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          inv.fullImageUrl,
                                          height: 240,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            " ${inv.productName}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              "  ${inv.quantity} - ${inv.sizeName} - ${inv.colorName}",
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 4, 45, 65),
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.white, size: 28),
                                          onPressed: () {
                                            final cubit =
                                                context.read<InventoryCubit>();
                                            showDialog(
                                              context: context,
                                              builder: (_) => AddInventoryPopup(
                                                existingInventory: inv,
                                                products: widget.products,
                                                coolors: widget.coolors,
                                                siizes: widget.siizes,
                                                inventoryCubit: cubit,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 20),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white, size: 28),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text("تأكيد الحذف"),
                                                content: const Text(
                                                    "هل أنت متأكد من حذف هذا المخزون؟"),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("إلغاء"),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text("حذف"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    220,
                                                                    174,
                                                                    171)),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              context
                                                  .read<InventoryCubit>()
                                                  .deleteInventory(inv.id);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is InventoryError) {
                  return Center(child: Text("خطأ: ${state.message}"));
                } else {
                  return const Center(child: Text("تحميل البيانات..."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
