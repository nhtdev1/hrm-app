class StaffEvent {}

class Increment extends StaffEvent {}

class UpdateData extends StaffEvent{

  final String keyword;

  UpdateData(this.keyword);
}