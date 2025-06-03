mixin ValidationsMixin {
  String? isNotEmpty(String? value, [String? message]){
    if (value!.isEmpty) return message ?? 'Este campo é obrigatório';
    return null;

  }
  String? temSeteChars(String? value, [String? message]) {
    if (value!.length < 7) return message ?? 'Você deve usar pelo menos 7 caracteres';
    return null;
  }


}