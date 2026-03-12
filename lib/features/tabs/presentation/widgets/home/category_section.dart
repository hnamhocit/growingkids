import 'package:flutter/material.dart';

final categories = [
  {
    'name': 'Liquids',
    'img': 'https://images.unsplash.com/photo-1629198688000-71f23e745b6e?w=200',
  },
  {
    'name': 'Soil Mixes',
    'img':
        'https://bizweb.dktcdn.net/100/340/551/products/untitled-jpeg-e11dbed0-94b2-42c2-a715-19449d1871a7.jpg?v=1726831504500',
  },
  {
    'name': 'Biology Plant Pot',
    'img':
        'https://www.forestrytools.com.au/cdn/shop/products/Bio-Pots-8cm-12-Pack_1024x.jpg?v=1678410099',
  },
];

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'See all',
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(categories[index]['img']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index]['name']!,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
