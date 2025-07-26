import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiCategory.dart';
import 'package:yahya_new_app/components/product-popup.dart';
import 'package:yahya_new_app/cubit-state/product-Cub-State/product-cub.dart';
import 'package:yahya_new_app/cubit-state/product-Cub-State/product-state.dart';
import 'package:yahya_new_app/model/category.dart';
import 'package:yahya_new_app/model/product.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedCategoryId = 0;
  List<Categorys> categories = [];
  int? selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndProducts();
  }

  Future<void> _loadCategoriesAndProducts() async {
    await context.read<ProductCubit>().loadProducts();
    final products = context.read<ProductCubit>().state is ProductLoaded
        ? (context.read<ProductCubit>().state as ProductLoaded).products
        : [];

    final cats = await ApiCategory().getAllCategoriesFromApi();

    final Set<dynamic> usedCategoryIds =
        products.map((p) => p.categoryId).toSet();

    categories = [
      Categorys(id: 0, name: 'الكل'),
      ...cats.where((cat) => usedCategoryIds.contains(cat.id))
    ];

    setState(() {});
  }

  List<Product> _filterProducts(List<Product> allProducts) {
    if (selectedCategoryId == 0) return allProducts;
    return allProducts
        .where((p) => p.categoryId == selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final productCubit = context.read<ProductCubit>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF232F34),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
        ),
        title: const Text(
          "ادارة المنتجات",
          style: TextStyle(
              color: Color.fromARGB(255, 248, 246, 243), fontSize: 24),
        ),
        backgroundColor: Color.fromARGB(255, 31, 40, 44),
        elevation: 5,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () async {
                final cats = await ApiCategory().getAllCategoriesFromApi();
                await showDialog(
                  context: context,
                  builder: (context) {
                    return BlocProvider.value(
                      value: productCubit,
                      child: ProductDialog(categories: cats),
                    );
                  },
                );
                await productCubit.loadProducts();
                setState(() {});
              },
              splashColor: Colors.pink.shade100,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      const Color(0xFF344955),
                      Color.fromARGB(255, 35, 79, 104)
                    ],
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
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductError) {
                  return Center(child: Text(state.message ?? 'حدث خطأ'));
                } else if (state is ProductLoaded) {
                  final productsToShow = _filterProducts(state.products);

                  if (productsToShow.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات'));
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 600,
                        width: screenWidth < 600
                            ? screenWidth * 1
                            : screenWidth * 0.6,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 580,
                            autoPlay: true,
                            viewportFraction: 0.90,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayCurve: Curves.slowMiddle,
                            // enlargeCenterPage: true,
                          ),
                          items: productsToShow.map((product) {
                            final imgUrl = product.fullImageUrl ?? '';
                            final isSelected = selectedProductId == product.id;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedProductId =
                                      isSelected ? null : product.id;
                                });
                              },
                              child: Card(
                                color: const Color(0xFF344955),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(15)),
                                          child: imgUrl.isNotEmpty
                                              ? Image.network(
                                                  imgUrl.startsWith('http')
                                                      ? imgUrl
                                                      : 'http://192.168.18.3:7045/$imgUrl',
                                                  height: 500,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  height: 200,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1, vertical: 11),
                                          child: Column(
                                            children: [
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 218, 192, 132),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                  " ${product.categoryName} - ${product.price}",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 219, 192, 128))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.4),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Color.fromARGB(
                                                          255, 105, 14, 14),
                                                      size: 32),
                                                  onPressed: () async {
                                                    final cats = await ApiCategory()
                                                        .getAllCategoriesFromApi();
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return BlocProvider
                                                            .value(
                                                          value: productCubit,
                                                          child: ProductDialog(
                                                            product: product,
                                                            categories: cats,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    await productCubit
                                                        .loadProducts();
                                                    setState(() {
                                                      selectedProductId = null;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(width: 20),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.white,
                                                      size: 32),
                                                  onPressed: () async {
                                                    final confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'تأكيد الحذف'),
                                                        content: const Text(
                                                            'هل أنت متأكد من حذف هذا المنتج؟'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    false),
                                                            child: const Text(
                                                                'إلغاء'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            child: const Text(
                                                                'حذف'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await productCubit
                                                          .deleteProduct(
                                                              product.id);
                                                      await productCubit
                                                          .loadProducts();
                                                      setState(() {
                                                        selectedProductId =
                                                            null;
                                                      });
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
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF344955),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: categories.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  final isSelected =
                                      cat.id == selectedCategoryId;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCategoryId = cat.id ?? 0;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 237, 155, 104),
                                                  Color.fromARGB(
                                                      255, 213, 165, 76),
                                                ],
                                              )
                                            : const LinearGradient(
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 226, 212, 155),
                                                  Color.fromARGB(
                                                      255, 233, 211, 185),
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: isSelected
                                              ? Color.fromARGB(
                                                  255, 224, 198, 94)
                                              : Color.fromARGB(
                                                  255, 245, 232, 158),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          if (isSelected)
                                            BoxShadow(
                                              color: Colors.pink.shade100
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    255, 40, 30, 5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
