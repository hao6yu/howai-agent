class LocationQueryInfo {
  final String category;
  final String query;
  final String originalText;

  LocationQueryInfo({
    required this.category,
    required this.query,
    required this.originalText,
  });
}

class LocationQueryDetector {
  static LocationQueryInfo? detect(String text) {
    final lowerText = text.toLowerCase();

    final isAnalysisRequest = lowerText.contains('suggest') &&
            (lowerText.contains('from the list') ||
                lowerText.contains('top ') ||
                lowerText.contains('best')) ||
        lowerText.contains('recommend') &&
            (lowerText.contains('from the list') ||
                lowerText.contains('top ') ||
                lowerText.contains('best')) ||
        lowerText.contains('explain why') ||
        lowerText.contains('analyze') ||
        lowerText.contains('compare') ||
        lowerText.contains('choose') ||
        lowerText.contains('pick');

    if (isAnalysisRequest) {
      return null;
    }

    final foodPatterns = [
      RegExp(r'附近.*?(餐厅|饭店|美食|吃饭|吃的|火锅|烧烤|日料|韩料|川菜|粤菜|湘菜|东北菜)',
          caseSensitive: false),
      RegExp(r'(哪里|哪儿).*?(好吃|美食|餐厅|饭店)', caseSensitive: false),
      RegExp(r'推荐.*?(餐厅|美食|吃饭|饭店)', caseSensitive: false),
      RegExp(r'(restaurants?|food|eating|dining).*?(near|nearby|around|close)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|close).*?(restaurants?|food|eating|dining)',
          caseSensitive: false),
      RegExp(r'(recommend|suggest|find).*?(restaurants?|food|places to eat)',
          caseSensitive: false),
      RegExp(r'(where.*?(eat|dine|food)|best.*?(restaurants?|food))',
          caseSensitive: false),
      RegExp(
          r'(good|best).*(pizza|burger|sushi|chinese|italian|mexican|thai|indian)',
          caseSensitive: false),
      RegExp(r'(restaurants?|food|places|dining).*?(in|at)\s+\w+',
          caseSensitive: false),
      RegExp(r'(any|find|looking for).*(restaurants?|food|places to eat)',
          caseSensitive: false),
      RegExp(
          r'(pizza|burger|sushi|chinese|italian|mexican|thai|indian|coffee).*?(in|at)\s+\w+',
          caseSensitive: false),
    ];

    final barPatterns = [
      RegExp(r'附近.*?(酒吧|夜店|清吧|夜生活|喝酒)', caseSensitive: false),
      RegExp(r'(哪里|哪儿).*?(喝酒|酒吧)', caseSensitive: false),
      RegExp(r'(bars?|nightlife|drinking|cocktails?).*?(near|nearby|around)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around).*?(bars?|nightlife|drinking)',
          caseSensitive: false),
      RegExp(r'(find|recommend).*(bars?|nightlife|drinks)',
          caseSensitive: false),
    ];

    final cafePatterns = [
      RegExp(r'(coffee|cafe|咖啡).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(coffee|cafe|咖啡)',
          caseSensitive: false),
      RegExp(r'(coffee|cafe|咖啡).*?(in|at)\s+\w+', caseSensitive: false),
      RegExp(r'(any|find|looking for).*?(coffee|cafe)', caseSensitive: false),
    ];

    final shoppingPatterns = [
      RegExp(r'(shopping|mall|store|商场|购物).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(shopping|mall|store|商场|购物)',
          caseSensitive: false),
    ];

    final dessertPatterns = [
      RegExp(
          r'(ice cream|gelato|dessert|sweet|bakery|cake|donut|甜品|冰淇淋|蛋糕|面包房).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(
          r'(near|nearby|around|附近).*?(ice cream|gelato|dessert|sweet|bakery|cake|donut|甜品|冰淇淋|蛋糕)',
          caseSensitive: false),
      RegExp(
          r'(find|looking for|any).*?(ice cream|gelato|dessert|sweet|bakery)',
          caseSensitive: false),
    ];

    final parkingPatterns = [
      RegExp(r'(parking|garage|park.*car|停车|停车场).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(parking|garage|停车)',
          caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(parking|garage|place to park)',
          caseSensitive: false),
    ];

    final restroomPatterns = [
      RegExp(
          r'(restroom|bathroom|toilet|washroom|wc|洗手间|厕所|卫生间).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(
          r'(near|nearby|around|附近).*?(restroom|bathroom|toilet|washroom|洗手间|厕所)',
          caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(restroom|bathroom|toilet|washroom)',
          caseSensitive: false),
    ];

    final beautyPatterns = [
      RegExp(
          r'(beauty|salon|spa|nail|hair|massage|美容|美发|按摩|指甲).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(
          r'(near|nearby|around|附近).*?(beauty|salon|spa|nail|hair|massage|美容|美发)',
          caseSensitive: false),
      RegExp(r'(find|looking for).*?(beauty|salon|spa|nail salon|hair salon)',
          caseSensitive: false),
    ];

    final pharmacyPatterns = [
      RegExp(
          r'(pharmacy|drugstore|medicine|药店|药房|医药).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(pharmacy|drugstore|medicine|药店|药房)',
          caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(pharmacy|drugstore|medicine)',
          caseSensitive: false),
    ];

    final atmPatterns = [
      RegExp(r'(atm|cash|withdraw|money|取款机|提款机|现金).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(atm|cash|withdraw|取款机)',
          caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(atm|cash machine|money)',
          caseSensitive: false),
    ];

    final laundryPatterns = [
      RegExp(r'(laundry|laundromat|dry.*clean|洗衣|干洗).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(r'(near|nearby|around|附近).*?(laundry|laundromat|dry.*clean|洗衣)',
          caseSensitive: false),
      RegExp(r'(find|looking for|need).*?(laundry|laundromat|dry cleaning)',
          caseSensitive: false),
    ];

    final attractionPatterns = [
      RegExp(
          r'(attractions?|tourist|sightseeing|景点|旅游|游玩).*?(near|nearby|around|附近)',
          caseSensitive: false),
      RegExp(
          r'(near|nearby|around|附近).*?(attractions?|tourist|sightseeing|景点|旅游)',
          caseSensitive: false),
    ];

    final generalLocationPatterns = [
      RegExp(
          r'(any|find|looking for|show me|list).*?(shops?|stores?|places?).*?(in|at)\s+\d{5}',
          caseSensitive: false),
      RegExp(
          r'(any|find|looking for|show me|list).*?(in|at)\s+\w+\s+(area|city|town|neighborhood)',
          caseSensitive: false),
      RegExp(r'\b\d{5}\b.*?(area|region|zip|code)', caseSensitive: false),
    ];

    for (final pattern in foodPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'restaurant',
          query: _extractFoodQuery(text),
          originalText: text,
        );
      }
    }

    for (final pattern in barPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
          category: 'night_club',
          query: _extractBarQuery(text),
          originalText: text,
        );
      }
    }

    for (final pattern in cafePatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'cafe', query: 'coffee shops', originalText: text);
      }
    }

    for (final pattern in shoppingPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'shopping_mall', query: 'shopping', originalText: text);
      }
    }

    for (final pattern in attractionPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'tourist_attraction',
            query: 'attractions',
            originalText: text);
      }
    }

    for (final pattern in dessertPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'convenience_store',
            query: 'ice cream desserts',
            originalText: text);
      }
    }

    for (final pattern in parkingPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'parking', query: 'parking garage', originalText: text);
      }
    }

    for (final pattern in restroomPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'restroom', query: 'public restroom', originalText: text);
      }
    }

    for (final pattern in beautyPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'beauty_salon',
            query: 'beauty spa salon',
            originalText: text);
      }
    }

    for (final pattern in pharmacyPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'pharmacy',
            query: 'pharmacy drugstore',
            originalText: text);
      }
    }

    for (final pattern in atmPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'atm', query: 'atm cash machine', originalText: text);
      }
    }

    for (final pattern in laundryPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return LocationQueryInfo(
            category: 'laundry',
            query: 'laundromat dry cleaning',
            originalText: text);
      }
    }

    for (final pattern in generalLocationPatterns) {
      if (pattern.hasMatch(lowerText)) {
        String category = 'restaurant';
        String query = text;

        if (lowerText.contains('coffee') || lowerText.contains('cafe')) {
          category = 'cafe';
          query = 'coffee shops';
        } else if (lowerText.contains('shop') || lowerText.contains('store')) {
          category = 'shopping_mall';
          query = 'shops';
        } else if (lowerText.contains('restaurant') ||
            lowerText.contains('food')) {
          category = 'restaurant';
          query = 'restaurants';
        } else if (lowerText.contains('bar') || lowerText.contains('drink')) {
          category = 'night_club';
          query = 'bars';
        } else if (lowerText.contains('ice cream') ||
            lowerText.contains('dessert')) {
          category = 'convenience_store';
          query = 'ice cream desserts';
        } else if (lowerText.contains('parking') ||
            lowerText.contains('garage')) {
          category = 'parking';
          query = 'parking garage';
        } else if (lowerText.contains('restroom') ||
            lowerText.contains('bathroom')) {
          category = 'restroom';
          query = 'public restroom';
        }

        return LocationQueryInfo(
            category: category, query: query, originalText: text);
      }
    }

    return null;
  }

  static String _extractFoodQuery(String text) {
    final lowerText = text.toLowerCase();

    final foodKeywords = {
      'pizza': 'pizza places',
      'burger': 'burger joints',
      'sushi': 'sushi restaurants',
      'chinese': 'chinese restaurants',
      'italian': 'italian restaurants',
      'mexican': 'mexican restaurants',
      'thai': 'thai restaurants',
      'indian': 'indian restaurants',
      'korean': 'korean restaurants',
      'japanese': 'japanese restaurants',
      'vietnamese': 'vietnamese restaurants',
      'seafood': 'seafood restaurants',
      'steakhouse': 'steakhouses',
      'bbq': 'bbq restaurants',
      'breakfast': 'breakfast places',
      'lunch': 'lunch spots',
      'dinner': 'dinner restaurants',
      '火锅': 'hot pot restaurants',
      '烧烤': 'bbq restaurants',
      '日料': 'japanese restaurants',
      '韩料': 'korean restaurants',
      '川菜': 'sichuan restaurants',
      '粤菜': 'cantonese restaurants',
      '湘菜': 'hunan restaurants',
      '东北菜': 'northeastern chinese restaurants',
    };

    for (final keyword in foodKeywords.keys) {
      if (lowerText.contains(keyword)) {
        return foodKeywords[keyword]!;
      }
    }

    return 'restaurants';
  }

  static String _extractBarQuery(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('cocktail')) return 'cocktail bars';
    if (lowerText.contains('wine')) return 'wine bars';
    if (lowerText.contains('beer')) return 'beer bars';
    if (lowerText.contains('rooftop')) return 'rooftop bars';
    if (lowerText.contains('sports')) return 'sports bars';

    return 'bars';
  }
}
