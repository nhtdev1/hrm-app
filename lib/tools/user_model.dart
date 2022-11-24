import 'package:flutter/material.dart';

class UserModel{
  String? uid;
  String? email;
  String? name;
  String? pass;
  String? no; //number order
  String? DOB;
  String? DOE;
  String? phone;
  String? address;
  String? lichRanh;
  String? lichRanh_old;

  UserModel({
    this.uid,
    this.email,
    this.name,
    this.pass,
    this.no,
    this.DOB,
    this.DOE,
    this.phone,
    this.address,
    this.lichRanh,
    this.lichRanh_old
  });

  //recieving data from server
  factory UserModel.fromMap(map){
    return UserModel(
      email: map['email'],
      uid: map['uid'],
      pass: map['pass'],
      name: map['name'],
      no: map['no'],
      DOB: map['DOB'],
      DOE: map['DOE'],
      phone: map['phone'],
      address: map['address'],
      lichRanh: map['lichRanh'],
      lichRanh_old: map['lichRanh_old']
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap(){
    return{
      'uid': uid,
      'email': email,
      'pass': pass,
      'name': name,
      'no': no,
      'DOB': DOB,
      'DOE': DOE,
      'phone': phone,
      'address': address,
      'lichRanh': lichRanh,
      'lichRanh_old': lichRanh_old
    };
  }
}