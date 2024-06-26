
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChangeSwitch extends GetxController {
  
  bool weightValue = false;
  bool hairValue = false;
  bool acneValue = false;
  bool skinValue = false;

  int wValue = 0;
  int hValue = 0;
  int aValue = 0;
  int sValue = 0;

  double result = 0;
  String textResult = '';

  final box = GetStorage();

  //몸무게 switch value 바꾸기
  changeWeightValue() {
    weightValue ?
    weightValue = true :
    weightValue = false;

    update();
  }

  //다모증 switch value 바꾸기  
  changeHairValue() {
    hairValue ?
    hairValue = true :
    hairValue = false;
    
    update();
  }

  //여드름 switch value 바꾸기
  changeAcneValue() {
    acneValue ?
    acneValue = true :
    acneValue = false;
    
    update();
  }

  //다크닝 switch value 바꾸기
  changeSkinValue() {
    skinValue ?
    skinValue = true :
    skinValue = false;
    
    update();
  }

  // 설문조사한 값들로 발생률 가져오기 
  getJSONData() async {

    weightValue ? wValue = 1 : wValue = 0;
    hairValue ? hValue = 1 : hValue = 0;
    acneValue ? aValue = 1 : aValue = 0;
    skinValue ? sValue = 1 : sValue = 0;

    var url = Uri.parse('http://localhost:8080/Flutter/Pserve/pcosPred.jsp?weight=$wValue&hair=$hValue&acne=$aValue&dark=$sValue');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(response.body);

    result = dataConvertedJSON['result'] * 100;

    if (result >= 80) {
      textResult = "병원을 가보시는 것을 추천드립니다.";
    } else if (result >= 60) {
      textResult = "정기적인 검진을 받아보시는 것을 추천드립니다.";
    } else if (result >= 40) {
      textResult = "긴장하셔야 합니다.";
    } else {
      textResult = "양호합니다.";
    }
    insertResult(result);

    //스위치 value false로 초기화
    weightValue = false;
    hairValue = false;
    acneValue = false;
    skinValue = false;

    update();
  }

  insertResult(result) async {

    //로그인한 email과 같은 user를 가져옴
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('user')
      .where('email', isEqualTo: box.read('email'))
      .limit(1)
      .get();

    if(querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;
      String documentId = document.id;

      await FirebaseFirestore.instance
          .collection('user')
          .doc(documentId)
          .update({'occurRate' : result});
    } 

    update();
  }

}