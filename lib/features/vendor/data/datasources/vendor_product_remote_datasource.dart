import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/data/models/explore_category_model.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_product.dart';
import '../../domain/entities/vendor_product_edit.dart';
import '../../domain/entities/vendor_product_page.dart';
import '../../domain/entities/vendor_product_query.dart';
import '../models/vendor_product_model.dart';

/// What the seven vendor product endpoints answer.
abstract interface class VendorProductRemoteDataSource {
  /// `GET /vendor/product-categories` — [query] is matched against the name.
  Future<List<ExploreCategory>> categories({
    required String locale,
    String? query,
  });

  /// `GET /vendor/products`
  Future<VendorProductPage> products(VendorProductQuery query);

  /// `POST /vendor/products` — the new product waits for an admin.
  Future<VendorProduct> add({
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  });

  /// `PUT /vendor/products/{id}`
  Future<VendorProduct> update({
    required int id,
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  });

  /// `DELETE /vendor/products/{id}`
  Future<void> remove({required int id, required String locale});
}

/// Remote data source backed by the Dali Alsham vendor product endpoints.
///
/// All seven are authenticated and scoped to the signed-in vendor's own
/// service; the shared Dio carries the bearer token through `AuthInterceptor`.
class DalilVendorProductRemoteDataSource
    implements VendorProductRemoteDataSource {
  DalilVendorProductRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<ExploreCategory>> categories({
    required String locale,
    String? query,
  }) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorProductCategoriesPath,
        queryParameters: _categoriesQuery(locale, query),
      ),
    );
    final data = body?['data'];
    if (data == null) return const [];
    if (data is! List) {
      throw const ParseException('Product category reply carried no list');
    }
    try {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ExploreCategoryModel.fromJson)
          .toList();
    } on FormatException {
      throw const ParseException(
        'Product category reply carried an unusable entry',
      );
    }
  }

  @override
  Future<VendorProductPage> products(VendorProductQuery query) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorProductsPath,
        queryParameters: _productsQuery(query),
      ),
    );
    final data = body?['data'];
    if (data is! List) {
      throw const ParseException('Product list reply carried no rows');
    }
    final pagination = body?['pagination'];

    return VendorProductPage(
      products: _rows(data),
      hasMore: pagination is Map<String, dynamic>
          ? pagination['has_more'] == true
          : false,
      nextPage: pagination is Map<String, dynamic>
          ? (pagination['next_page'] as num?)?.toInt()
          : null,
      count: (body?['count'] as num?)?.toInt(),
    );
  }

  /// A row the vendor cannot show — no id, no name — fails the page rather
  /// than rendering a blank line, the same way a rejected write does.
  static List<VendorProduct> _rows(List<Object?> data) {
    try {
      return [
        for (final row in data.whereType<Map<String, dynamic>>())
          VendorProductModel.fromJson(row),
      ];
    } on FormatException {
      throw const ParseException('Product list reply carried an unusable row');
    }
  }

  @override
  Future<VendorProduct> add({
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  }) => _written(
    () => _dio.post<dynamic>(
      ApiConstants.vendorProductsPath,
      data: _fields(edit, image),
      queryParameters: <String, String>{'locale': locale},
    ),
  );

  @override
  Future<VendorProduct> update({
    required int id,
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  }) => _written(
    () => _dio.put<dynamic>(
      ApiConstants.vendorProductPath(id),
      data: _fields(edit, image),
      queryParameters: <String, String>{'locale': locale},
    ),
  );

  @override
  Future<void> remove({required int id, required String locale}) async {
    await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.vendorProductPath(id),
        queryParameters: <String, String>{'locale': locale},
      ),
    );
  }

  /// Only the words that were typed travel — an empty `q` would ask the
  /// category list for a match against nothing.
  static Map<String, String> _categoriesQuery(String locale, String? query) {
    final text = query?.trim();
    return <String, String>{
      'locale': locale,
      if (text != null && text.isNotEmpty) 'q': text,
    };
  }

  /// The listing takes its filters the same way: a filter the vendor did not
  /// choose is left out rather than sent empty.
  static Map<String, dynamic> _productsQuery(VendorProductQuery query) =>
      <String, dynamic>{
        'locale': query.locale,
        'per_page': query.perPage,
        'page': query.page,
        if (query.text.trim().isNotEmpty) 'q': query.text.trim(),
        if (query.categoryId != null) 'product_category_id': query.categoryId,
        if (query.status != null) 'status': query.status!.wire,
      };

  /// A write is multipart because the picture rides with it, so the plain
  /// fields go out as form parts too.
  static FormData _fields(VendorProductEdit edit, AvatarFile? image) =>
      FormData.fromMap(<String, dynamic>{
        'product_category_id': edit.categoryId,
        'name_ar': edit.nameAr,
        'name_en': edit.nameEn ?? '',
        'description_ar': edit.descriptionAr ?? '',
        'description_en': edit.descriptionEn ?? '',
        'price': edit.price,
        if (edit.quantity != null) 'quantity': edit.quantity,
        if (edit.isActive != null) 'is_active': edit.isActive! ? 1 : 0,
        if (edit.isAvailable != null) 'is_available': edit.isAvailable! ? 1 : 0,
        if (image != null)
          'image': MultipartFile.fromBytes(
            image.bytes,
            filename: image.fileName,
          ),
      });

  /// A write answers with the row it stored, approval flag included, so the
  /// list can show what the server decided instead of what was typed.
  Future<VendorProduct> _written(
    Future<Response<dynamic>> Function() request,
  ) async {
    final body = await _reply(request);
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Product reply carried no product');
    }
    try {
      return VendorProductModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Product reply carried no product');
    }
  }

  Future<Map<String, dynamic>?> _reply(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return _body(await request());
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static Map<String, dynamic>? _body(Response<dynamic>? response) =>
      response?.data is Map<String, dynamic>
      ? response!.data as Map<String, dynamic>
      : null;

  /// A validation reply names the offending field, which says more than the
  /// generic `message` the endpoint returns alongside it.
  static String _message(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    if (errors is Map) {
      for (final messages in errors.values) {
        final first = messages is List && messages.isNotEmpty
            ? messages.first
            : null;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }
    }
    return (body?['message'] as String?)?.trim() ?? '';
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final message = _message(_body(error.response));
      return ServerException(
        message.isEmpty ? 'HTTP ${error.response?.statusCode}' : message,
      );
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      _ => ServerException(error.message ?? 'Request failed'),
    };
  }
}
