class LongVideoAd {
  LongVideoAd({
    this.id,
    this.title,
    this.description,
    this.video,
    this.image,
    this.ctaText,
    this.ctaLink,
    this.type,
    this.placement,
    this.skipAfter,
    this.duration,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? video;
  final String? image;
  final String? ctaText;
  final String? ctaLink;
  final String? type;
  final String? placement;
  final int? skipAfter;
  final int? duration;

  bool get hasVideo => video != null && video!.trim().isNotEmpty;
  bool get hasImage => image != null && image!.trim().isNotEmpty;
  bool get isVideoAd => hasVideo;

  String get normalizedType =>
      (type ?? 'skippable').toLowerCase().trim().replaceAll('_', '-');

  bool get isSkippable => normalizedType == 'skippable';

  bool get isNonSkippable =>
      normalizedType == 'non-skippable' || normalizedType == 'non skippable';

  bool get isBanner => normalizedType == 'banner';

  bool get isOverlay => normalizedType == 'overlay';

  /// Full-screen ads that pause the main video (pre-roll / mid-roll).
  bool get isInterruptType => isSkippable || isNonSkippable;

  bool get supportsPreRoll {
    final p = placement?.toLowerCase() ?? 'pre-roll';
    return p == 'pre-roll' || p == 'both';
  }

  bool get supportsMidRoll {
    final p = placement?.toLowerCase() ?? 'pre-roll';
    return p == 'mid-roll' || p == 'both';
  }

  int get skipAfterSeconds {
    final v = skipAfter ?? 5;
    return v < 0 ? 0 : v;
  }

  int get displayDurationSeconds {
    final v = duration ?? 30;
    return v > 0 ? v : 30;
  }

  factory LongVideoAd.fromJson(Map<String, dynamic> json) {
    return LongVideoAd(
      id: json['_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      video: json['video']?.toString(),
      image: json['image']?.toString(),
      ctaText: json['ctaText']?.toString(),
      ctaLink: json['ctaLink']?.toString(),
      type: json['type']?.toString(),
      placement: json['placement']?.toString(),
      skipAfter: _parseInt(json['skipAfter']),
      duration: _parseInt(json['duration']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
