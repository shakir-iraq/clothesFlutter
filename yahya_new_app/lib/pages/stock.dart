import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:yahya_new_app/cubit-state/stock-Cub-State/stock-cub.dart';
import 'package:yahya_new_app/cubit-state/stock-Cub-State/stock-state.dart';
import 'package:yahya_new_app/model/inventory.dart';
import 'package:yahya_new_app/components/stock-popup.dart';

class StockPage extends StatefulWidget {
  final List<Inventory> inventory;

  const StockPage({super.key, required this.inventory});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  int? selectedProductId;
  int? selectedMovementType;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  void _loadMovements() {
    context.read<StockCubit>().loadMovements(
          inventoryId: selectedProductId,
          movementType: selectedMovementType,
        );
  }

  Future<void> _showAddMovementDialog() async {
    final stockCubit = context.read<StockCubit>();
    await showDialog(
      context: context,
      builder: (context) {
        return StockMovementDialog(
          inventory: widget.inventory,
          stockCubit: stockCubit,
        );
      },
    );
    _loadMovements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232F34),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
        ),
        backgroundColor: const Color(0xFF232F34),
        title: Center(
          child: const Text(
            'ادارة الحركات ',
            style: TextStyle(color: Color.fromARGB(255, 247, 246, 243)),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: _showAddMovementDialog,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF344955),
                      Color.fromARGB(255, 27, 59, 78)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownSearch<Inventory?>(
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      menuProps: const MenuProps(
                        backgroundColor: Colors.white,
                      ),
                      // ✅ هنا نعرّف كيف يتم عرض العناصر في القائمة المنسدلة
                      itemBuilder: (context, Inventory? item, bool isSelected) {
                        return Directionality(
                          textDirection:
                              TextDirection.rtl, // <-- هنا تغيير الاتجاه
                          child: item == null
                              ? const ListTile(
                                  title: Text('اختيار كل المنتجات'))
                              : ListTile(
                                  title: Text(
                                    '${item.productName} - ${item.colorName} - ${item.sizeName}',
                                  ),
                                ),
                        );
                      },
                    ),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 3),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                      ),
                    ),
                    items: [null, ...widget.inventory],
                    selectedItem: selectedProductId == null
                        ? null
                        : widget.inventory.firstWhere(
                            (inv) => inv.id == selectedProductId,
                          ),
                    itemAsString: (Inventory? inv) {
                      if (inv == null) return 'اختيار كل المنتجات';
                      return '${inv.productName} - ${inv.colorName} - ${inv.sizeName}';
                    },
                    compareFn: (a, b) => a?.id == b?.id,
                    dropdownBuilder: (context, Inventory? selectedItem) {
                      if (selectedItem == null) {
                        return const Text(
                          textAlign: TextAlign.center,
                          'اختيار كل المنتجات',
                          style: TextStyle(
                            color: Color.fromARGB(255, 12, 12, 12),
                            fontSize: 16,
                          ),
                        );
                      }
                      return Text(
                        '${selectedItem.productName} - ${selectedItem.colorName} - ${selectedItem.sizeName}',
                      );
                    },
                    onChanged: (Inventory? selected) {
                      setState(() {
                        selectedProductId = selected?.id;
                      });
                      _loadMovements();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                    flex: 1,
                    child: Directionality(
                      textDirection: TextDirection.rtl, // لجعل القائمة RTL
                      child: DropdownButtonFormField<int>(
                        value: selectedMovementType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                        ),
                        dropdownColor: Colors.white,
                        items: const [
                          DropdownMenuItem(
                              value: null, child: Text("كل الحركات")),
                          DropdownMenuItem(value: 1, child: Text("إضافة")),
                          DropdownMenuItem(value: -1, child: Text("خصم")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedMovementType = value;
                          });
                          _loadMovements();
                        },
                        selectedItemBuilder: (context) {
                          return const [
                            Align(
                              alignment:
                                  Alignment.center, // محاذاة في الوسط أفقيًا
                              child: Text(
                                "كل الحركات",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "إضافة",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "خصم",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ];
                        },
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<StockCubit, StockState>(
                builder: (context, state) {
                  if (state is StockLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StockLoaded) {
                    if (state.movements.isEmpty) {
                      return const Center(child: Text('لا توجد حركات'));
                    }
                    return ListView.builder(
                      itemCount: state.movements.length,
                      itemBuilder: (context, index) {
                        final move = state.movements[index];
                        final isAddition = move.quantity > 0;

                        final inv = widget.inventory
                            .firstWhere((i) => i.id == move.inventoryId);

                        return Card(
                          color: Color.fromARGB(236, 255, 255, 254),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: 120,
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                inv.fullImageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          inv.fullImageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 60),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          ' ${inv.sizeName} - ${inv.productName} - ${inv.colorName} ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Text(
                                          'الكمية: ${move.quantity} (${isAddition ? 'إضافة' : 'خصم'})',
                                          style: TextStyle(
                                            color: isAddition
                                                ? Color.fromARGB(
                                                    255, 30, 145, 34)
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (move.notes != null &&
                                          move.notes!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Center(
                                            child: Text(
                                              'ملاحظات: ${move.notes}',
                                              style:
                                                  const TextStyle(fontSize: 22),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      if (move.movementDate != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Center(
                                            child: Text(
                                              'التاريخ: ${move.movementDate!.toLocal().toString().substring(0, 16)}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blueGrey),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is StockError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
