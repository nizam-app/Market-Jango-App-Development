// pretty_custom_search_bar.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/models/global_search_model.dart';

/// Generic: R = response type, T = item type
class GlobalSearchBar<R, T> extends ConsumerStatefulWidget {
  const GlobalSearchBar({
    super.key,
    required this.provider,                 // e.g. searchProvider(query)
    required this.itemsSelector,            // (R res) => List<T>
    required this.itemBuilder,              // (ctx, T item) => Widget
    this.onItemSelected,
    this.hintText = 'Search for products',
    this.debounce = const Duration(milliseconds: 350),
    this.minChars = 1,
    this.showResults = true,                // false => শুধু সার্চবার
    this.resultsMaxHeight = 380,
    this.autofocus = false,
  });

  final AutoDisposeFutureProviderFamily<R, String> provider;
  final List<T> Function(R response) itemsSelector;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T item)? onItemSelected;

  final String hintText;
  final Duration debounce;
  final int minChars;
  final bool showResults;
  final double resultsMaxHeight;
  final bool autofocus;

  @override
  ConsumerState<GlobalSearchBar<R, T>> createState() => _CustomSearchBarState<R, T>();
}

class _CustomSearchBarState<R, T> extends ConsumerState<GlobalSearchBar<R, T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  Timer? _debounce;
  String _query = '';

  // Overlay positioning
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  Size _fieldSize = Size.zero;

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () {
      setState(() => _query = v.trim());
      _rebuildOverlay(); // query বদলালে overlay subtree rebuild হবে
    });                                                                                               
  }

  void _openOverlay() {
    if (_entry != null) return;
    // NOTE: rootOverlay:false রাখছি যাতে ProviderScope-এর ভেতরে থাকে
    _entry = OverlayEntry(builder: _overlayBuilder);
    Overlay.of(context)!.insert(_entry!);
  }

  void _closeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _rebuildOverlay() {
    // _focus.hasFocus চেক বাদ — এটার জন্যই অনেক সময় লোডিং আটকে থাকত
    if (!widget.showResults || _query.length < widget.minChars) {
      _closeOverlay();
      return;
    }
    if (_entry == null) _openOverlay();
    _entry?.markNeedsBuild(); // নতুন query-র জন্য overlay উইজেট রিবিল্ড
  }

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      Future.microtask(() => _focus.requestFocus());
    }
    _focus.addListener(_rebuildOverlay);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.removeListener(_rebuildOverlay);
    _focus.dispose();
    _debounce?.cancel();
    _closeOverlay();
    super.dispose();
  }

  // Measure field size to set overlay width.
  void _updateFieldSize(BoxConstraints constraints) {
    final newSize = Size(constraints.maxWidth, 50.h);
    if (newSize != _fieldSize) {
      _fieldSize = newSize;
      _rebuildOverlay();
    }
  }

  Widget _overlayBuilder(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(children: [
          // tap outside to close
          GestureDetector(onTap: _closeOverlay, child: Container(color: Colors.transparent)),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: Offset(0, (50.h) + 8.h), 
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _fieldSize.width,
                  maxHeight: widget.resultsMaxHeight,
                ),
                child: _FloatingCard(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final asyncRes = ref.watch(widget.provider(_query));
                      return asyncRes.when(
                        loading: () => const LinearProgressIndicator(minHeight: 2),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Error: $e'),
                        ),
                        data: (res) {
                          final items = widget.itemsSelector(res);
                          if (items.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('No products found'),
                            );
                          }
                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, i) {
                              final it = items[i];
                              return InkWell(
                                onTap: () {
                                  widget.onItemSelected?.call(it);
                                  _closeOverlay();
                                  FocusScope.of(context).unfocus();
                                },
                                child: widget.itemBuilder(context, it),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // সুন্দর ইনপুট (আপনার স্টাইল রাখা হয়েছে)
    final input = Material(
      elevation: 1.2,
      borderRadius: BorderRadius.circular(50.r),
      clipBehavior: Clip.antiAlias,
      child: TextFormField(
        autofocus: widget.autofocus,
        focusNode: _focus,
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AllColor.hintTextColor, fontSize: 16.sp),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10.w, right: 4.w),
            child: const Icon(Icons.search),
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _controller.clear();
              setState(() => _query = '');
              _rebuildOverlay();
              _focus.requestFocus();
            },
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          border: InputBorder.none,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _updateFieldSize(constraints);
        return CompositedTransformTarget(
          link: _link,
          child: input,
        );
      },
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: .5, sigmaY: .5),
        child: Material(
          elevation: 8,
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }
}

/// সুন্দর product টাইল (আপনার SearchProduct মডেল)
class ProductSuggestionTile extends StatelessWidget {
  const ProductSuggestionTile({super.key, required this.p});
  final GlobalSearchProduct p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child:      FirstTimeShimmerImage(imageUrl: p.image,height: 56.h,width: 56.w,fit: BoxFit.cover,)
            // Image.network(
            //   p.image,
            //   width: 56.w,
            //   height: 56.w,
            //   fit: BoxFit.cover,
            // ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 2.h),
                Text(
                  p.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 6.h),
                _PriceRow(sell: p.sellPrice, regular: p.regularPrice),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.sell, required this.regular});
  final String sell;
  final String regular;

  @override
  Widget build(BuildContext context) {
    final bool hasRegular =
        regular.isNotEmpty && regular != '0' && regular != sell;

    return Row(
      children: [
        Text(
          '৳$sell',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasRegular) ...[
          SizedBox(width: 8.w),
          Text(
            '৳$regular',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}