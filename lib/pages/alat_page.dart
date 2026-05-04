import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/alat_controller.dart';
import 'package:fluxfit/controllers/budget_controller.dart';
import 'package:fluxfit/models/alat.dart';
import 'package:fluxfit/models/budget.dart';
import 'package:fluxfit/models/budget_list.dart';
import 'package:fluxfit/session/session_helper.dart';

class AlatPage extends StatefulWidget {
  const AlatPage({super.key});

  @override
  State<AlatPage> createState() => _AlatPageState();
}

class _AlatPageState extends State<AlatPage> {
  final AlatController alatController = AlatController();
  final BudgetController budgetController = BudgetController();

  List<Alat> alatList = [];
  List<Alat> allAlat = [];
  Map<int, int> cart = {};
  String search = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}";
  }

  Future<void> _loadData() async {
    final all = await alatController.getAll();

    List<Alat> data;

    if (search.isNotEmpty) {
      data = all
          .where((a) => a.nama.toLowerCase().contains(search.toLowerCase()))
          .toList();
    } else {
      data = all;
    }

    setState(() {
      allAlat = all;
      alatList = data;
    });
  }

  Widget _buildCartSheet() {
    if (cart.isEmpty) return const SizedBox();

    final selectedItems = allAlat
        .where((a) => cart.containsKey(a.alatId))
        .toList();

    double total = 0;
    for (var item in selectedItems) {
      total += item.harga * cart[item.alatId]!;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Text(
                "Keranjang Alat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 10),

              ...selectedItems.map((item) {
                int qty = cart[item.alatId]!;

                return Row(
                  children: [
                    // 📦 NAMA
                    Expanded(
                      flex: 4,
                      child: Text(item.nama, overflow: TextOverflow.ellipsis),
                    ),

                    // ➖ QTY ➕
                    Expanded(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_rounded,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (qty > 1) {
                                    cart[item.alatId!] = qty - 1;
                                  } else {
                                    cart.remove(item.alatId);
                                  }
                                });
                              },
                              color: Colors.blueAccent,
                            ),
                            Text(qty.toString()),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_rounded,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  cart[item.alatId!] = qty + 1;
                                });
                              },
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 💰 HARGA
                    Expanded(
                      flex: 3,
                      child: Text(
                        formatRupiah(item.harga * qty),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              }),

              const Divider(),

              Text("Total: ${formatRupiah(total.toInt())}"),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final controller = TextEditingController();

                  final namaBudget = await showDialog<String>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text(
                        "Nama Budget Plan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, controller.text);
                          },
                          child: const Text("Simpan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );

                  // kalau user cancel atau kosong
                  if (namaBudget == null || namaBudget.trim().isEmpty) return;

                  final userId = await SessionHelper.getUserId();
                  if (userId == null) return;

                  // 🔥 INSERT BUDGET
                  final budgetId = await budgetController.insertBudget(
                    Budget(
                      userId: userId,
                      nama: namaBudget,
                      datetime: DateTime.now().toIso8601String(),
                    ),
                  );

                  // 🔥 INSERT ITEM
                  for (var entry in cart.entries) {
                    await budgetController.insertBudgetList(
                      BudgetList(
                        budgetId: budgetId,
                        alatId: entry.key,
                        jumlah: entry.value,
                      ),
                    );
                  }

                  setState(() {
                    cart.clear();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      content: Text("Budget plan berhasil dibuat!"),
                    ),
                  );

                  Navigator.pop(context, true);
                },
                child: Text("Buat Budget Plan"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Alat Olahraga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 🔍 SEARCH BAR
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari alat...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    search = value;
                    _loadData();
                  },
                ),
              ),

              // 📦 LIST
              Expanded(
                child: alatList.isEmpty
                    ? const Center(child: Text("Tidak ada data"))
                    : ListView.builder(
                        itemCount: alatList.length,
                        itemBuilder: (context, index) {
                          final alat = alatList[index];
                          final isInCart = cart.containsKey(alat.alatId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // 🖼 IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      alat.gambar!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  // 📝 TEXT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              alat.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isInCart
                                                    ? Icons.check_circle
                                                    : Icons.add_circle,
                                                color: isInCart
                                                    ? Colors.green
                                                    : Colors.blueAccent,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  cart.update(
                                                    alat.alatId!,
                                                    (val) => val + 1,
                                                    ifAbsent: () => 1,
                                                  );
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          formatRupiah(alat.harga),
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          alat.deskripsi!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
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
                      ),
              ),
              SizedBox(height: 80),
            ],
          ),
          _buildCartSheet(),
        ],
      ),
    );
  }
}
