class PaginationManager {
  int _currentPage = 1;
  int get currentPage => _currentPage;

  void reset() {
    _currentPage = 1;
  }

  void nextPage() {
    _currentPage++;
  }

  void pastPage() {
    _currentPage--;
  }
}
