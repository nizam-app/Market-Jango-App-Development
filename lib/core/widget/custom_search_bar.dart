import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_serach_riverpod.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  const CustomSearchBar({super.key});

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String query = '';

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => query = value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search for products',
            hintStyle:
            TextStyle(color: AllColor.hintTextColor, fontSize: 16.sp),
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        if (query.isNotEmpty)
          searchAsync.when(
            data: (response) {
              if (response.products.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(12.h),
                  child: const Text('No products found'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: response.products.length,
                itemBuilder: (context, index) {
                  final p = response.products[index];
                  return ListTile(
                    leading: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: NetworkImage(p.image),
                          fit: BoxFit.cover,
                        ),
                      )),
                    title: Text(p.name),
                    subtitle: Text(p.description,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      // উদাহরণ: প্রোডাক্ট ডিটেইলে যাও
                      // context.push('/product/${p.id}');
                    },
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
      ],
    );
  }
}