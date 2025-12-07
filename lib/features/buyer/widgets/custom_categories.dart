import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/features/buyer/data/buyer_categori_data.dart';
import 'package:market_jango/features/buyer/model/buyer_category_model.dart';

class CustomCategories extends ConsumerWidget {
  const CustomCategories({
    super.key,
    required this.categoriCount,
    required this.onTapCategory,
    this.physics,
  });

  final int categoriCount;
  final void Function(CategoryItem category) onTapCategory;
  final ScrollPhysics? physics;

  static const _placeholder =
      'https://via.placeholder.com/300x300.png?text=Category';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCats = ref.watch(categoriesProvider);

    return asyncCats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (resp) {
        if (resp == null) return const SizedBox.shrink();

        final page = resp.data;
        final all = page.data; // List<CategoryItem>

        // হোমে ৪টা, অল স্ক্রিনে যত আছে সব
        final items = all.take(categoriCount).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.80,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final cat = items[index];
            final thumbs = _thumbsFor(cat);

            return InkWell(
              onTap: () => onTapCategory(cat),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [
                    BoxShadow(blurRadius: 5, color: Colors.black12),
                  ],
                ),
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2x2 থাম্বনেইল গ্রিড
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4.h,
                          crossAxisSpacing: 4.w,
                        ),
                        itemBuilder: (context, i) {
                          final url = thumbs[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ক্যাটাগরি থেকে ৪টা থাম্বনেইল বের করি:
  /// 1) প্রোডাক্টের `image`
  /// 2) না থাকলে প্রোডাক্ট.images[0].image_path
  /// 3) কম হলে placeholder দিয়ে ফিল করি
  List<String> _thumbsFor(CategoryItem cat) {
    final List<String> urls = [];
    for (final p in cat.products) {
      if (p.image.isNotEmpty) {
        urls.add(p.image);
      } else if (p.images.isNotEmpty && p.images.first.imagePath.isNotEmpty) {
        urls.add(p.images.first.imagePath);
      }
      if (urls.length >= 4) break;
    }
    while (urls.length < 4) {
      urls.add(_placeholder);
    }
    return urls.take(4).toList();
  }
}
