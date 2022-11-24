class LikeState{
  final int count;

  LikeState(this.count);
}

class Liked extends LikeState{
  Liked(int count) : super(count);


  // Liked(this.count);
}

class Unliked extends LikeState{
  Unliked(int count) : super(count);
  // final int count;
  //
  // Unliked(this.count);
}