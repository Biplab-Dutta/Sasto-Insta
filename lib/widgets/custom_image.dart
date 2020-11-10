import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_network/widgets/progress.dart';

CachedNetworkImage cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => circularProgress(),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
