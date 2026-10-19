enum LoadStatus {
  idle,
  loading,
  success,
  failure;

  bool get isLoading => this == LoadStatus.loading;
}
