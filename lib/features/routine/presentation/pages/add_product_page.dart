import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/product_scanner/data/datasources/product_remote_datasource.dart';
import 'package:kora/features/product_scanner/data/models/skincare_report_model.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/presentation/widgets/add_product_form_sections.dart';
import 'package:kora/features/routine/routine_injection.dart';

/// Screen to add a new skincare product to the routine (C08 in blueprint),
/// persisting directly to `public.routine_items` via [RoutineBloc] and
/// integrated with the Kora Product Scanner AI Agents.
class AddProductPage extends StatefulWidget {
  /// Creates an [AddProductPage].
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedStep = RoutineStepType.serum;
  String _selectedPeriod = RoutinePeriod.both;
  final Set<String> _selectedActives = {'Niacinamide'};

  bool _isAnalyzingAi = false;
  SkincareReport? _aiReport;

  static const List<String> _commonActives = [
    'Niacinamide',
    'Hyaluronic Acid',
    'Retinol',
    'Salicylic Acid',
    'L-Ascorbic Acid',
    'Ceramides',
    'Azelaic Acid',
    'Panthenol',
    'Squalane',
    'Zinc Oxide',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _analyzeProductWithAi([String? rawQuery]) async {
    final query = (rawQuery ?? _searchController.text).trim();
    if (query.isEmpty) return;

    setState(() => _isAnalyzingAi = true);

    try {
      final getIt = GetIt.instance;
      ProductRemoteDataSource dataSource;
      if (getIt.isRegistered<ProductRemoteDataSource>()) {
        dataSource = getIt<ProductRemoteDataSource>();
      } else {
        dataSource = ProductRemoteDataSourceImpl(
          aiApiClient: getIt.isRegistered<KoraAiApiClient>()
              ? getIt<KoraAiApiClient>()
              : null,
        );
      }

      final rawJson = await dataSource.searchProductByOcrText(
        rawText: query,
        lines: <String>[query],
        imagePath: '',
      );
      final report = SkincareReportModel.fromJson(rawJson).toEntity();

      if (!mounted) return;
      setState(() {
        _aiReport = report;
        if (report.product.name.isNotEmpty) {
          _nameController.text = report.product.name;
        }
        if (report.product.brand.isNotEmpty) {
          _brandController.text = report.product.brand;
        }
        final cat = report.product.category.toLowerCase();
        if (cat.contains('clean')) {
          _selectedStep = RoutineStepType.cleanser;
        } else if (cat.contains('toner')) {
          _selectedStep = RoutineStepType.toner;
        } else if (cat.contains('moist') || cat.contains('cream')) {
          _selectedStep = RoutineStepType.moisturizer;
        } else if (cat.contains('spf') || cat.contains('sun')) {
          _selectedStep = RoutineStepType.spf;
        } else if (cat.contains('treat') || cat.contains('retinol')) {
          _selectedStep = RoutineStepType.treatment;
        } else {
          _selectedStep = RoutineStepType.serum;
        }
        if (report.formulaStatic.isNotEmpty) {
          _selectedActives
            ..clear()
            ..addAll(
              report.formulaStatic
                  .take(4)
                  .map((ingredient) => ingredient.inciName),
            );
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isAnalyzingAi = false);
      }
    }
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a product name.',
            style: AppTypography.bodySMedium.copyWith(color: AppColors.grey50),
          ),
          backgroundColor: AppColors.error400,
        ),
      );
      return;
    }

    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }
    final bloc = getIt<RoutineBloc>();
    final now = DateTime.now();

    final newProduct = RoutineProduct(
      id: 'item-${now.millisecondsSinceEpoch}',
      userId: bloc.state.userId,
      name: name,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      stepType: _selectedStep,
      actives: _selectedActives.toList(),
      period: _selectedPeriod,
      startedOn: now,
      sortOrder: RoutineStepType.defaultOrder(_selectedStep),
      ingredientsRaw: _aiReport?.formulaStatic
          .map((i) => i.inciName)
          .join(', '),
      createdAt: now,
      updatedAt: now,
    );

    bloc.add(RoutineProductSaved(newProduct));

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return ProductSavedConfirmSheet(
          productName: name,
          onStartExperiment: () {
            Navigator.of(bottomSheetContext).pop();
            context.pushReplacement(AppRoutes.experimentNew);
          },
          onKeepInRoutine: () {
            Navigator.of(bottomSheetContext).pop();
            context.pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Add Product',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.routineCatalog),
            child: Text(
              'Catalog',
              style: AppTypography.bodySMedium.copyWith(
                color: AppColors.primary700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _searchController,
                      hintText: 'Search product, barcode, or paste INCI...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: 'Analyze product with Kora AI',
                    child: InkWell(
                      onTap: _isAnalyzingAi ? null : _analyzeProductWithAi,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _isAnalyzingAi
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.grey50,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: AppColors.grey50,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AI Match',
                                    style: AppTypography.bodyXsSemiBold
                                        .copyWith(color: AppColors.grey50),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_aiReport != null) ...[
                AddProductAiVerdictCard(report: _aiReport!),
                const SizedBox(height: 12),
              ],
              const AddProductOcrShortcutCard(),
              const SizedBox(height: 20),
              Text(
                'Step Category',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RoutineStepType.values.map((step) {
                  final isSelected = _selectedStep == step;
                  return ChoiceChip(
                    label: Text(RoutineStepType.displayLabel(step)),
                    selected: isSelected,
                    selectedColor: AppColors.primary700,
                    backgroundColor: AppColors.grey100,
                    labelStyle: AppTypography.bodyXsSemiBold.copyWith(
                      color: isSelected ? AppColors.grey50 : AppColors.grey800,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary700
                          : AppColors.grey300,
                    ),
                    onSelected: (_) => setState(() => _selectedStep = step),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Product Name',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: _nameController,
                hintText: 'e.g. Niacinamide 10% + Zinc 1%',
              ),
              const SizedBox(height: 14),
              Text(
                'Brand',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: _brandController,
                hintText: 'e.g. The Ordinary',
              ),
              const SizedBox(height: 16),
              Text(
                'Key Actives (Optional)',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: {..._commonActives, ..._selectedActives}.map((a) {
                  final isSelected = _selectedActives.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: isSelected,
                    selectedColor: AppColors.primary100,
                    backgroundColor: AppColors.grey100,
                    labelStyle: AppTypography.bodyXsMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary900
                          : AppColors.grey800,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary700
                          : AppColors.grey300,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedActives.add(a);
                        } else {
                          _selectedActives.remove(a);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'When do you use it?',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              AddProductPeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodSelected: (period) =>
                    setState(() => _selectedPeriod = period),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Save product',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: _onSave,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
