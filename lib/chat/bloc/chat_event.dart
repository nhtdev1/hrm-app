class ChatEvent {}

class UpdateData extends ChatEvent{

  final String keyword;

  UpdateData(this.keyword);
}