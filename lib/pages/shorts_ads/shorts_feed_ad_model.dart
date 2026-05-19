class ShortsFeedAd {
  ShortsFeedAd({
    this.id,
    this.title,
    this.description,
    this.video,
    this.image,
    this.ctaText,
    this.ctaLink,
    this.type,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? video;
  final String? image;
  final String? ctaText;
  final String? ctaLink;
  final String? type;

  bool get hasVideo => video != null && video!.trim().isNotEmpty;
  bool get hasImage => image != null && image!.trim().isNotEmpty;

  /// Prefer video when both exist (matches upload flow).
  bool get isVideoAd => hasVideo;

  factory ShortsFeedAd.fromJson(Map<String, dynamic> json) {
    return ShortsFeedAd(
      id: json['_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      video: json['video']?.toString(),
      image: json['image']?.toString(),
      ctaText: json['ctaText']?.toString(),
      ctaLink: json['ctaLink']?.toString(),
      type: json['type']?.toString(),
    );
  }
}

/// Marker inserted into shorts feeds between video items.
class ShortsFeedAdSlot {
  const ShortsFeedAdSlot(this.ad);

  final ShortsFeedAd ad;
}
