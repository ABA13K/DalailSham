import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_product.dart';
import '../../domain/entities/vendor_product_edit.dart';
import '../../domain/entities/vendor_product_query.dart';
import '../../domain/repositories/vendor_product_repository.dart';

enum VendorProductsStatus { initial, loading, ready, failure }

class VendorProductsState extends Equatable {
  const VendorProductsState({
    this.status = VendorProductsStatus.initial,
    this.products = const [],
    this.text = '',
    this.categoryId,
    this.categoryName,
    this.approval,
    this.count,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isBusy = false,
    this.failure,
  });

  final VendorProductsStatus status;
  final List<VendorProduct> products;

  /// The words in the field, sent as `q`.
  final String text;
  final int? categoryId;

  /// Kept only to label the category chip; the request sends [categoryId].
  final String? categoryName;

  /// The approval state the list is narrowed to.
  final VendorProductStatus? approval;

  /// How many products the backend says match, across every page.
  final int? count;
  final bool hasMore;
  final bool isLoadingMore;

  /// A write is in flight, so no second one should start.
  final bool isBusy;
  final Failure? failure;

  bool get hasFilters =>
      categoryId != null || approval != null || text.isNotEmpty;

  /// A filter set to `null` means "leave it as it is", so clearing one takes
  /// the matching `clear...` flag instead.
  VendorProductsState copyWith({
    VendorProductsStatus? status,
    List<VendorProduct>? products,
    String? text,
    int? categoryId,
    String? categoryName,
    VendorProductStatus? approval,
    int? count,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isBusy,
    bool clearText = false,
    bool clearCategory = false,
    bool clearApproval = false,
  }) => VendorProductsState(
    status: status ?? this.status,
    products: products ?? this.products,
    text: clearText ? '' : (text ?? this.text),
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    categoryName: clearCategory ? null : (categoryName ?? this.categoryName),
    approval: clearApproval ? null : (approval ?? this.approval),
    count: count ?? this.count,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isBusy: isBusy ?? this.isBusy,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    products,
    text,
    categoryId,
    categoryName,
    approval,
    count,
    hasMore,
    isLoadingMore,
    isBusy,
    failure,
  ];
}

/// The vendor's own products, listed page by page under the filters the vendor
/// picks, and written back through the same three calls the dashboard uses.
///
/// A write answers with the message to show, or null when it worked, so a
/// rejected request still reaches the vendor with the words the backend used.
class VendorProductsCubit extends Cubit<VendorProductsState> {
  VendorProductsCubit(this._repository, {String locale = 'en'})
    : _locale = locale,
      super(const VendorProductsState());

  final VendorProductRepository _repository;

  String _locale;
  int? _nextPage;
  bool _requestInFlight = false;

  Future<void> load(String locale) async {
    _locale = locale;
    _nextPage = null;
    await _fetch(page: 1, replace: true);
  }

  /// The words typed in the field; empty means the whole list again.
  Future<void> search(String text) async {
    final trimmed = text.trim();
    if (trimmed == state.text) return;
    _emit(state.copyWith(text: trimmed));
    await _fetch(page: 1, replace: true);
  }

  Future<void> chooseCategory({required int id, required String name}) async {
    if (state.categoryId == id) return;
    _emit(state.copyWith(categoryId: id, categoryName: name));
    await _fetch(page: 1, replace: true);
  }

  Future<void> chooseApproval(VendorProductStatus? approval) async {
    if (state.approval == approval) return;
    _emit(state.copyWith(approval: approval, clearApproval: approval == null));
    await _fetch(page: 1, replace: true);
  }

  Future<void> clearFilters() async {
    if (!state.hasFilters) return;
    _emit(
      state.copyWith(clearText: true, clearCategory: true, clearApproval: true),
    );
    await _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null || _requestInFlight) return;
    _emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: next, replace: false);
  }

  Future<String?> add({required VendorProductEdit edit, AvatarFile? image}) =>
      _write(() => _repository.add(edit: edit, image: image, locale: _locale));

  Future<String?> update({
    required int id,
    required VendorProductEdit edit,
    AvatarFile? image,
  }) => _write(
    () => _repository.update(id: id, edit: edit, image: image, locale: _locale),
  );

  Future<String?> remove({required int id}) =>
      _write(() => _repository.remove(id: id, locale: _locale));

  /// Every write ends with a fresh first page, because the row the endpoint
  /// stores carries the approval flag and the id the form cannot guess.
  Future<String?> _write(Future<Result<Object?>> Function() request) async {
    _emit(state.copyWith(isBusy: true));
    final result = await request();
    return result.fold(
      (failure) {
        _emit(state.copyWith(isBusy: false));
        return failure.message;
      },
      (_) async {
        _emit(state.copyWith(isBusy: false));
        await load(_locale);
        return null;
      },
    );
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    final result = await _repository.products(
      VendorProductQuery(
        locale: _locale,
        page: page,
        categoryId: state.categoryId,
        status: state.approval,
        text: state.text,
      ),
    );
    _requestInFlight = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (replace) {
          emit(
            VendorProductsState(
              status: VendorProductsStatus.failure,
              text: state.text,
              categoryId: state.categoryId,
              categoryName: state.categoryName,
              approval: state.approval,
              failure: failure,
            ),
          );
        } else {
          _emit(state.copyWith(isLoadingMore: false));
        }
      },
      (listing) {
        _nextPage = listing.hasMore ? listing.nextPage : null;
        _emit(
          VendorProductsState(
            status: VendorProductsStatus.ready,
            products: replace
                ? listing.products
                : [...state.products, ...listing.products],
            text: state.text,
            categoryId: state.categoryId,
            categoryName: state.categoryName,
            approval: state.approval,
            count: listing.count,
            hasMore: _nextPage != null,
          ),
        );
      },
    );
  }

  /// A write or a page can answer after the page that started it is gone.
  void _emit(VendorProductsState next) {
    if (isClosed) return;
    emit(next);
  }
}
