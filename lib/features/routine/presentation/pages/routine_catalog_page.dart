import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/routine/domain/entities/catalog_product.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/presentation/bloc/routine_state.dart';
import 'package:kora/features/routine/routine_injection.dart';

/// Full-screen catalog browser (`public.catalog_products` in Supabase).
///
/// Allows filtering by SQL category (`cleanser`, `toner`, `serum`, `treatment`,
/// `moisturizer`, `spf`, `mask`), searching by active ingredient or brand,
/// inspecting INCI breakdown, or one-tap adding to the user's routine.
class RoutineCatalogPage extends StatefulWidget {
  /// Creates a [RoutineCatalogPage].
  const RoutineCatalogPage({super.key});

  @override
  State<RoutineCatalogPage> createState() => _RoutineCatalogPageState();
}

class _RoutineCatalogPageState extends State<RoutineCatalogPage> {
  final TextEditingController _searchController = TextEditingController();

  static const List<({String key, String label})> _categories = [
    (key: 'all', label: 'All'),
    (key: RoutineStepType.cleanser, label: 'Cleanser'),
    (key: RoutineStepType.toner, label: 'Toner'),
    (key: RoutineStepType.serum, label: 'Serum'),
    (key: RoutineStepType.treatment, label: 'Treatment'),
    (key: RoutineStepType.moisturizer, label: 'Moisturizer'),
    (key: RoutineStepType.spf, label: 'SPF'),
    (key: RoutineStepType.mask, label: 'Mask'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _quickAddCatalogProduct(BuildContext context, CatalogProduct item) {
    final bloc = context.read<RoutineBloc>();
    final now = DateTime.now();
    final period = item.category == RoutineStepType.spf
        ? RoutinePeriod.am
        : (item.category == RoutineStepType.treatment ||
                  item.category == RoutineStepType.mask
              ? RoutinePeriod.pm
              : RoutinePeriod.both);

    final product = RoutineProduct(
      id: 'item-${item.slug}-${now.millisecondsSinceEpoch}',
      userId: bloc.state.userId,
      name: item.name,
      brand: item.brand,
      stepType: item.category,
      actives: item.actives,
      period: period,
      startedOn: now,
      sortOrder: RoutineStepType.defaultOrder(item.category),
      catalogProductId: item.id,
      ingredientsRaw: item.ingredientsRaw,
      createdAt: now,
      updatedAt: now,
    );

    bloc.add(RoutineProductSaved(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} added to your routine.',
          style: AppTypography.bodySMedium.copyWith(color: AppColors.grey50),
        ),
        backgroundColor: AppColors.primary700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }
    final bloc = getIt<RoutineBloc>();
    if (bloc.state.status.isInitial) {
      bloc.add(const RoutineStarted());
    }

    return BlocProvider<RoutineBloc>.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Dermatology Catalog',
            style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<RoutineBloc, RoutineState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: AppTextField(
                      controller: _searchController,
                      hintText: 'Search brand, active, or concern...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.grey600,
                      ),
                      onChanged: (val) => context.read<RoutineBloc>().add(
                        RoutineCatalogFiltered(query: val),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected =
                            state.selectedCatalogCategory == cat.key;
                        return GestureDetector(
                          onTap: () => context.read<RoutineBloc>().add(
                            RoutineCatalogFiltered(category: cat.key),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary700
                                  : AppColors.grey50,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary700
                                    : AppColors.grey300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat.label,
                              style: AppTypography.bodyXsSemiBold.copyWith(
                                color: isSelected
                                    ? AppColors.grey50
                                    : AppColors.grey800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: state.catalogProducts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.catalogProducts[index];
                        final alreadyInRoutine = state.products.any(
                          (p) =>
                              p.catalogProductId == item.id ||
                              p.name.toLowerCase() == item.name.toLowerCase(),
                        );

                        return _CatalogProductCard(
                          item: item,
                          alreadyInRoutine: alreadyInRoutine,
                          onInspectTap: () => context.push(
                            AppRoutes.buildRoutineIngredientsPath(item.id),
                          ),
                          onAddTap: () =>
                              _quickAddCatalogProduct(context, item),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.item,
    required this.alreadyInRoutine,
    required this.onInspectTap,
    required this.onAddTap,
  });

  final CatalogProduct item;
  final bool alreadyInRoutine;
  final VoidCallback onInspectTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      onTap: onInspectTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Text(
                  RoutineStepType.displayLabel(item.category).toUpperCase(),
                  style: AppTypography.bodyXsBold.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.brand != null)
                Text(
                  item.brand!,
                  style: AppTypography.bodyXsSemiBold.copyWith(
                    color: AppColors.primary800,
                  ),
                ),
              const Spacer(),
              Semantics(
                button: true,
                label: alreadyInRoutine
                    ? '${item.name} is already in your routine'
                    : 'Add ${item.name} to routine',
                child: InkWell(
                  onTap: alreadyInRoutine ? null : onAddTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: alreadyInRoutine
                          ? AppColors.primary50
                          : AppColors.primary700,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: alreadyInRoutine
                            ? AppColors.primary200
                            : AppColors.primary700,
                      ),
                    ),
                    child: Text(
                      alreadyInRoutine ? 'In Routine' : '+ Add',
                      style: AppTypography.bodyXsSemiBold.copyWith(
                        color: alreadyInRoutine
                            ? AppColors.primary800
                            : AppColors.grey50,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: AppTypography.bodyLSemiBold.copyWith(
              color: AppColors.grey1050,
            ),
          ),
          if (item.goodFor != null) ...[
            const SizedBox(height: 4),
            Text(
              'Good for: ${item.goodFor!}',
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ],
          if (item.skipIf != null) ...[
            const SizedBox(height: 2),
            Text(
              'Skip if: ${item.skipIf!}',
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppColors.secondary800,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.actives.map((active) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Text(
                  active,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
