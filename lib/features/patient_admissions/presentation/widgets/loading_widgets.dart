import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LoadingWidgets {
  LoadingWidgets._(); // Private constructor to prevent instantiation

  /// Creates a skeleton loading widget with multiple placeholder cards
  /// Used during initial data loading to provide visual feedback
  static Widget buildSkeletonLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 3, // Show 3 skeleton items
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }

  /// Creates a pagination loading indicator
  /// Used at the bottom of lists during infinite scroll
  static Widget buildPaginationLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.loadingMore,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Creates an error state widget with retry functionality
  /// Used when API calls fail or network errors occur
  static Widget buildErrorState({
    required BuildContext context,
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                l10n.retry,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates an empty state widget with helpful guidance
  /// Used when no data is available to display
  static Widget buildEmptyState({
    required BuildContext context,
    required String message,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyStateGuidance,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual skeleton card widget
/// Mimics the actual patient card layout with shimmer effects
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient name and status row
            Row(
              children: [
                Expanded(
                  child: ShimmerContainer(height: 20, width: double.infinity),
                ),
                SizedBox(width: 12),
                ShimmerContainer(height: 24, width: 80),
              ],
            ),
            SizedBox(height: 8),
            // Patient ID
            ShimmerContainer(height: 16, width: 120),
            SizedBox(height: 16),
            // Patient details container
            _SkeletonDetailsContainer(),
            SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ShimmerContainer(height: 40, width: double.infinity),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerContainer(height: 40, width: double.infinity),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton details container mimicking patient information grid
class _SkeletonDetailsContainer extends StatelessWidget {
  const _SkeletonDetailsContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              children: [
                ShimmerContainer(height: 12, width: 60),
                SizedBox(height: 8),
                ShimmerContainer(height: 16, width: 80),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ShimmerContainer(height: 12, width: 60),
                SizedBox(height: 8),
                ShimmerContainer(height: 16, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer container with gradient effect
/// Creates a loading animation that mimics content placeholders
class ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerContainer({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
