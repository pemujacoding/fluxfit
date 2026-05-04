import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/budget_controller.dart';

class DetailbudgetPage extends StatefulWidget {
  final int budgetId;
  final String nama;

  const DetailbudgetPage({
    super.key,
    required this.budgetId,
    required this.nama,
  });

  @override
  State<DetailbudgetPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<DetailbudgetPage> {
  final BudgetController controller = BudgetController();

  List<Map<String, dynamic>> items = [];
  int total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}";
  }

  Future<void> _loadData() async {
    final data = await controller.getBudgetDetailed(widget.budgetId);

    int sum = 0;
    for (var item in data) {
      sum += (item['harga'] as int) * (item['jumlah'] as int);
    }

    setState(() {
      items = data;
      total = sum;
    });
  }

  void _deleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Budget Plan?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text("Data yang dihapus tidak bisa dikembalikan"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await controller.deleteBudget(widget.budgetId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _update() {
    final _editController = TextEditingController(text: widget.nama);

    // Set the current name as the initial text (Optional but better UX)
    // _editController.text = currentBudgetName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Nama Budget Plan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: TextField(controller: _editController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // READ THE TEXT HERE - Right when the button is clicked!
              String newName = _editController.text;

              if (newName.isNotEmpty) {
                await controller.updateBudgetName(newName, widget.budgetId);

                // If this is a StatefulWidget, you might want to call _loadData() here
                // before closing the dialog.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    content: Text("Nama budget plan berhasil diupdate"),
                  ),
                );
                Navigator.pop(context);
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _update();
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  _deleteConfirm();
                },
                style: IconButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      final nama = item['nama'];
                      final harga = item['harga'];
                      final gambar = item['gambar'];
                      final jumlah = item['jumlah'];

                      final subtotal = harga * jumlah;

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
                                  gambar,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // 📝 INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${formatRupiah(harga)} x $jumlah",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 💰 SUBTOTAL
                              Text(
                                formatRupiah(subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🔥 TOTAL BOX
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
