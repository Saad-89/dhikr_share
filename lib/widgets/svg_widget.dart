import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SafeSvgWidget extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final Widget? fallbackWidget;
  final IconData? fallbackIcon;
  final VoidCallback? onError;
  final bool showErrorDetails;

  const SafeSvgWidget({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.fallbackWidget,
    this.fallbackIcon,
    this.onError,
    this.showErrorDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadSvg(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          if (showErrorDetails) {
            debugPrint('SVG Loading Error: ${snapshot.error}');
          }
          onError?.call();
          return _buildErrorWidget(snapshot.error);
        }

        return snapshot.data ?? _buildErrorWidget(null);
      },
    );
  }

  Future<Widget> _loadSvg(BuildContext context) async {
    try {
      // Pre-load the SVG to catch any parsing errors
      await DefaultAssetBundle.of(context).loadString(assetPath);

      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
        placeholderBuilder: (context) => _buildLoadingWidget(),
      );
    } catch (e) {
      throw e;
    }
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      width: width ?? 50,
      height: height ?? 50,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    // Use custom fallback widget if provided
    if (fallbackWidget != null) {
      return fallbackWidget!;
    }

    // Use fallback icon if provided
    if (fallbackIcon != null) {
      return Icon(
        fallbackIcon,
        size: width ?? height ?? 24,
        color: color ?? Colors.grey,
      );
    }

    // Default error widget
    return Container(
      width: width ?? 50,
      height: height ?? 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: (width ?? height ?? 50) * 0.4,
            color: Colors.grey,
          ),
          if (showErrorDetails && error != null) ...[
            const SizedBox(height: 4),
            Text(
              'SVG Error',
              style: TextStyle(fontSize: 8, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

// Alternative simplified version for quick usage
class SimpleSafeSvg extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;

  const SimpleSafeSvg({
    Key? key,
    required this.assetPath,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeSvgWidget(
      assetPath: assetPath,
      width: size,
      height: size,
      color: color,
      fallbackIcon: Icons.image,
      showErrorDetails: true,
    );
  }
}

// Usage examples widget
class SvgExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SVG Widget Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Usage:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SafeSvgWidget(
              assetPath: 'assets/svgs/welcome.svg',
              width: 100,
              height: 100,
            ),

            const SizedBox(height: 24),
            Text(
              'With Custom Fallback:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SafeSvgWidget(
              assetPath: 'assets/svgs/welcome.svg',
              width: 100,
              height: 100,
              fallbackIcon: Icons.home,
              color: Colors.blue,
              onError: () => print('SVG failed to load'),
            ),

            const SizedBox(height: 24),
            Text(
              'With Custom Error Widget:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SafeSvgWidget(
              assetPath: 'assets/svgs/welcome.svg',
              width: 100,
              height: 100,
              fallbackWidget: Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: Center(child: Text('No Image')),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Simple Version:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SimpleSafeSvg(
              assetPath: 'assets/svgs/welcome.svg',
              size: 80,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
