class UserRelationState {
  final bool isBlocked;
  final bool isBlockedMe;
  final bool isRequested;
  final bool isFriend;

  const UserRelationState({
    this.isBlocked = false,
    this.isBlockedMe = false,
    this.isRequested = false,
    this.isFriend = false,
  });
}
