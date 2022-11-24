// import 'package:demo/chat/chat_content.dart';
// import 'package:demo/tools/const.dart';
// import 'package:flutter/material.dart';
// import '../../tools/function.dart';
// //không dùng
// class CardItem extends StatelessWidget{
//   final List<CardStaff> list_staff = [
//     CardStaff(name: 'Hồ Việt Phát', id: '001', urlAvt: 'https://ss-images.saostar.vn/pc/1605234579397/z2174715918193_7a8c2d1a36fa6b98074de65420dcb7dd(1).jpg'),
//     CardStaff(name: 'Hồ Việt Phát', id: '002', urlAvt: 'https://ss-images.saostar.vn/pc/1605234579397/z2174715918193_7a8c2d1a36fa6b98074de65420dcb7dd(1).jpg'),
//     CardStaff(name: 'Hồ Việt Phát', id: '003', urlAvt: 'https://ss-images.saostar.vn/pc/1605234579397/z2174715918193_7a8c2d1a36fa6b98074de65420dcb7dd(1).jpg'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     final ThemeData themeData = Theme.of(context);
//
//     // TODO: implement build
//     return Expanded(
//       child: ListView.builder(
//           itemCount: list_staff.length,
//           itemBuilder: (BuildContext context, int index){
//             CardStaff staffInfo = list_staff[index];
//             return InkWell(
//               onTap: (){
//                 // Navigator.push(context, MaterialPageRoute(builder: (context) => MemberDetails(keyMember: 'hhh',)));
//               },
//               child: Container(
//                 height: size.width / 5,
//                 margin: EdgeInsets.all(5.0),
//                 padding: EdgeInsets.all(DefaultPadding - 5.0),
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 7,
//                         offset: Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                     borderRadius: BorderRadius.all(Radius.circular(20.0))
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       child: Row(
//                         // mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           CircleAvatar(backgroundImage: NetworkImage(staffInfo.urlAvt), radius: 30.0),
//                           addHorizontalSpace(DefaultPadding),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(staffInfo.name, style: themeData.textTheme.headline4,),
//                               addVerticalSpace(DefaultPadding/4),
//                               Text(staffInfo.id)
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     // CircleAvatar(backgroundImage: NetworkImage(staffInfo.urlAvt), radius: 30.0),
//                     // Column(
//                     //   crossAxisAlignment: CrossAxisAlignment.start,
//                     //   mainAxisAlignment: MainAxisAlignment.center,
//                     //   children: [
//                     //     Text(staffInfo.name, style: themeData.textTheme.headline4,),
//                     //     addVerticalSpace(DefaultPadding/4),
//                     //     Text(staffInfo.id)
//                     //   ],
//                     // ),
//                     addHorizontalSpace(DefaultPadding * 4),
//                     IconButton(
//                         onPressed: (){
//                           showToast(list_staff[index].id);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => Messenger(keyMember: list_staff[index].id,)),
//                           );
//                         },
//                         icon: Icon(Icons.message_outlined, color: COLOR_PRIMARY_1,)
//                     )
//                   ],
//                 ),
//               ),
//             );
//           }
//       ),
//     );
//   }
// }
//
// class CardStaff {
//   String name;
//   String id;
//   String urlAvt;
//
//   CardStaff({
//     required this.name,
//     required this.id,
//     required this.urlAvt
//   });
// }