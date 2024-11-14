class ProductDetails {
  final String ean;
  final String title;
  final String description;
  final String upc;
  final String brand;
  final String model;
  final String color;
  final String size;
  final String dimension;
  final String weight;
  final String category;
  final String currency;
  final double lowestRecordedPrice;
  final double highestRecordedPrice;
  final List<String> images;
  final List<Offer> offers;
  final String asin;
  final String elid;

  ProductDetails({
    required this.ean,
    required this.title,
    required this.description,
    required this.upc,
    required this.brand,
    required this.model,
    required this.color,
    required this.size,
    required this.dimension,
    required this.weight,
    required this.category,
    required this.currency,
    required this.lowestRecordedPrice,
    required this.highestRecordedPrice,
    required this.images,
    required this.offers,
    required this.asin,
    required this.elid,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      ean: json['ean'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      upc: json['upc'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      dimension: json['dimension'] ?? '',
      weight: json['weight'] ?? '',
      category: json['category'] ?? '',
      currency: json['currency'] ?? '',
      lowestRecordedPrice: (json['lowest_recorded_price'] as num?)?.toDouble() ?? 0.0,
      highestRecordedPrice: (json['highest_recorded_price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      offers: (json['offers'] as List<dynamic>?)
          ?.map((offer) => Offer.fromJson(offer))
          .toList() ?? [],
      asin: json['asin'] ?? '',
      elid: json['elid'] ?? '',
    );
  }

  @override
  String toString() {
    return '''
    ProductDetails {
      ean: $ean,
      title: $title,
      description: $description,
      upc: $upc,
      brand: $brand,
      model: $model,
      color: $color,
      size: $size,
      dimension: $dimension,
      weight: $weight,
      category: $category,
      currency: $currency,
      lowestRecordedPrice: $lowestRecordedPrice,
      highestRecordedPrice: $highestRecordedPrice,
      images: $images,
      offers: $offers,
      asin: $asin,
      elid: $elid
    }
    ''';
  }
}

class Offer {
  final String merchant;
  final String domain;
  final String title;
  final String currency;
  final dynamic listPrice;
  final dynamic price;
  final String shipping;
  final String condition;
  final String availability;
  final String link;
  final int updatedT;

  Offer({
    required this.merchant,
    required this.domain,
    required this.title,
    required this.currency,
    required this.listPrice,
    required this.price,
    required this.shipping,
    required this.condition,
    required this.availability,
    required this.link,
    required this.updatedT,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      merchant: json['merchant'] ?? '',
      domain: json['domain'] ?? '',
      title: json['title'] ?? '',
      currency: json['currency'] ?? '',
      listPrice: json['list_price'] ?? '',
      price: json['price'] ?? 0,
      shipping: json['shipping'] ?? '',
      condition: json['condition'] ?? '',
      availability: json['availability'] ?? '',
      link: json['link'] ?? '',
      updatedT: json['updated_t'] ?? 0,
    );
  }

  @override
  String toString() {
    return '''
    Offer {
      merchant: $merchant,
      domain: $domain,
      title: $title,
      currency: $currency,
      listPrice: $listPrice,
      price: $price,
      shipping: $shipping,
      condition: $condition,
      availability: $availability,
      link: $link,
      updatedT: $updatedT
    }
    ''';
  }
}