import 'package:flutter/material.dart';
import 'package:buzzer_app/core/responsive/app_spacing.dart';
import 'package:buzzer_app/core/widgets/views/state_views.dart';

/// Generic infinite-scroll paginated list view with:
/// - Pull-to-refresh
/// - Scroll threshold triggering next page fetch
/// - End-of-list loading indicator
/// - Empty state handling
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    super.key,
    this.onRefresh,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.emptyView,
    this.scrollThreshold = 200.0,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.separator,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool isLoadingMore;
  final bool hasMore;
  final Widget? emptyView;
  final double scrollThreshold;
  final EdgeInsets padding;
  final Widget? separator;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.scrollThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return widget.emptyView ?? const EmptyView();
    }

    Widget listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (index >= widget.items.length) return const SizedBox.shrink();
        return widget.separator ?? const SizedBox(height: AppSpacing.sm);
      },
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: widget.isLoadingMore
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}
