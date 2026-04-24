import 'package:distributor/models/plant_model.dart';
import 'package:distributor/models/varient_model.dart';
import 'package:distributor/services/request_service.dart';
import 'package:distributor/utils/colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderRequestScreen extends StatefulWidget {
  const OrderRequestScreen({super.key});

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {
  bool isVariantEnabled = false;
  bool usePreviousStock = false; // ✅ checkbox for used_previous_stock
  bool allowRemainingStock = false; // ✅ replaces keepAtPlant
  bool isSubmitting = false;

  // ✅ Controllers
  final TextEditingController deliveredJarsController = TextEditingController();
  final TextEditingController usedPreviousStockController =
      TextEditingController();
  final TextEditingController requiredLabeledController =
      TextEditingController();
  final TextEditingController requiredUnlabeledController =
      TextEditingController();

  /// 🌱 PLANT DATA
  List<Plant> plants = [];
  Plant? selectedPlant;
  bool isLoadingPlants = true;

  /// 🧪 VARIANTS
  List<VariantData> variants = [];
  List<VariantData> selectedVariants = [];
  Map<int, TextEditingController> variantControllers = {};
  bool isLoadingVariants = true;

  // ✅ HELPER METHODS
  /// Sum of all selected variant quantities
  int _totalVariantQty() {
    int total = 0;
    for (var v in selectedVariants) {
      total += int.tryParse(variantControllers[v.id]?.text ?? "0") ?? 0;
    }
    return total;
  }

  int get _requiredLabeled => int.tryParse(requiredLabeledController.text) ?? 0;

  int get _requiredUnlabeled =>
      int.tryParse(requiredUnlabeledController.text) ?? 0;

  int get _deliveredJars => int.tryParse(deliveredJarsController.text) ?? 0;

  int get _totalRequired => _requiredLabeled + _requiredUnlabeled;

  /// ✅ VALIDATION
  String? _validateForm() {
    // 1. Plant
    if (selectedPlant == null) return "Please select a plant";

    // 2. Delivered jars
    if (_deliveredJars == 0) return "Enter delivered jars count";

    // 3. used_previous_stock (optional, only if checkbox on)
    if (usePreviousStock) {
      int prev = int.tryParse(usedPreviousStockController.text) ?? 0;
      if (prev == 0) return "Enter used previous stock count";
    }

    // 4. Required labeled jars
    if (_requiredLabeled == 0) return "Enter required labeled jars count";

    // 5. At least one variant selected
    if (selectedVariants.isEmpty) return "Select at least one variant";

    // 6. Each selected variant must have qty > 0
    for (var v in selectedVariants) {
      int qty = int.tryParse(variantControllers[v.id]?.text ?? "0") ?? 0;
      if (qty == 0) {
        return "Enter quantity for variant \"${v.variantName}\"";
      }
    }

    // 7. ✅ required_labeled_jars MUST equal sum of variant quantities
    int variantTotal = _totalVariantQty();
    if (variantTotal != _requiredLabeled) {
      return "Variant total ($variantTotal) must match required labeled jars ($_requiredLabeled)";
    }

    // 8. Required unlabeled jars
    if (_requiredUnlabeled == 0) return "Enter required unlabeled jars count";

    // 9. ✅ allow_remaining_stock validation
    if (allowRemainingStock) {
      // delivered_jars must be >= required_labeled + required_unlabeled
      if (_deliveredJars < _totalRequired) {
        return "With 'Allow Remaining Stock', delivered jars ($_deliveredJars) must be ≥ total required ($_totalRequired)";
      }
    } else {
      // delivered_jars must EXACTLY equal required_labeled + required_unlabeled
      if (_deliveredJars != _totalRequired) {
        return "Delivered jars ($_deliveredJars) must exactly equal labeled + unlabeled ($_totalRequired). Enable 'Allow Remaining Stock' for surplus.";
      }
    }

    return null; // ✅ valid
  }

  /// ✅ BUILD jars_with_label map → {"variantId": qty}
  Map<String, dynamic> _buildJarsWithLabel() {
    final Map<String, dynamic> map = {};
    for (var v in selectedVariants) {
      int qty = int.tryParse(variantControllers[v.id]?.text ?? "0") ?? 0;
      if (qty > 0) {
        map[v.id.toString()] = qty;
      }
    }
    return map;
  }

  // ✅ LIFECYCLE
  @override
  void initState() {
    super.initState();
    fetchPlants();
    fetchVariants();
  }

  @override
  void dispose() {
    deliveredJarsController.dispose();
    usedPreviousStockController.dispose();
    requiredLabeledController.dispose();
    requiredUnlabeledController.dispose();
    for (var c in variantControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ✅ API CALLS
  /// 🌱 FETCH PLANTS
  Future<void> fetchPlants() async {
    try {
      final service = RequestService();
      final data = await service.getPlants();

      setState(() {
        plants = data;
        selectedPlant = null;
        isLoadingPlants = false;
      });
    } catch (e) {
      setState(() => isLoadingPlants = false);
      _showError("Failed to load plants");
    }
  }

  /// 🧪 FETCH VARIANTS
  Future<void> fetchVariants() async {
    // setState(() => isLoadingVariants = true);

    try {
      final data = await RequestService().getVariants();
      setState(() {
        variants = data;
        isLoadingVariants = false;
      });
    } catch (e) {
      setState(() => isLoadingVariants = false);
      _showError("Failed to load variants");
    }
  }

  /// 🚀 SUBMIT ORDER
  Future<void> _submitOrder() async {
    final error = _validateForm();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await RequestService().submitOrder(
        plantId: selectedPlant!.id,
        deliveredJars: _deliveredJars,
        // usedPreviousStock: usePreviousStock
        //     ? (int.tryParse(usedPreviousStockController.text) ?? 0)
        //     : null,
        requiredLabeledJars: _requiredLabeled,
        requiredUnlabeledJars: _requiredUnlabeled,
        jarsWithLabel: _buildJarsWithLabel(),
        allowRemainingStock: allowRemainingStock,
      );

      if (mounted) {
        _showSuccess("Order submitted successfully!");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  /// 💬 SHOW ERROR
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ✅ SHOW SUCCESS
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Plant Operations",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final padding = isMobile ? 16.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 10, padding, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. PLANT ──────────────────────────────────
                _sectionLabel("PLANT SECTION"),
                const SizedBox(height: 4),
                isLoadingPlants
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _plantDropdown(),
                const SizedBox(height: 14),

                // ── 2. DELIVERED JARS ─────────────────────────
                _sectionLabel("DELIVERED JARS"),
                const SizedBox(height: 4),
                _inputBox(
                  controller: deliveredJarsController,
                  icon: Icons.local_shipping_outlined,
                  hint: "Enter delivered jars count",
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // ── 3. USE PREVIOUS STOCK (checkbox) ──────────
                _usePreviousStockCard(),
                const SizedBox(height: 14),

                // ── 4. REQUIRED LABELED JARS ──────────────────
                _sectionLabel("REQUIRED LABELED JARS"),
                const SizedBox(height: 4),
                _inputBox(
                  controller: requiredLabeledController,
                  icon: Icons.inventory_2_outlined,
                  hint: "Enter required labeled jars",
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // ── 5. VARIANTS (always visible) ──────────────
                _sectionLabel("VARIANTS & QUANTITIES"),
                const SizedBox(height: 4),
                _variantsCard(),
                const SizedBox(height: 4),

                // ✅ Live match indicator
                if (selectedVariants.isNotEmpty) _variantMatchIndicator(),
                const SizedBox(height: 14),

                // ── 6. REQUIRED UNLABELED JARS ────────────────
                _sectionLabel("REQUIRED UNLABELED JARS"),
                const SizedBox(height: 4),
                _inputBox(
                  controller: requiredUnlabeledController,
                  icon: Icons.label_off_outlined,
                  hint: "Enter required unlabeled jars",
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // ── 7. ALLOW REMAINING STOCK ──────────────────
                _allowRemainingStockCard(),
                const SizedBox(height: 14),

                // ✅ Delivery summary banner
                _deliverySummary(),
                const SizedBox(height: 24),

                // ── 8. SUBMIT ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubmitting
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : AppColors.primary,
                      elevation: isSubmitting ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSubmitting ? null : _submitOrder,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "SUBMIT ORDER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ WIDGETS
  /// ✅ Use Previous Stock checkbox + input
  Widget _usePreviousStockCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: usePreviousStock,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    usePreviousStock = val!;
                    if (!val) usedPreviousStockController.clear();
                  });
                },
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Use Previous Stock",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "INCLUDE PREVIOUS STOCK IN ORDER",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          // ✅ Show input only when checkbox is ON
          if (usePreviousStock) ...[
            const SizedBox(height: 10),
            _inputBox(
              controller: usedPreviousStockController,
              icon: Icons.inventory_outlined,
              hint: "Enter previous stock count",
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Allow Remaining Stock checkbox (replaces Keep at Plant)
  Widget _allowRemainingStockCard() {
    final int surplus = _deliveredJars - _totalRequired;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: allowRemainingStock,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => allowRemainingStock = val!),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Allow Remaining Stock",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "SURPLUS JARS STAY AT PLANT",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          // ✅ Show surplus info when enabled
          if (allowRemainingStock && surplus > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$surplus jars will remain at plant",
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Variant match indicator
  Widget _variantMatchIndicator() {
    final int variantTotal = _totalVariantQty();
    final bool isMatch =
        variantTotal == _requiredLabeled && _requiredLabeled > 0;
    final bool isOver = variantTotal > _requiredLabeled;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMatch
            ? Colors.green.shade50
            : isOver
            ? Colors.red.shade50
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMatch
              ? Colors.green.shade300
              : isOver
              ? Colors.red.shade300
              : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMatch
                ? Icons.check_circle
                : isOver
                ? Icons.error
                : Icons.info_outline,
            size: 16,
            color: isMatch
                ? Colors.green.shade700
                : isOver
                ? Colors.red.shade700
                : Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            isMatch
                ? "✅ Variant total matches required labeled jars ($variantTotal)"
                : isOver
                ? "❌ Variant total ($variantTotal) exceeds required labeled ($_requiredLabeled)"
                : "Variant total: $variantTotal / $_requiredLabeled required",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isMatch
                  ? Colors.green.shade700
                  : isOver
                  ? Colors.red.shade700
                  : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Delivery summary banner
  Widget _deliverySummary() {
    if (_deliveredJars == 0 && _totalRequired == 0) return const SizedBox();

    final bool isExact = _deliveredJars == _totalRequired;
    final bool isSurplus = _deliveredJars > _totalRequired;
    final bool isShort = _deliveredJars < _totalRequired;

    Color color = isExact
        ? Colors.green
        : isSurplus
        ? Colors.orange
        : Colors.red;

    String message = isExact
        ? "✅ Delivered jars exactly match total required ($_totalRequired)"
        : isSurplus
        ? "⚠️ ${_deliveredJars - _totalRequired} surplus jars — enable 'Allow Remaining Stock'"
        : "❌ Short by ${_totalRequired - _deliveredJars} jars";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.summarize_outlined, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Labeled: $_requiredLabeled  |  Unlabeled: $_requiredUnlabeled  |  Total: $_totalRequired",
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Variants card — always visible, no toggle
  Widget _variantsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoadingVariants)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            DropdownButtonHideUnderline(
              child: DropdownButton2<VariantData>(
                isExpanded: true,
                // ✅ Always show count/hint — never bind a real value
                customButton: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedVariants.isEmpty
                            ? "Select Variants"
                            : "${selectedVariants.length} variant(s) selected",
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedVariants.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                items: variants.map((variant) {
                  // ✅ FIX 1: enabled: true so taps register
                  return DropdownMenuItem<VariantData>(
                    value: variant,
                    enabled: true, // ✅ was false — that was blocking taps
                    child: StatefulBuilder(
                      builder: (context, menuSetState) {
                        final isSelected = selectedVariants.any(
                          (v) => v.id == variant.id,
                        );

                        void toggle() {
                          final already = selectedVariants.any(
                            (v) => v.id == variant.id,
                          );
                          if (already) {
                            selectedVariants.removeWhere(
                              (v) => v.id == variant.id,
                            );
                            variantControllers.remove(variant.id);
                          } else {
                            selectedVariants.add(variant);
                            variantControllers[variant.id] =
                                TextEditingController();
                          }
                          menuSetState(() {});
                          setState(() {});
                        }

                        // ✅ FIX 2: GestureDetector instead of InkWell
                        return GestureDetector(
                          behavior:
                              HitTestBehavior.opaque, // ✅ catches all taps
                          onTap: toggle,
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                onChanged: (_) => toggle(),
                              ),
                              Expanded(
                                child: Text(
                                  variant.variantName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),

                // ✅ FIX 3: onChanged must NOT close or reset — just ignore
                onChanged: (val) {
                  // intentionally empty — selection handled inside item
                },

                value: null, // ✅ always null for multi-select
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 300,
                  elevation: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // Selected variants qty inputs — unchanged
          if (selectedVariants.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...selectedVariants.map((v) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        v.variantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: variantControllers[v.id],
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.primary,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Qty",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _plantDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _cardDecoration().copyWith(
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Plant>(
          value: selectedPlant,
          isExpanded: true,
          hint: const Text(
            "Select Plant",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          items: plants.map((plant) {
            return DropdownMenuItem<Plant>(
              value: plant,
              child: Text(
                plant.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedPlant = val),
          buttonStyleData: const ButtonStyleData(height: 48),
          menuItemStyleData: const MenuItemStyleData(height: 48),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        color: Colors.grey,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primary,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
