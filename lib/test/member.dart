import 'package:flutter/material.dart';

class Member{
  String keyThanhVien;
  String id;
  String taiKhoan;
  String matKhau;
  String ten;
  String? ngayVaoLam;
  String ngaySinh;
  String? gioiTinh;
  String? urlAvt;
  int? luong;
  String? sdt;
  String? diaChi;

  Member({
    required this.keyThanhVien,
    required this.id,
    required this.taiKhoan,
    required this.matKhau,
    required this.ten,
    this.ngayVaoLam,
    required this.ngaySinh,
    this.gioiTinh,
    this.urlAvt,
    this.sdt,
    this.luong,
    this.diaChi
  });
}