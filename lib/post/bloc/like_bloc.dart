import 'package:bloc/bloc.dart';
import 'package:xeplich/post/bloc/like_event.dart';
import 'package:xeplich/post/bloc/like_state.dart';

class LikeBloc extends Bloc<LikeEvent, LikeState>{

  final LikeState likeState;

  LikeBloc(this.likeState) : super(likeState){
    on<Increment>((event, emit){
      if(state is Unliked)
        return emit(Liked(event.count+1));
    });
    on<Decrement>((event, emit){
      if(state is Liked)
        return emit(Unliked(event.count-1));
    });
  }
}

