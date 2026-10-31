import 'package:equatable/equatable.dart';

/// Retailer purchase link inside `public.catalog_products.retailers` JSONB.
class CatalogProductRetailer extends Equatable {
  /// Creates a [CatalogProductRetailer].
  const CatalogProductRetailer({
    required this.name,
    required this.url,
    this.affiliate = true,
  });

  /// Retailer display name.
  final String name;

  /// Product purchase URL.
  final String url;

  /// Whether this is an affiliate partner link.
  final bool affiliate;

  @override
  List<Object?> get props => [name, url, affiliate];
}

/// Pure domain entity mirroring `public.catalog_products` from the Supabase
/// migration (`20261012000000_skinproof_init.sql`).
class CatalogProduct extends Equatable {
  /// Creates a [CatalogProduct].
  const CatalogProduct({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    this.brand,
    this.actives = const [],
    this.concerns = const [],
    this.skinTypes = const [],
    this.goodFor,
    this.skipIf,
    this.imageUrl,
    this.retailers = const [],
    this.active = true,
    this.sortOrder = 100,
    this.ingredientsRaw,
  });

  /// Unique UUID.
  final String id;

  /// Unique URL-safe slug.
  final String slug;

  /// Product display name.
  final String name;

  /// Brand name.
  final String? brand;

  /// Category: `cleanser`, `toner`, `serum`, `treatment`, `moisturizer`,
  /// `spf`, `mask`, `other`.
  final String category;

  /// Active ingredients keys (e.g. `['retinol', 'niacinamide']`).
  final List<String> actives;

  /// Targeted concern keys matching `public.concern_types.key`.
  final List<String> concerns;

  /// Compatible skin types (`['oily','dry','combination','normal']`).
  final List<String> skinTypes;

  /// Editorial note explaining who this product is best suited for.
  final String? goodFor;

  /// Editorial caution explaining when to skip this product.
  final String? skipIf;

  /// Optional image URL.
  final String? imageUrl;

  /// List of retailers offering the product.
  final List<CatalogProductRetailer> retailers;

  /// Whether active in catalog.
  final bool active;

  /// Sort order in catalog.
  final int sortOrder;

  /// Full INCI ingredient list for instant inspection.
  final String? ingredientsRaw;

  @override
  List<Object?> get props => [
    id,
    slug,
    name,
    brand,
    category,
    actives,
    concerns,
    skinTypes,
    goodFor,
    skipIf,
    imageUrl,
    retailers,
    active,
    sortOrder,
    ingredientsRaw,
  ];
}
