class FeedState {
  final bool isInitialized;
  final bool isLoading;
  final bool isStatusChecked;
  final bool shouldShowScrollUpButton;

  const FeedState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isStatusChecked = false,
    this.shouldShowScrollUpButton = false,
  });
}
