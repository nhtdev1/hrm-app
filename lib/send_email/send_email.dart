import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailjet/mailjet.dart';
import 'package:xeplich/chart/ChartPage.dart';

class Receiver {
  final String email;
  final String name;

  Receiver(this.email, this.name);
}

class SendEmail {
  static final SendEmail _singleton = SendEmail._internal();

  factory SendEmail() => _singleton;

  SendEmail._internal();

  static final emailTemplate = """"
      <style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
      <h3>ADMIN đã cập nhật lịch làm mới. Các bạn vui lòng xem qua nhé</h3>
<table>
  <tr>
    <th>Thứ</th>
    <th>Sáng</th>
    <th>Trưa</th>
    <th>Chiều</th>
  </tr>
  <tr>
    <td>Thứ 2</td>
    <td>Khuê</td>
    <td>Khuê</td>
    <td>Khuê</td>
  </tr>
  <tr>
    <td>Thứ 3</td>
 	<td>Khuê</td>
    <td>Khuê</td>
    <td>Khuê</td>
  </tr>
  <tr>
      <td>Thứ 4</td>
    <td>Khuê</td>
    <td>Khuê</td>
    <td>Khuê</td>
  </tr>
  <tr>
      <td>Thứ 5</td>
    <td>Khuê</td>
    <td>Khuê</td>
    <td>Khuê</td>
  </tr>
  <tr>
    <td>Thứ 6</td>
    <td>Khuê</td>
    <td>Khuê</td>
    <td>Khuê</td>
  </tr>
  <tr>
      <td>Thứ 7</td>
      <td>Khuê</td>
      <td>Khuê</td>
      <td>Khuê</td>
  </tr>
  <tr>
      <td>Chủ nhật</td>
      <td>Khuê</td>
     <td>Khuê</td>
     <td>Khuê</td>
  </tr>
</table>""";

  Future<bool> sendEmail(
      {String sender = "quanandaudau2001@gmail.com",
      required List<Receiver> receiver,
      String subject = "LỊCH LÀM VIỆC MỚI",
      String apiKey = "15d3187d909489fcfff8b26dbb8ba7f6",
      String secretKey = "20711f2477c4df95e526f69582829bad",
      String htmlEmail =
          "<h3>ADMIN đã cập nhật lịch làm mới. Các bạn vui lòng xem qua nhé</h3><br />Chúc toàn thể nhân viên một ngày tốt lành!"}) async {
    try {
      MailJet mailJet = MailJet(
        apiKey: apiKey,
        secretKey: secretKey,
      );
      List<Recipient> recipients = receiver
          .map((e) => Recipient(
                email: e.email,
                name: e.name,
              ))
          .toList();

      var result = await mailJet.sendEmail(
        subject: subject,
        sender: Sender(
          email: sender,
          name: "QUÁN ĂN ĐẬU ĐẬU",
        ),
        reciepients: recipients,
        htmlEmail: htmlEmail,
      );
      print(result);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  String generateScheduleTemplate(List<String> schedule, String week) {
    if (schedule.length != 21) return "Lỗi định dạng";
    String template = """
        <h3>ADMIN đã cập nhật lịch làm mới cho tuần $week. Các bạn vui lòng xem qua nhé!!!</h3>
<table>
  <tr>
    <th>Thứ</th>
    <th>Sáng</th>
    <th>Trưa</th>
    <th>Chiều</th>
  </tr>
  <tr>
    <td>Thứ 2</td>
   <td style="background-color:${schedule[0] == '-' ? "#FF0000" : "#00FF00"}">${schedule[0] == '-' ? "(Trống)" : schedule[0]}</td>
    <td style="background-color:${schedule[1] == '-' ? "#FF0000" : "#00FF00"}">${schedule[1] == '-' ? "(Trống)" : schedule[1]}</td>
    <td style="background-color:${schedule[2] == '-' ? "#FF0000" : "#00FF00"}">${schedule[2] == '-' ? "(Trống)" : schedule[2]}</td>
  </tr>
  <tr>
    <td>Thứ 3</td>
   <td style="background-color:${schedule[3] == '-' ? "#FF0000" : "#00FF00"}">${schedule[3] == '-' ? "(Trống)" : schedule[3]}</td>
    <td style="background-color:${schedule[4] == '-' ? "#FF0000" : "#00FF00"}">${schedule[4] == '-' ? "(Trống)" : schedule[4]}</td>
    <td style="background-color:${schedule[5] == '-' ? "#FF0000" : "#00FF00"}">${schedule[5] == '-' ? "(Trống)" : schedule[5]}</td>
  </tr>
  <tr>
      <td>Thứ 4</td>
   <td style="background-color:${schedule[6] == '-' ? "#FF0000" : "#00FF00"}">${schedule[6] == '-' ? "(Trống)" : schedule[6]}</td>
    <td style="background-color:${schedule[7] == '-' ? "#FF0000" : "#00FF00"}">${schedule[7] == '-' ? "(Trống)" : schedule[7]}</td>
    <td style="background-color:${schedule[8] == '-' ? "#FF0000" : "#00FF00"}">${schedule[8] == '-' ? "(Trống)" : schedule[8]}</td>
  </tr style="background-color:#00FF00">
  <tr>
      <td>Thứ 5</td>
   <td style="background-color:${schedule[9] == '-' ? "#FF0000" : "#00FF00"}">${schedule[9] == '-' ? "(Trống)" : schedule[9]}</td>
    <td style="background-color:${schedule[10] == '-' ? "#FF0000" : "#00FF00"}">${schedule[10] == '-' ? "(Trống)" : schedule[10]}</td>
    <td style="background-color:${schedule[11] == '-' ? "#FF0000" : "#00FF00"}">${schedule[11] == '-' ? "(Trống)" : schedule[11]}</td>
  </tr>
  <tr>
    <td>Thứ 6</td>
   <td style="background-color:${schedule[12] == '-' ? "#FF0000" : "#00FF00"}">${schedule[12] == '-' ? "(Trống)" : schedule[12]}</td>
    <td style="background-color:${schedule[13] == '-' ? "#FF0000" : "#00FF00"}">${schedule[13] == '-' ? "(Trống)" : schedule[13]}</td>
    <td style="background-color:${schedule[14] == '-' ? "#FF0000" : "#00FF00"}">${schedule[14] == '-' ? "(Trống)" : schedule[14]}</td>
  </tr>
  <tr>
      <td>Thứ 7</td>
   <td style="background-color:${schedule[15] == '-' ? "#FF0000" : "#00FF00"}">${schedule[15] == '-' ? "(Trống)" : schedule[15]}</td>
    <td style="background-color:${schedule[16] == '-' ? "#FF0000" : "#00FF00"}">${schedule[16] == '-' ? "(Trống)" : schedule[16]}</td>
    <td style="background-color:${schedule[17] == '-' ? "#FF0000" : "#00FF00"}">${schedule[17] == '-' ? "(Trống)" : schedule[17]}</td>
  </tr>
  <tr>
      <td>Chủ nhật</td>
    <td style="background-color:${schedule[18] == '-' ? "#FF0000" : "#00FF00"}">${schedule[18] == '-' ? "(Trống)" : schedule[18]}</td>
    <td style="background-color:${schedule[19] == '-' ? "#FF0000" : "#00FF00"}">${schedule[19] == '-' ? "(Trống)" : schedule[19]}</td>
    <td style="background-color:${schedule[20] == '-' ? "#FF0000" : "#00FF00"}">${schedule[20] == '-' ? "(Trống)" : schedule[20]}</td>
  </tr>
  <br>
    <br>
Mọi thắc mắc xin liên hệ về email <a href="quanandaudau2001@gmail.com">quanandaudau2001@gmail.com</a>. Hoặc qua số điện thoại:<a href="077-682-4881">077-682-4881</a>. Xin cảm ơn.
</table>""";
    return template;
  }

  Future<List<Employee>> getEmployees() async {
    try {
      List<Employee> employees = [];
      var userCollection =
          await FirebaseFirestore.instance.collection('users').get();
      var users = userCollection.docs;
      users.forEach(
        (element) {
          var data = element.data();
          if (data['no'] != '000') {
            employees.add(Employee.fromJson(data));
          }
        },
      );
      return employees;
    } catch (error) {
      return [];
    }
  }
}
