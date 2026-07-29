import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shows a full-screen interactive lightbox for an image with zoom & pan support.
void showImageLightbox(
  BuildContext context, {
  required String title,
  String? imageSource,
  Uint8List? imageBytes,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header with title and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.image_outlined, color: Color(0xFF14B8A6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Image viewer area with zoom/pan
            Flexible(
              child: Container(
                color: const Color(0xFF030712),
                constraints: const BoxConstraints(maxHeight: 600),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: AppImagePreview(
                      imageSource: imageSource,
                      imageBytes: imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Footer text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                imageSource ?? 'Image Preview',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Flexible Image Preview Widget that resolves local file paths, memory bytes,
/// network URLs, base64 data URIs, or renders a fallback graphic for filename strings.
class AppImagePreview extends StatelessWidget {
  const AppImagePreview({
    super.key,
    this.imageSource,
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? imageSource;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageWidget(context);

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: imageWidget,
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    // 1. Direct memory bytes provided
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallbackGraphic(context),
      );
    }

    final String? src = imageSource?.trim();
    if (src == null || src.isEmpty) {
      return _buildFallbackGraphic(context, label: 'No image');
    }

    // 2. HTTP / HTTPS Network URL
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF1F2937),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF14B8A6), strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackGraphic(context, label: src),
      );
    }

    // 3. Base64 Data URI
    if (src.startsWith('data:image')) {
      try {
        final commaIdx = src.indexOf(',');
        final base64Str = commaIdx != -1 ? src.substring(commaIdx + 1) : src;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallbackGraphic(context, label: 'Base64 Image'),
        );
      } catch (_) {
        return _buildFallbackGraphic(context, label: 'Invalid Data URI');
      }
    }

    // 4. Local File Path (non-web)
    if (!kIsWeb && File(src).existsSync()) {
      return Image.file(
        File(src),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallbackGraphic(context, label: src),
      );
    }

    // 5. Raw filename string or non-existent file path: render simulated preview card graphic
    return _buildFallbackGraphic(context, label: src);
  }

  Widget _buildFallbackGraphic(BuildContext context, {String? label}) {
    final String textLabel = label ?? imageSource ?? 'Preview';
    final String extension = textLabel.contains('.') ? textLabel.split('.').last.toUpperCase() : 'IMG';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background decorative design elements
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.image,
              size: 80,
              color: const Color(0xFF14B8A6).withValues(alpha: 0.08),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            main: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.collections_outlined,
                  color: Color(0xFF14B8A6),
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  extension.length <= 4 ? extension : 'FILE',
                  style: const TextStyle(
                    color: Color(0xFF14B8A6),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  textLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card widget to display an image preview with title, thumbnail, and click-to-enlarge lightbox dialog.
class AppImagePreviewCard extends StatelessWidget {
  const AppImagePreviewCard({
    super.key,
    required this.title,
    this.imageSource,
    this.imageBytes,
    this.width = 200,
    this.height = 170,
  });

  final String title;
  final String? imageSource;
  final Uint8List? imageBytes;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = (imageSource != null && imageSource!.trim().isNotEmpty) || (imageBytes != null && imageBytes!.isNotEmpty);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? const Color(0xFF14B8A6).withValues(alpha: 0.3) : const Color(0xFF1F2937),
          width: 1.5,
        ),
        boxShadow: hasImage
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                Icon(
                  hasImage ? Icons.image : Icons.image_not_supported_outlined,
                  size: 16,
                  color: hasImage ? const Color(0xFF14B8A6) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: hasImage ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasImage)
                  InkWell(
                    onTap: () => showImageLightbox(context, title: title, imageSource: imageSource, imageBytes: imageBytes),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.fullscreen, color: Color(0xFF14B8A6), size: 14),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1F2937)),
          // Thumbnail Preview Body
          Expanded(
            child: InkWell(
              onTap: hasImage ? () => showImageLightbox(context, title: title, imageSource: imageSource, imageBytes: imageBytes) : null,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: AppImagePreview(
                        imageSource: imageSource,
                        imageBytes: imageBytes,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (hasImage)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.zoom_in, color: Color(0xFF14B8A6), size: 12),
                              SizedBox(width: 4),
                              Text('Preview', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An interactive file/image upload card widget for forms, displaying real-time image preview thumbnails.
class AppImageUploadCard extends StatelessWidget {
  const AppImageUploadCard({
    super.key,
    required this.label,
    required this.imageSource,
    this.imageBytes,
    required this.onPickImage,
    this.onClearImage,
  });

  final String label;
  final String? imageSource;
  final Uint8List? imageBytes;
  final VoidCallback onPickImage;
  final VoidCallback? onClearImage;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = (imageSource != null && imageSource!.trim().isNotEmpty) || (imageBytes != null && imageBytes!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? const Color(0xFF14B8A6).withValues(alpha: 0.4) : const Color(0xFF1F2937),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.collections_outlined, color: Color(0xFF14B8A6), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (hasImage && onClearImage != null)
                IconButton(
                  onPressed: onClearImage,
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFCA5A5), size: 20),
                  tooltip: 'Clear image',
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasImage) ...<Widget>[
            // Image preview thumbnail box
            InkWell(
              onTap: () => showImageLightbox(context, title: label, imageSource: imageSource, imageBytes: imageBytes),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: AppImagePreview(
                          imageSource: imageSource,
                          imageBytes: imageBytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.zoom_in, color: Color(0xFF14B8A6), size: 14),
                              SizedBox(width: 4),
                              Text('Tap to Enlarge', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    imageSource ?? 'Selected Image',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onPickImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF14B8A6)),
                    foregroundColor: const Color(0xFF14B8A6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Change'),
                ),
              ],
            ),
          ] else ...<Widget>[
            // Upload button area when no image selected
            InkWell(
              onTap: onPickImage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF374151), style: BorderStyle.solid),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF14B8A6), size: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Click to select or upload image',
                      style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PNG, JPG, JPEG, WEBP files supported',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
