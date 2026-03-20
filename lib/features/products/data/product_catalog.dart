import 'package:growingkids/features/products/domain/entities/product.dart';

abstract final class ProductCatalog {
  static const List<Product> items = [
    Product(
      id: 'green-gold-liquid',
      name: 'GreenGold dạng lỏng',
      subtitle: 'Đa dụng 500ml',
      priceLabel: '\$14.50',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREhM_TgK4EbEb7OksCE0QZXlUOlFSziYhKoQ&s',
      tag: 'NỔI BẬT',
      backgroundColorValue: 0xFFF1C40F,
      description:
          'Dung dịch dinh dưỡng cân bằng cho cây cảnh trong nhà, phù hợp lịch chăm định kỳ mỗi tuần.',
      highlights: [
        'Pha nhanh, dùng được cho cả tưới gốc và phun lá.',
        'Hỗ trợ ra lá non và giữ màu xanh ổn định.',
        'Hợp với người mới bắt đầu chăm cây tại nhà.',
      ],
    ),
    Product(
      id: 'premium-aroid-soil',
      name: 'Đất Aroid cao cấp',
      subtitle: 'Hỗn hợp hạt to 5L',
      priceLabel: '\$22.00',
      imageUrl:
          'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=400',
      backgroundColorValue: 0xFF2C3E50,
      description:
          'Giá thể thoáng khí cho Monstera, Philodendron và nhóm cây rễ khỏe cần độ thông thoáng cao.',
      highlights: [
        'Giữ ẩm vừa phải nhưng vẫn thoát nước tốt.',
        'Giảm nguy cơ úng rễ khi trồng trong nhà.',
        'Thích hợp thay chậu định kỳ cho cây lá kiểng.',
      ],
    ),
    Product(
      id: 'slow-release-sticks',
      name: 'Que tan chậm',
      subtitle: 'Gói 20 que',
      priceLabel: '\$9.00',
      imageUrl:
          'https://5.imimg.com/data5/SELLER/Default/2021/8/VU/HT/NV/116172416/stick-image1-blur-jpg.jpg',
      backgroundColorValue: 0xFF95A5A6,
      description:
          'Phân tan chậm dạng que giúp bổ sung dinh dưỡng lâu dài, tiện cho cây để bàn hoặc cây ban công.',
      highlights: [
        'Duy trì dinh dưỡng nhiều tuần sau mỗi lần cắm.',
        'Ít tốn công chăm hơn so với lịch bón lỏng thường xuyên.',
        'Dễ dùng cho chậu nhỏ và cây nội thất.',
      ],
    ),
    Product(
      id: 'pure-neem-oil',
      name: 'Tinh dầu neem nguyên chất',
      subtitle: 'Kiểm soát sâu bệnh 250ml',
      priceLabel: '\$16.50',
      imageUrl:
          'https://i5.walmartimages.com/seo/Majestic-Pure-Neem-Oil-100-Pure-Cold-Pressed-Great-For-Skin-Care-Hair-Care-Massage-Oil-Nails-Acne-Moisturizer-for-Dry-Skin-4-fl-oz_dc0577f3-a8f8-4ce3-8b4e-eed5d7310a54.4828ab425ff3c44d04eb55a28577e088.jpeg',
      backgroundColorValue: 0xFF27AE60,
      description:
          'Giải pháp kiểm soát rệp sáp, bọ trĩ và nấm nhẹ cho vườn tại nhà với lịch phun định kỳ linh hoạt.',
      highlights: [
        'Có thể kết hợp trong quy trình phòng bệnh hàng tuần.',
        'Phù hợp cây lá và cây gia vị trồng chậu.',
        'Dễ pha loãng theo nhiều tình huống chăm sóc khác nhau.',
      ],
    ),
  ];

  static Product? findById(String id) {
    for (final product in items) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }
}
