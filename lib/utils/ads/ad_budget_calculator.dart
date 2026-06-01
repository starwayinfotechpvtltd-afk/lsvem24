/// Client-side mirror of backend/util/adBudgetCalculator.js (offline fallback).

class AdBudgetBreakdown {
  final int sizeCost;
  final int durationCost;
  final int budget;

  const AdBudgetBreakdown({
    required this.sizeCost,
    required this.durationCost,
    required this.budget,
  });
}

class AdBudgetCalculator {
  static AdBudgetBreakdown calculate({
    required double fileSizeMB,
    required int durationSeconds,
    required String adType,
    required String placement,
    required String mediaType,
  }) {
    final sizeMB = fileSizeMB < 0 ? 0 : fileSizeMB;
    final durationSec = durationSeconds < 0 ? 0 : durationSeconds;
    final type = adType.toLowerCase();
    final place = placement.toLowerCase();
    final isVideo = mediaType.toLowerCase() == 'video';

    final sizeCost = (sizeMB * 10).ceil();
    final durationCost = isVideo && durationSec > 0
        ? ((durationSec / 10).ceil() * 2)
        : isVideo
            ? 0
            : 5;

    var budget = (sizeCost + durationCost).toDouble();

    switch (type) {
      case 'non-skippable':
        budget *= 2;
        break;
      case 'skippable':
        budget *= 1.5;
        break;
      case 'overlay':
        budget *= 0.8;
        break;
      case 'banner':
        budget *= 0.5;
        break;
    }

final normalizedPlacement =
    ['pre-roll', 'mid-roll', 'both'].contains(place)
        ? place
        : 'pre-roll';
        
    switch (normalizedPlacement) {
      case 'mid-roll':
        budget *= 1.2;
        break;
      case 'both':
        budget *= 1.5;
        break;
    }

    final total = budget.ceil() < 1 ? 1 : budget.ceil();
    return AdBudgetBreakdown(
      sizeCost: sizeCost,
      durationCost: durationCost,
      budget: total,
    );
  }
}
