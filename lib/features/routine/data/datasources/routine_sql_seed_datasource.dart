import 'package:kora/features/routine/domain/entities/catalog_product.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';

/// Provides realistic seed data strictly aligned with the PostgreSQL tables in
/// `supabase/migrations/20261012000000_skinproof_init.sql`:
/// - `public.routine_items`
/// - `public.routine_logs`
/// - `public.catalog_products`
/// - `public.checkins`
///
/// Used as an automatic local seed when the local Drift cache is empty so that
/// every screen in the Routine shell renders rich, believable data immediately
/// while remaining 100% compatible with real Supabase sync.
abstract final class RoutineSqlSeedDataSource {
  /// Default demo user UUID matching the demo seed profile ("Amina").
  static const String defaultUserId = 'demo-user-amina';

  /// Formats a [DateTime] as an ISO date string (`YYYY-MM-DD`).
  static String formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Default `public.routine_items` aligned with `seed_demo_data()` in
  /// `20261012000000_skinproof_init.sql`.
  static List<RoutineProduct> buildSeedRoutineItems({
    required String userId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    return [
      RoutineProduct(
        id: 'item-cerave-cleanser',
        userId: userId,
        name: 'Hydrating Facial Cleanser',
        brand: 'CeraVe',
        stepType: RoutineStepType.cleanser,
        actives: const ['Ceramides NP, AP, EOP', 'Hyaluronic Acid'],
        startedOn: now.subtract(const Duration(days: 60)),
        sortOrder: 10,
        catalogProductId: 'cat-cerave-cleanser',
        ingredientsRaw:
            'AQUA/WATER, GLYCERIN, CETEARYL ALCOHOL, PEG-40 STEARATE, '
            'STEARYL ALCOHOL, POTASSIUM PHOSPHATE, CERAMIDE NP, CERAMIDE AP, '
            'CERAMIDE EOP, CARBOMER, BEHENTRIMONIUM METHOSULFATE, '
            'SODIUM LAUROYL LACTYLATE, SODIUM HYALURONATE, CHOLESTEROL, '
            'PHENOXYETHANOL, DISODIUM EDTA, DIPOTASSIUM PHOSPHATE, '
            'TOCOPHEROL, PHYTOSPHINGOSINE, XANTHAN GUM, CETYL ALCOHOL, '
            'POLYSORBATE 20, ETHYLHEXYLGLYCERIN.',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      RoutineProduct(
        id: 'item-anua-toner',
        userId: userId,
        name: 'Heartleaf 77% Soothing Toner',
        brand: 'Anua',
        stepType: RoutineStepType.toner,
        actives: const ['Houttuynia Cordata 77%', 'Panthenol', 'Betaine'],
        startedOn: now.subtract(const Duration(days: 35)),
        sortOrder: 20,
        catalogProductId: 'cat-anua-toner',
        ingredientsRaw:
            'HOUTTUYNIA CORDATA EXTRACT (77%), WATER, 1,2-HEXANEDIOL, '
            'GLYCERIN, BETAINE, PANTHENOL, SACCHARUM OFFICINARUM EXTRACT, '
            'PORTULACA OLERACEA EXTRACT, BUTYLENE GLYCOL, VITEX AGNUS-CASTUS '
            'EXTRACT, CHAMOMILLA RECUTITA FLOWER EXTRACT, ACRYLATES/C10-30 '
            'ALKYL ACRYLATE CROSSPOLYMER, TROMETHAMINE, DISODIUM EDTA.',
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now,
      ),
      RoutineProduct(
        id: 'item-geek-vitc',
        userId: userId,
        name: 'C-Glow 15% Vitamin C Serum',
        brand: 'Geek & Gorgeous',
        stepType: RoutineStepType.serum,
        actives: const ['L-Ascorbic Acid 15%', 'Ferulic Acid', 'Tocopherol'],
        period: RoutinePeriod.am,
        startedOn: now.subtract(const Duration(days: 28)),
        sortOrder: 30,
        catalogProductId: 'cat-geek-vitc',
        ingredientsRaw:
            'WATER, ASCORBIC ACID, DIMETHYL ISOSORBIDE, BUTYLENE GLYCOL, '
            'PEG/PPG/POLYBUTYLENE GLYCOL-8/5/3 GLYCERIN, FERULIC ACID, '
            'TOCOPHEROL, PHENOXYETHANOL, ETHYLHEXYLGLYCERIN, '
            'SODIUM HYDROXIDE.',
        createdAt: now.subtract(const Duration(days: 28)),
        updatedAt: now,
      ),
      RoutineProduct(
        id: 'item-ordinary-retinol',
        userId: userId,
        name: 'Retinol 0.3% Emulsion',
        brand: 'The Ordinary',
        stepType: RoutineStepType.treatment,
        actives: const ['Retinol 0.3%', 'Squalane', 'Bisabolol'],
        period: RoutinePeriod.pm,
        days: const [1, 3, 5, 7],
        startedOn: now.subtract(const Duration(days: 42)),
        sortOrder: 40,
        catalogProductId: 'cat-ordinary-retinol',
        ingredientsRaw:
            'SQUALANE, CAPRYLIC/CAPRIC TRIGLYCERIDE, SIMMONDSIA CHINENSIS '
            '(JOJOBA) SEED OIL, RETINOL, SOLANUM LYCOPERSICUM (TOMATO) FRUIT '
            'EXTRACT, ROSMARINUS OFFICINALIS (ROSEMARY) LEAF EXTRACT, '
            'HYDROXYMETHOXYPHENYL DECANONE, BISABOLOL, BHT.',
        createdAt: now.subtract(const Duration(days: 42)),
        updatedAt: now,
      ),
      RoutineProduct(
        id: 'item-avene-barrier',
        userId: userId,
        name: 'Tolerance Control Soothing Recovery Cream',
        brand: 'Avène',
        stepType: RoutineStepType.moisturizer,
        actives: const ['D-Sensinose', 'Thermal Spring Water', 'Squalane'],
        startedOn: now.subtract(const Duration(days: 60)),
        sortOrder: 60,
        catalogProductId: 'cat-avene-barrier',
        ingredientsRaw:
            'AVENE THERMAL SPRING WATER, CAPRYLIC/CAPRIC TRIGLYCERIDE, '
            'ETHYLHEXYL PALMITATE, GLYCERIN, CETEARYL ALCOHOL, SQUALANE, '
            'CETEARYL GLUCOSIDE, CETYL ESTERS, AQUAPHILUS DOLOMIAE EXTRACT '
            'FILTRATE, ARGININE, BEESWAX, CITRIC ACID, TROMETHAMINE, WATER, '
            'XANTHAN GUM.',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      RoutineProduct(
        id: 'item-lrp-spf50',
        userId: userId,
        name: 'Anthelios UVMune 400 Invisible Fluid SPF 50+',
        brand: 'La Roche-Posay',
        stepType: RoutineStepType.spf,
        actives: const ['Mexoryl 400', 'Zinc Oxide', 'Tocopherol'],
        period: RoutinePeriod.am,
        startedOn: now.subtract(const Duration(days: 60)),
        sortOrder: 70,
        catalogProductId: 'cat-lrp-spf50',
        ingredientsRaw:
            'AQUA/WATER, ALCOHOL DENAT., TRIETHYL CITRATE, DIISOPROPYL '
            'SEBACATE, SILICA, ETHYLHEXYL SALICYLATE, BIS-ETHYLHEXYLOXYPHENOL '
            'METHOXYPHENYL TRIAZINE, ETHYLHEXYL TRIAZONE, BUTYL '
            'METHOXYDIBENZOYLMETHANE, GLYCERIN, PROPANEDIOL, '
            'METHOXYPROPYLAMINO CYCLOHEXENYLIDENE ETHOXYETHYLCYANOACETATE, '
            'TOCOPHEROL.',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
    ];
  }

  /// Builds today's initial `public.routine_logs` so the user immediately sees
  /// a partially completed morning routine and ready-to-log steps.
  static List<RoutineLogRecord> buildSeedLogsForDate({
    required String userId,
    required String logDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    return [
      RoutineLogRecord(
        id: 'log-$logDate-am-cleanser',
        userId: userId,
        itemId: 'item-cerave-cleanser',
        logDate: logDate,
        createdAt: now,
      ),
      RoutineLogRecord(
        id: 'log-$logDate-am-toner',
        userId: userId,
        itemId: 'item-anua-toner',
        logDate: logDate,
        createdAt: now,
      ),
      RoutineLogRecord(
        id: 'log-$logDate-am-vitc',
        userId: userId,
        itemId: 'item-geek-vitc',
        logDate: logDate,
        createdAt: now,
      ),
      RoutineLogRecord(
        id: 'log-$logDate-pm-cleanser',
        userId: userId,
        itemId: 'item-cerave-cleanser',
        logDate: logDate,
        period: RoutinePeriod.pm,
        createdAt: now,
      ),
    ];
  }

  /// Curated `public.catalog_products` aligned with the SQL schema:
  /// `category in ('cleanser','toner','serum','treatment','moisturizer','spf',`
  /// `'mask','other')`, `concerns` matching `public.concern_types.key`.
  static List<CatalogProduct> buildCatalogProducts() {
    return const [
      CatalogProduct(
        id: 'cat-cerave-cleanser',
        slug: 'cerave-hydrating-facial-cleanser',
        name: 'Hydrating Facial Cleanser',
        brand: 'CeraVe',
        category: RoutineStepType.cleanser,
        actives: ['Ceramides NP, AP, EOP', 'Hyaluronic Acid'],
        concerns: ['moisture', 'redness'],
        skinTypes: ['dry', 'normal', 'combination'],
        goodFor: 'Protecting barrier lipids while removing daily impurities.',
        skipIf: 'You wear heavy waterproof sunscreen without a first cleanse.',
        sortOrder: 10,
        retailers: [
          CatalogProductRetailer(
            name: 'Dermstore',
            url: 'https://www.dermstore.com',
          ),
        ],
        ingredientsRaw:
            'AQUA/WATER, GLYCERIN, CETEARYL ALCOHOL, CERAMIDE NP, '
            'CERAMIDE AP, CERAMIDE EOP, SODIUM HYALURONATE, CHOLESTEROL.',
      ),
      CatalogProduct(
        id: 'cat-anua-toner',
        slug: 'anua-heartleaf-77-soothing-toner',
        name: 'Heartleaf 77% Soothing Toner',
        brand: 'Anua',
        category: RoutineStepType.toner,
        actives: ['Houttuynia Cordata 77%', 'Panthenol', 'Betaine'],
        concerns: ['redness', 'moisture', 'pore'],
        skinTypes: ['oily', 'combination', 'normal', 'dry'],
        goodFor: 'Calming visible redness and prepping skin after cleansing.',
        skipIf: 'Known botanical allergy to Houttuynia Cordata.',
        sortOrder: 20,
        retailers: [
          CatalogProductRetailer(
            name: 'Olive Young',
            url: 'https://global.oliveyoung.com',
          ),
        ],
        ingredientsRaw:
            'HOUTTUYNIA CORDATA EXTRACT (77%), WATER, 1,2-HEXANEDIOL, '
            'GLYCERIN, BETAINE, PANTHENOL.',
      ),
      CatalogProduct(
        id: 'cat-geek-vitc',
        slug: 'geek-and-gorgeous-c-glow-15',
        name: 'C-Glow 15% Vitamin C Serum',
        brand: 'Geek & Gorgeous',
        category: RoutineStepType.serum,
        actives: ['L-Ascorbic Acid 15%', 'Ferulic Acid', 'Tocopherol'],
        concerns: ['age_spot', 'radiance', 'firmness'],
        skinTypes: ['normal', 'combination', 'oily'],
        goodFor: 'Fading dark spots and boosting morning UV defense.',
        skipIf: 'Skin barrier is compromised or highly reactive to low pH.',
        sortOrder: 30,
        retailers: [
          CatalogProductRetailer(
            name: 'Geek & Gorgeous',
            url: 'https://geekandgorgeous.com',
          ),
        ],
        ingredientsRaw:
            'WATER, ASCORBIC ACID, DIMETHYL ISOSORBIDE, FERULIC ACID, '
            'TOCOPHEROL.',
      ),
      CatalogProduct(
        id: 'cat-ordinary-retinol',
        slug: 'the-ordinary-retinol-03-emulsion',
        name: 'Retinol 0.3% Emulsion',
        brand: 'The Ordinary',
        category: RoutineStepType.treatment,
        actives: ['Retinol 0.3%', 'Squalane', 'Bisabolol'],
        concerns: ['age_spot', 'texture', 'wrinkle', 'pore'],
        skinTypes: ['combination', 'normal', 'oily'],
        goodFor: 'Evening cellular turnover for dark spots and smoother skin.',
        skipIf: 'Pregnant or nursing, or using prescription retinoids.',
        sortOrder: 40,
        retailers: [
          CatalogProductRetailer(
            name: 'DECIEM',
            url: 'https://theordinary.com',
          ),
        ],
        ingredientsRaw:
            'SQUALANE, CAPRYLIC/CAPRIC TRIGLYCERIDE, RETINOL, BISABOLOL.',
      ),
      CatalogProduct(
        id: 'cat-paulas-bha',
        slug: 'paulas-choice-2-percent-bha-liquid-exfoliant',
        name: 'Skin Perfecting 2% BHA Liquid Exfoliant',
        brand: "Paula's Choice",
        category: RoutineStepType.treatment,
        actives: ['Salicylic Acid 2%', 'Camellia Oleifera Extract'],
        concerns: ['pore', 'acne', 'texture', 'oiliness'],
        skinTypes: ['oily', 'combination'],
        goodFor: 'Decongesting pores and smoothing uneven texture 2–3x/week.',
        skipIf:
            'Allergic to salicylates (aspirin) or on the same night as '
            'Retinol.',
        sortOrder: 45,
        retailers: [
          CatalogProductRetailer(
            name: "Paula's Choice",
            url: 'https://www.paulaschoice.com',
          ),
        ],
        ingredientsRaw:
            'WATER, METHYLPROPANEDIOL, BUTYLENE GLYCOL, SALICYLIC ACID, '
            'POLYSORBATE 20, CAMELLIA OLEIFERA LEAF EXTRACT.',
      ),
      CatalogProduct(
        id: 'cat-ordinary-azelaic',
        slug: 'the-ordinary-azelaic-acid-10-suspension',
        name: 'Azelaic Acid Suspension 10%',
        brand: 'The Ordinary',
        category: RoutineStepType.treatment,
        actives: ['Azelaic Acid 10%', 'Tocopherol'],
        concerns: ['redness', 'age_spot', 'acne', 'texture'],
        skinTypes: ['oily', 'combination', 'normal', 'dry'],
        goodFor: 'Targeting redness and post-blemish marks gently.',
        skipIf: 'You prefer ultra-fluid water textures over matte creams.',
        sortOrder: 50,
        retailers: [
          CatalogProductRetailer(
            name: 'DECIEM',
            url: 'https://theordinary.com',
          ),
        ],
        ingredientsRaw:
            'AQUA, ISODECYL NEOPENTANOATE, DIMETHICONE, AZELAIC ACID, '
            'DIMETHICONE/BIS-ISOBUTYL PPG-20 CROSSPOLYMER, TOCOPHEROL.',
      ),
      CatalogProduct(
        id: 'cat-avene-barrier',
        slug: 'avene-tolerance-control-soothing-cream',
        name: 'Tolerance Control Soothing Recovery Cream',
        brand: 'Avène',
        category: RoutineStepType.moisturizer,
        actives: ['D-Sensinose', 'Thermal Spring Water', 'Squalane'],
        concerns: ['moisture', 'redness'],
        skinTypes: ['dry', 'normal', 'combination'],
        goodFor: 'Calming sensitized skin and buffering evening retinoids.',
        skipIf: 'Looking for an oil-free gel texture in humid climates.',
        sortOrder: 60,
        retailers: [
          CatalogProductRetailer(
            name: 'Avène',
            url: 'https://www.aveneusa.com',
          ),
        ],
        ingredientsRaw:
            'AVENE THERMAL SPRING WATER, CAPRYLIC/CAPRIC TRIGLYCERIDE, '
            'GLYCERIN, SQUALANE, AQUAPHILUS DOLOMIAE EXTRACT FILTRATE.',
      ),
      CatalogProduct(
        id: 'cat-lrp-spf50',
        slug: 'la-roche-posay-anthelios-uvmune-400-spf50',
        name: 'Anthelios UVMune 400 Invisible Fluid SPF 50+',
        brand: 'La Roche-Posay',
        category: RoutineStepType.spf,
        actives: ['Mexoryl 400', 'Zinc Oxide', 'Tocopherol'],
        concerns: ['age_spot', 'wrinkle', 'redness'],
        skinTypes: ['oily', 'combination', 'normal', 'dry'],
        goodFor: 'Ultra-long UVA protection without white cast.',
        skipIf: 'Sensitive to denatured alcohol in fluid sunscreens.',
        sortOrder: 70,
        retailers: [
          CatalogProductRetailer(
            name: 'La Roche-Posay',
            url: 'https://www.laroche-posay.us',
          ),
        ],
        ingredientsRaw:
            'AQUA/WATER, ALCOHOL DENAT., TRIETHYL CITRATE, SILICA, '
            'BIS-ETHYLHEXYLOXYPHENOL METHOXYPHENYL TRIAZINE, TOCOPHEROL.',
      ),
      CatalogProduct(
        id: 'cat-laneige-mask',
        slug: 'laneige-cica-sleeping-mask',
        name: 'Cica Sleeping Mask',
        brand: 'Laneige',
        category: RoutineStepType.mask,
        actives: ['Forest Yeast Extract', 'Panthenol', 'Shea Butter'],
        concerns: ['moisture', 'redness'],
        skinTypes: ['dry', 'normal', 'combination'],
        goodFor: 'Overnight barrier recovery on non-retinoid nights.',
        skipIf: 'Prone to fungal congestion from rich occlusive balms.',
        sortOrder: 80,
        retailers: [
          CatalogProductRetailer(
            name: 'Sephora',
            url: 'https://www.sephora.com',
          ),
        ],
        ingredientsRaw:
            'WATER, PROPANEDIOL, CETYL ETHYLHEXANOATE, SQUALANE, '
            'PANTHENOL, BUTYROSPERMUM PARKII BUTTER, AUREOBASIDIUM PULLULANS '
            'FERMENT.',
      ),
    ];
  }

  /// Default daily check-in (`public.checkins`) for [date].
  static SkinCheckin buildDefaultCheckin({
    required String userId,
    required String date,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    return SkinCheckin(
      id: 'checkin-$date',
      userId: userId,
      checkinDate: date,
      skinFeel: 3,
      note: 'Barrier feels calm; zero flaking after Retinol 0.3% last night.',
      createdAt: now,
    );
  }
}
