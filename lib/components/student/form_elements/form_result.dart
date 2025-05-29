class FormResult {
  const FormResult({
    required this.questionIndex,
    required this.id,
    required this.value,
    required this.hiddenFields,
  });

  final int questionIndex;
  final String id;
  final String? value;
  final List<String> hiddenFields;

  factory FormResult.empty() {
    return const FormResult(
      questionIndex: 0,
      id: '',
      value: null,
      hiddenFields: [],
    );
  }

  @override
  String toString() {
    return "FormResult(questionIndex: $questionIndex, id: $id, value: $value, hiddenFields: $hiddenFields)";
  }
}

typedef FormResultCallback = void Function(FormResult result);
