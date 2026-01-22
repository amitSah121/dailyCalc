enum ExportStatus {
  success,
  failure,
}

class ExportResult {
  final ExportStatus status;
  final String message;

  const ExportResult({
    required this.status,
    required this.message,
  });

  bool get isSuccess => status == ExportStatus.success;
}
