part of 'manage_ingredient_view.dart';

class ManageIngredientViewNotifier extends ChangeNotifier {
  ManageIngredientViewNotifier(this.ref)
      : _repo = ref.read(ingredientRepoProvider);
  final Ref ref;
  final IngredientRepository _repo;

  //----------------------Form Props----------------------//
  late final ingredientViewNameController = TextEditingController();
  //----------------------Form Props----------------------//

  void initEdit(Ingredient data) {
    ingredientViewNameController.text = data.name ?? '';
  }

  Future<Either<String, Ingredient>> handlemanageIngredient([
    Ingredient? data,
  ]) async {
    final _data = (data ?? Ingredient()).copyWith(
      name: ingredientViewNameController.text,
    );

    return await Future.microtask(() => _repo.manageIngredient(_data));
  }
}

final ingredientViewProvider = ChangeNotifierProvider.autoDispose(
  ManageIngredientViewNotifier.new,
);
