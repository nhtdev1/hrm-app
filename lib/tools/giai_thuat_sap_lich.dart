import 'package:cloud_firestore/cloud_firestore.dart';
import 'file_storage.dart';

const INF = 99;
//sửa lại
class GiaiThuat{
  final fireStore = FirebaseFirestore.instance;
  List<Member> list_ngayRanh = []; //list ngayRanh của tất cả các nhân viên
  List<int> list_tongNgayRanh = []; //list tổng ngày rảnh của tất cả các nhân viên
  List<int> thuTuCa = []; //thứ tự các ca
  List<int> thuTuNhanVien = []; //thứ tự nhan vien
  List<String> lichDuKien = []; //list lịch sau khi sắp

  //cập nhật lịch rảnh vào file khi ...
  void lichRanh_databaseToFile(){
    Query ref = fireStore.collection('users').orderBy('no', descending: false);
    ref.get().then((QuerySnapshot snapshot)async{
      await FileStorage().cleanFile('lichRanh'); //reset lại file
      var values = snapshot.docs;
      values.forEach((element) {
        var data = element.data() as Map<String, dynamic>;
        if(data['no'] != '000') {
          String s = data['lichRanh'];
          FileStorage().writeFile(s.substring(s.lastIndexOf(" ") + 1), 'lichRanh'); //lưu lịch rảnh
        }
      });
    });
  }

  //cập nhật lịch rảnh vào file khi ...
  void lichRanh_old_databaseToFile(){
    Query ref = fireStore.collection('users').orderBy('no', descending: false);
    ref.get().then((QuerySnapshot snapshot){
      FileStorage().cleanFile('lichRanh_old');
      var values = snapshot.docs;
      values.forEach((element) {
        var data = element.data() as Map<String, dynamic>;
        if(data['no'] != '000') {
          String s2 = data['lichRanh_old'];
          FileStorage().writeFile(s2.substring(s2.lastIndexOf(" ") + 1), 'lichRanh_old');
        }
      });
    });
  }

  void name_databaseToFile(){
    Query ref = fireStore.collection('users').orderBy('no', descending: false);
    ref.get().then((QuerySnapshot snapshot)async{
      await FileStorage().cleanFile('name'); //reset lại file
      var values = snapshot.docs;
      values.forEach((element) {
        var data = element.data() as Map<String, dynamic>;
        if(data['no'] != '000') {
          String s = data['name'];
          FileStorage().writeFile(s.substring(s.lastIndexOf(" ") + 1), 'name'); //lưu tên
        }
      });
    });
  }


  //load lịch rảnh từ file
  Future<List> loadData() async { //lấy dữ liệu từ firebase về file
    var lichRanh = await FileStorage().readFile('lichRanh');
    List list = lichRanh.split("\n"); //cắt file
    list.removeLast(); //loại bỏ kí tự xuống dòng
    return list; //trả về list lịch rảnh
  }

  Future<List<int>> sapXepCa() async { //trả về list ca theo thứ tự ít đến nhiều
    int min = INF;
    int k=0;
    List<int> Ca = List.filled(21, 0);
    List<int> temp = List.filled(21, 0); //khởi tạo các giá trị rỗng cho thuTuCa
    List<bool> mark = List.filled(21, false);

    List data = await loadData();

    //đếm ca
    for(int i=0; i<21; i++){ //xét từng ca
      for(int j=0; j<data.length; j++){ //xét từng thành viên
        if(data[j][i] == '1')
          Ca[i]++;
      }
    }

    //sắp xếp danh sách Ca[]
    for(int j=0; j<21; j++){
      for(int i=0; i<21; i++)
        if(Ca[i] < min && mark[i] != true){
          min = Ca[i];
          k = i;
        }
      min = INF;
      mark[k] = true;
      temp[j] = k;
    }

    return temp;
  }

  Future<List<int>> sapXepNhanVien(int soLuongNV) async { //trả về list nhân viên có số ngày rảnh từ ít đến nhiều
    int min = INF;
    int k = 0;
    List<int> temp = List.filled(soLuongNV, 0);
    List<bool> mark = List.filled(soLuongNV, false);
    list_tongNgayRanh = List.filled(soLuongNV, 0);
    List data = await loadData();

    //đếm tổng số ngày có thể làm của từng nv
    for(int i=0; i<data.length; i++){
      for(int j=0; j<21; j++){
        if(data[i][j] == '1')
          list_tongNgayRanh[i]++;
      }
    }

    //sắp xếp thứ tự nhân viên
    for(int j=0; j<data.length; j++){
      for(int i=0; i<data.length; i++)
        if(list_tongNgayRanh[i] < min && mark[i] != true){
          // min = NV[i];
          min = list_tongNgayRanh[i];
          k = i;
        }
      min = INF;
      mark[k] = true;
      temp[j] = k; // k là số thứ tự của từng nhân viên
    }
    return temp;
  }

  Future<List<String>> sapLich(int soLuongNV) async { //trả về list lịch sau khi sắp xếp
    List<String> tenNV = List.filled(soLuongNV, ''); //lưu tên nhân viên
    List<String> temp = List.filled(21, '-'); //lich sau khi sap
    List<int> list_order = List.filled(21, -1); //lưu số thứ tự nhân viên sau khi sắp lịch
    List<int> count = List.filled(soLuongNV, 0); //đếm số ca nhân viên khi sắp lịch
    List<bool> mark = List.filled(soLuongNV, false); //đánh dấu
    int avg = 21~/soLuongNV; //trung bình số ca một nhân viên trong tuần

    var value = await FileStorage().readFile('lichRanh');
    var lichranh = await value.split("\n"); //cắt file

    thuTuCa = await sapXepCa();
    thuTuNhanVien = await sapXepNhanVien(soLuongNV);

    //giải thuật sắp lịch...
    int k = 0;
    for(int i=0; i<21; i++){ //chạy từ ThuTuCa[1->21]
      //  for(int j=1; j<=3; j++){ // sau này đổi lại thành số nhân viên tối đa 1 ca
      while(k!= -1 && k<soLuongNV){
        if(list_tongNgayRanh[thuTuNhanVien[k]] < avg)//nếu tổng ngày rảnh ít hơn trung bình ca, thì thay thế temp
          avg = list_tongNgayRanh[thuTuNhanVien[k]];

        if( //điều kiện để sắp vô ca
            mark[thuTuNhanVien[k]] != true
            && count[thuTuNhanVien[k]] < avg
            && lichranh[thuTuNhanVien[k]][thuTuCa[i]] == '1'
            && list_order[thuTuCa[i]] == -1
        ){
          list_order[thuTuCa[i]] = thuTuNhanVien[k];
          print(list_order[thuTuCa[i]]);
          count[thuTuNhanVien[k]]++;
        }
        k++;
        avg = 21~/soLuongNV;
      }
      k = 0;
    }
    for(int i=0; i<21; i++)
      if(list_order[i] == -1)
        for(int j=0; j<soLuongNV; j++)
          if(lichranh[j][i] == '1'){
            list_order[i] = j;
            break;
          }
    var ten = await FileStorage().readFile('name');
    tenNV = await ten.split("\n"); //cắt file

    for(int i=0; i<21; i++){
      if(list_order[i] != -1)
        temp[i] = tenNV[list_order[i]];
    }
    return temp;
  }
}

class Member{ //các thuộc tính của một nhân viên
  late List<bool> ngayRanh; //list đánh dấu ngày rảnh
  late int tongNgayRanh; //tổng ngày rảnh
  late int thuTuNV; //thứ tự nhân viên tính theo thứ tự có ngày rảnh ít nhất đến nhiều nhất

  Member(){
    ngayRanh = List.filled(21, false);
    tongNgayRanh = 0;
    thuTuNV = 0;
  }
}