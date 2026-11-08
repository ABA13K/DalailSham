import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/option_sheet.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../../profile/domain/repositories/avatar_picker.dart';
import '../../domain/entities/vendor_product.dart';
import '../../domain/entities/vendor_product_edit.dart';
import '../../domain/repositories/vendor_product_repository.dart';
import '../cubit/vendor_products_cubit.dart';

/// What the form route is handed: the cubit it writes through, and the product
/// it edits — none when the vendor is adding one.
///
/// Sharing the cubit is what keeps the list behind the form honest, since every
/// write reads the first page back into it.
class VendorProductFormArgs {
  const VendorProductFormArgs({required this.cubit, this.product});

  final VendorProductsCubit cubit;
  final VendorProduct? product;
}

/// `POST /vendor/products` and `PUT /vendor/products/{id}` — the fields both
/// take, plus the picture that rides with them.
class VendorProductFormPage extends StatefulWidget {
  const VendorProductFormPage({super.key, required this.args});

  final VendorProductFormArgs args;

  @override
  State<VendorProductFormPage> createState() => _VendorProductFormPageState();
}

class _VendorProductFormPageState extends State<VendorProductFormPage> {
  static const _priceCeiling = 9999999.99;
  static const _quantityCeiling = 999999;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameAr = _controller(
    widget.args.product?.nameAr,
  );
  late final TextEditingController _nameEn = _controller(
    widget.args.product?.nameEn,
  );
  late final TextEditingController _descriptionAr = _controller(
    widget.args.product?.descriptionAr,
  );
  late final TextEditingController _descriptionEn = _controller(
    widget.args.product?.descriptionEn,
  );
  late final TextEditingController _price = _controller(
    widget.args.product == null ? '' : _plain(widget.args.product!.price),
  );
  late final TextEditingController _quantity = _controller(
    widget.args.product?.quantity?.toString(),
  );

  int? _categoryId;
  String? _categoryName;
  bool _isActive = true;
  bool _isAvailable = true;

  /// The picture chosen for this write; the one already stored stays unless the
  /// vendor picks another.
  AvatarFile? _picked;

  TextEditingController _controller(String? text) =>
      TextEditingController(text: text ?? '');

  @override
  void initState() {
    super.initState();
    final product = widget.args.product;
    _categoryId = product?.categoryId;
    _categoryName = product?.categoryName;
    _isActive = product?.isActive ?? true;
    _isAvailable = product?.isAvailable ?? true;
  }

  @override
  void dispose() {
    for (final controller in [
      _nameAr,
      _nameEn,
      _descriptionAr,
      _descriptionEn,
      _price,
      _quantity,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final category = await showOptionSheet<ExploreCategory>(
      context,
      title: l10n.chooseCategory,
      label: (category) => category.name,
      load: (locale, query) async {
        final result = await getIt<VendorProductRepository>().categories(
          locale: locale,
          query: query,
        );
        return result.fold(
          (failure) => throw failure,
          (categories) => categories,
        );
      },
    );
    if (category == null || !mounted) return;
    setState(() {
      _categoryId = category.id;
      _categoryName = category.name;
    });
  }

  Future<void> _pickImage() async {
    final file = await getIt<AvatarPicker>().pick();
    if (file == null || !mounted) return;
    // Nothing is uploaded yet — the picture rides with the write.
    setState(() => _picked = file);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = widget.args.cubit;
    final product = widget.args.product;
    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final categoryId = _categoryId;
    if (categoryId == null) {
      notify(l10n.productCategoryRequired);
      return;
    }

    final edit = VendorProductEdit(
      categoryId: categoryId,
      nameAr: _nameAr.text.trim(),
      nameEn: _blank(_nameEn.text),
      descriptionAr: _blank(_descriptionAr.text),
      descriptionEn: _blank(_descriptionEn.text),
      price: double.parse(_price.text.trim()),
      quantity: _whole(_quantity.text),
      // A new product has no flags to change — the endpoint does not take them.
      isActive: product == null ? null : _isActive,
      isAvailable: product == null ? null : _isAvailable,
    );

    final message = product == null
        ? await cubit.add(edit: edit, image: _picked)
        : await cubit.update(id: product.id, edit: edit, image: _picked);
    if (message != null) {
      notify(message);
      return;
    }
    notify(l10n.productSaved);
    if (!mounted) return;
    GoRouter.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = widget.args.cubit;
    final product = widget.args.product;
    if (product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteProductQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('product-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteProduct),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final message = await cubit.remove(id: product.id);
    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.productDeleted)));
    if (!mounted) return;
    GoRouter.of(context).pop();
  }

  static String? _blank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// A whole price opens the field without a `.0` the vendor then has to delete.
  static String _plain(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  static int? _whole(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isEdit = widget.args.product != null;

    String? checkName(String? value) {
      final required = value == null || value.trim().isEmpty
          ? l10n.fieldRequired
          : null;
      if (required != null) return required;
      return value!.length > 255 ? l10n.tooLong : null;
    }

    String? checkOptional(String? value, int max) =>
        (value?.length ?? 0) > max ? l10n.tooLong : null;

    String? checkPrice(String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return l10n.fieldRequired;
      final parsed = double.tryParse(text);
      if (parsed == null || parsed < 0 || parsed > _priceCeiling) {
        return l10n.invalidPrice;
      }
      return null;
    }

    String? checkQuantity(String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      final parsed = int.tryParse(text);
      if (parsed == null || parsed < 0 || parsed > _quantityCeiling) {
        return l10n.invalidQuantity;
      }
      return null;
    }

    return BlocProvider.value(
      value: widget.args.cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? l10n.editProduct : l10n.addProduct,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (isEdit)
              IconButton(
                key: const ValueKey('product-delete'),
                tooltip: l10n.deleteProduct,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: CenteredContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Picture(
                    product: widget.args.product,
                    picked: _picked,
                    onPick: _pickImage,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    key: const ValueKey('product-category-tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _categoryId == null
                          ? Icons.category_rounded
                          : Icons.sell_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      _categoryName ?? l10n.labelCategory,
                      style: _categoryName == null
                          ? theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickCategory,
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    key: const ValueKey('product-name-ar'),
                    controller: _nameAr,
                    label: l10n.nameArabicLabel,
                    validator: checkName,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    key: const ValueKey('product-name-en'),
                    controller: _nameEn,
                    label: l10n.nameEnglishLabel,
                    validator: (value) => checkOptional(value, 255),
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    key: const ValueKey('product-description-ar'),
                    controller: _descriptionAr,
                    label: l10n.descriptionArabicLabel,
                    maxLines: 4,
                    validator: (value) => checkOptional(value, 5000),
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    key: const ValueKey('product-description-en'),
                    controller: _descriptionEn,
                    label: l10n.descriptionEnglishLabel,
                    maxLines: 4,
                    validator: (value) => checkOptional(value, 5000),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AuthTextField(
                          key: const ValueKey('product-price'),
                          controller: _price,
                          label: l10n.priceLabel,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: checkPrice,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AuthTextField(
                          key: const ValueKey('product-quantity'),
                          controller: _quantity,
                          label: l10n.quantityLabel,
                          keyboardType: const TextInputType.numberWithOptions(),
                          validator: checkQuantity,
                        ),
                      ),
                    ],
                  ),
                  // Only the edit call takes the two flags, so a new product is
                  // written without them.
                  if (isEdit) ...[
                    const SizedBox(height: 8),
                    SwitchListTile(
                      key: const ValueKey('product-active'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.activeLabel),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    SwitchListTile(
                      key: const ValueKey('product-available'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.availableLabel),
                      value: _isAvailable,
                      onChanged: (value) =>
                          setState(() => _isAvailable = value),
                    ),
                  ],
                  const SizedBox(height: 20),
                  BlocBuilder<VendorProductsCubit, VendorProductsState>(
                    builder: (context, state) => FilledButton(
                      key: const ValueKey('product-save'),
                      onPressed: state.isBusy ? null : _submit,
                      child: state.isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? l10n.saveChanges : l10n.addProduct),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The picture the vendor already stored, or the one just chosen on the device.
class _Picture extends StatelessWidget {
  const _Picture({
    required this.product,
    required this.picked,
    required this.onPick,
  });

  final VendorProduct? product;
  final AvatarFile? picked;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: picked != null
                ? Image.memory(picked!.bytes, fit: BoxFit.cover)
                : product?.imageUrl == null
                ? ColoredBox(
                    color: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_bar_rounded,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                : Image.network(
                    product!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const ValueKey('product-pick-image'),
            onPressed: onPick,
            child: Text(l10n.changePhoto),
          ),
        ),
      ],
    );
  }
}
