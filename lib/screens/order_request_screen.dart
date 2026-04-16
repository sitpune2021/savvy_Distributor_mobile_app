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
  bool keepAtPlant = false;
  bool isSubmitting = false;

  final TextEditingController filledJarsController = TextEditingController();
  final TextEditingController unlabeledJarsController = TextEditingController();

  /// 🌱 PLANT DATA
  List<Plant> plants = [];
  Plant? selectedPlant;
  bool isLoadingPlants = true;

  /// 🧪 VARIANTS
  List<VariantData> variants = [];
  List<VariantData> selectedVariants = [];
  Map<int, TextEditingController> variantControllers = {};
  bool isLoadingVariants = false;

  /// 📊 CALCULATED VALUES
  int _remainingQuantity = 0;

  // ============================================
  // ✅ HELPER METHODS
  // ============================================

  /// 🔢 GET TOTAL VARIANT QUANTITY
  int getTotalVariantQty() {
    int total = 0;

    for (var v in selectedVariants) {
      final text = variantControllers[v.id]?.text ?? "0";
      total += int.tryParse(text) ?? 0;
    }

    return total;
  }

  /// 🧮 CALCULATE REMAINING QUANTITY
  int _calculateRemaining() {
    int filled = int.tryParse(filledJarsController.text) ?? 0;
    int unlabeled = int.tryParse(unlabeledJarsController.text) ?? 0;

    int allocated = unlabeled;

    if (isVariantEnabled) {
      allocated += getTotalVariantQty();
    }

    return filled - allocated;
  }

  /// ✅ DETERMINE IF "KEEP AT PLANT" SHOULD BE TRUE
  /// Returns true if remaining quantity > 0 (not all allocated)
  bool _shouldKeepAtPlant() {
    return _calculateRemaining() > 0;
  }

  /// 🔴 VALIDATION LOGIC
  /// Returns error message if validation fails, null if valid
  String? _validateForm() {
    // 1️⃣ PLANT REQUIRED
    if (selectedPlant == null) {
      return "Please select a plant";
    }

    // 2️⃣ FILLED JARS REQUIRED
    int filled = int.tryParse(filledJarsController.text) ?? 0;
    if (filled == 0) {
      return "Enter filled jars quantity";
    }

    // 3️⃣ UNLABELED JARS REQUIRED
    int unlabeled = int.tryParse(unlabeledJarsController.text) ?? 0;
    if (unlabeled == 0) {
      return "Enter unlabeled jars count";
    }

    // 4️⃣ VARIANT VALIDATION
    if (isVariantEnabled) {
      if (selectedVariants.isEmpty) {
        return "Select at least one variant";
      }

      // Check if all selected variants have quantity > 0
      for (var v in selectedVariants) {
        int qty = int.tryParse(variantControllers[v.id]?.text ?? "0") ?? 0;
        if (qty == 0) {
          return "Enter quantity for all selected variants";
        }
      }
    }

    // 5️⃣ QUANTITY MATCH VALIDATION
    int remaining = _calculateRemaining();

    if (remaining < 0) {
      return "Total allocated (${filled - remaining}) exceeds filled jars ($filled)";
    }

    if (remaining > 0 && !keepAtPlant) {
      return "Set 'Keep at Plant' for remaining $remaining jars";
    }

    if (remaining == 0 && keepAtPlant) {
      return "Uncheck 'Keep at Plant' - all jars are allocated";
    }

    return null; // ✅ ALL VALID
  }

  /// 📦 BUILD LABEL BREAKDOWN
  List<Map<String, dynamic>> buildLabelBreakdown() {
    List<Map<String, dynamic>> list = [];

    if (isVariantEnabled) {
      for (var v in selectedVariants) {
        int qty = int.tryParse(variantControllers[v.id]?.text ?? "0") ?? 0;
        if (qty > 0) {
          list.add({"raw_material_variant_id": v.id, "quantity": qty});
        }
      }
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    fetchPlants();

    /// 👂 LISTEN TO QUANTITY CHANGES
    filledJarsController.addListener(_updateKeepAtPlantState);
    unlabeledJarsController.addListener(_updateKeepAtPlantState);
  }

  /// ✅ AUTO-UPDATE KEEP AT PLANT STATE
  void _updateKeepAtPlantState() {
    setState(() {
      _remainingQuantity = _calculateRemaining();

      // Auto-set based on remaining quantity
      if (_shouldKeepAtPlant()) {
        keepAtPlant = true;
      } else {
        keepAtPlant = false;
      }
    });
  }

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
    setState(() => isLoadingVariants = true);

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
    // Validate form
    String? validationError = _validateForm();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      int filled = int.tryParse(filledJarsController.text) ?? 0;
      int unlabeled = int.tryParse(unlabeledJarsController.text) ?? 0;

      final service = RequestService();
      await service.submitOrder(
        plantId: selectedPlant!.id,
        requiredQuantity: filled,
        labelBreakdown: buildLabelBreakdown(),
        unlabelCount: unlabeled,
        keepAtPlant: keepAtPlant,
      );

      if (mounted) {
        _showSuccess("Order submitted successfully!");

        // Reset form after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
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
  void dispose() {
    filledJarsController.removeListener(_updateKeepAtPlantState);
    unlabeledJarsController.removeListener(_updateKeepAtPlantState);
    filledJarsController.dispose();
    unlabeledJarsController.dispose();

    for (var controller in variantControllers.values) {
      controller.dispose();
    }

    super.dispose();
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
          final double width = constraints.maxWidth;
          final bool isMobile = width < 600;
          final bool isTablet = width < 1024;
          final double containerWidth = isMobile
              ? double.infinity
              : (isTablet ? 500 : 420);
          final double padding = isMobile ? 16 : 24;

          return SizedBox(
            width: containerWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 10, padding, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🌱 PLANT
                    _sectionLabel("PLANT SECTION"),
                    const SizedBox(height: 4),
                    isLoadingPlants
                        ? const Center(child: CircularProgressIndicator())
                        : _plantDropdown(),
                    const SizedBox(height: 14),

                    /// 🔢 REQUIRED JARS
                    _sectionLabel("REQUIRED FILLED JARS"),
                    const SizedBox(height: 4),
                    _numberInputBox(
                      controller: filledJarsController,
                      icon: Icons.inventory_2_outlined,
                      hint: "Enter quantity",
                    ),
                    const SizedBox(height: 14),

                    /// 🔁 TOGGLE
                    _rawMaterialToggle(),
                    const SizedBox(height: 14),

                    /// 🧪 VARIANTS
                    if (isVariantEnabled) ...[
                      _variantsCard(),
                      const SizedBox(height: 14),
                    ],

                    /// 🔢 UNLABELEDOUNT"),
                    _sectionLabel("UNLABELED JARS COUNT"),
                    const SizedBox(height: 4),
                    _numberInputBox(
                      controller: unlabeledJarsController,
                      icon: Icons.label_off_outlined,
                      hint: "Enter count",
                    ),
                    const SizedBox(height: 14),

                    /// 📊 REMAINING QUANTITY DISPLAY
                    if (_remainingQuantity > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Remaining: $_remainingQuantity jars (Keep at Plant enabled)",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    /// ── KEEP AT PLANT ──
                    _keepAtPlantCard(),
                    const SizedBox(height: 24),

                    /// 🚀 BUTTON
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "SUBMIT",
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
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ DROPDOWN FOR PLANTS
  Widget _plantDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      // decoration: _cardDecoration(),
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
          onChanged: (value) {
            setState(() {
              selectedPlant = value;
            });
          },

          /// ✅ FIXED NEW STYLE
          buttonStyleData: const ButtonStyleData(height: 48),
          menuItemStyleData: const MenuItemStyleData(height: 48),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,

            /// ✅ WHITE BACKGROUND
            decoration: BoxDecoration(
              color: Colors.white, // 👈 important
              borderRadius: BorderRadius.circular(16), // 👈 curve dropdown
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

  /// 🔢 INPUT
  Widget _numberInputBox({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
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
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),

              /// ✅ ONLY NUMBERS
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔁 TOGGLE
  Widget _rawMaterialToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.science, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Raw Material Variant",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "ADDITIONAL CONFIGURATION",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(
              alpha: 0.4,
            ), // ✅ track color
            value: isVariantEnabled,
            onChanged: (val) async {
              setState(() => isVariantEnabled = val);

              if (val) {
                await fetchVariants();
              } else {
                selectedVariants.clear();
                variantControllers.clear();
                _updateKeepAtPlantState();
              }
            },
          ),
        ],
      ),
    );
  }

  /// 🧪 VARIANT UI
  Widget _variantsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SELECT VARIANTS & QUANTITY"),
          const SizedBox(height: 10),

          /// 🔄 LOADING
          if (isLoadingVariants)
            const Center(child: CircularProgressIndicator()),

          /// ✅ DROPDOWN
          if (!isLoadingVariants)
            DropdownButtonHideUnderline(
              child: DropdownButton2<VariantData>(
                isExpanded: true,
                hint: const Text("Select Variants"),

                items: variants.map((variant) {
                  return DropdownMenuItem<VariantData>(
                    value: variant,
                    enabled: false,

                    /// 🔥 FIXED STATE
                    child: StatefulBuilder(
                      builder: (context, menuSetState) {
                        bool isSelected = selectedVariants.any(
                          (v) => v.id == variant.id,
                        );

                        void toggleSelection() {
                          final alreadySelected = selectedVariants.any(
                            (v) => v.id == variant.id,
                          );

                          if (alreadySelected) {
                            selectedVariants.removeWhere(
                              (v) => v.id == variant.id,
                            );
                            variantControllers.remove(variant.id);
                          } else {
                            selectedVariants.add(variant);
                            variantControllers[variant.id] =
                                TextEditingController();
                          }

                          /// ⚡ FAST UI UPDATE
                          menuSetState(() {});
                          // setState(() {});
                          setState(() => _updateKeepAtPlantState());
                        }

                        return InkWell(
                          onTap: toggleSelection,
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                onChanged: (_) => toggleSelection(),
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

                onChanged: (_) {},

                /// ✅ SHOW COUNT
                value: selectedVariants.isEmpty ? null : selectedVariants.first,

                selectedItemBuilder: (context) {
                  return variants.map((variant) {
                    return Text(
                      selectedVariants.isEmpty
                          ? "Select Variants"
                          : "${selectedVariants.length} selected",
                      style: const TextStyle(fontSize: 14),
                    );
                  }).toList();
                },

                /// 🎨 STYLE
                buttonStyleData: const ButtonStyleData(height: 48),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 300,
                  elevation: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          /// ✅ SELECTED VARIANTS LIST
          ...selectedVariants.map((v) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// NAME
                  Expanded(
                    child: Text(
                      v.variantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  /// INPUT
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: variantControllers[v.id],
                          keyboardType: TextInputType.number,
                          cursorColor: AppColors.primary,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) =>
                              setState(() => _updateKeepAtPlantState()),
                          decoration: InputDecoration(
                            hintText: "Qty",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),

                            /// ✅ DEFAULT BORDER
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),

                            /// ✅ FOCUSED BORDER
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

                      const SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _keepAtPlantCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Checkbox(
            value: keepAtPlant,
            activeColor: AppColors.primary,
            // onChanged: (val) => setState(() => keepAtPlant = val!),
            onChanged: (val) {
              setState(() {
                // Only allow manual change if it matches the calculated state
                if (val == _shouldKeepAtPlant()) {
                  keepAtPlant = val!;
                } else {
                  _showError(
                    "Keep at Plant must be ${_shouldKeepAtPlant() ? 'enabled' : 'disabled'} based on quantities",
                  );
                }
              });
            },
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Keep at Plant",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                "IMMEDIATE STORAGE PROTOCOLS",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
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
