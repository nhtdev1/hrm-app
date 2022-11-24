class LikeEvent{}

class LikeChange extends LikeEvent{}

class Increment extends LikeEvent{
  final int count;

  Increment(this.count);
}

class Decrement extends LikeEvent{
  final int count;

  Decrement(this.count);
}