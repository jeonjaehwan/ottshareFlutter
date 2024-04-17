import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/userInfo.dart';


class AutoMatchingPage extends StatefulWidget {
  final UserInfo? userInfo; // 선택적 매개변수로 변경

  AutoMatchingPage({Key? key, this.userInfo}) : super(key: key); // `required` 제거

  @override
  _AutoMatchingPageState createState() => _AutoMatchingPageState();
}

class _AutoMatchingPageState extends State<AutoMatchingPage> {

  late UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo; // null일 수 있음
  }


  // 자동매칭 요청 함수
  Future<void> sendAutoMatchingRequest() async {
    if (selectedOttIndex == null || isLeader == null) {
      // 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select both OTT and role.')));
      return;
    }

    String ottTypeString;
    switch (selectedOttIndex) {
      case 0:
        ottTypeString = 'NETFLIX';
        break;
      case 1:
        ottTypeString = 'TVING';
        break;
      case 2:
        ottTypeString = 'DISNEY_PLUS';
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTT selection')));
        return;
    }

    Map<String, dynamic> requestMap = {
      'ott': ottTypeString,
      'isLeader': isLeader,
    };

    if (userInfo != null) {
      requestMap['userInfo'] = userInfo!.toJson(); // null 검사 후에 ! 사용
    }

    var body = jsonEncode(requestMap);

    print('Request body: $body'); // 요청 본문 출력

    // API 요청
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/waitingUser/save'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );


    if (response.statusCode == 200) {
      // 성공 처리
      print('Success response: ${response.body}'); // 성공 응답 본문 출력
    } else {
      // 실패 처리
      print('Failure response: ${response.body}'); // 실패 응답 본문 출력
    }
  }

  int? selectedOttIndex; // 선택된 OTT의 인덱스를 추적하는 변수
  bool? isLeader; // 방장이 선택되었는지 여부를 나타내는 상태


  void _onOttTapped(int index) {
    setState(() {
      selectedOttIndex = index;
    });
  }

  String _calculateSubscription() {
    if (selectedOttIndex == null) {
      return ''; // 서비스를 선택하지 않았을 때는 빈 문자열을 반환
    } else if (selectedOttIndex == 0) {
      return '27,000 / 3 = 월 9,000원'; // 넷플릭스 선택
    } else if (selectedOttIndex == 1) {
      return '17,000 / 4 = 월 4,250원'; // 티빙 선택
    } else if (selectedOttIndex == 2) {
      return '13,900 / 4 = 월 3,475원'; // 웨이브 선택
    }
    return ''; // 기타 경우
  }



  @override
  Widget build(BuildContext context) {
    String subscriptionText = _calculateSubscription();
    bool hasSelectedService = selectedOttIndex != null;


    Widget ottBox(String assetName, String label, int index) {
      bool isSelected = selectedOttIndex == index;
      return InkWell(
        onTap: () => _onOttTapped(index),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.yellow : Colors.grey, width: isSelected ? 3 : 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [Image.asset(assetName, width: 70), Text(label)]),
        ),
      );
    }

    ElevatedButton roleButton(String label, bool selected, bool leader) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            isLeader = leader;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.yellow : Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Container(
          height: 70,
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 20)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('OTT 공유'),
        bottom: PreferredSize(preferredSize: Size.fromHeight(1.0), child: Divider(height: 1.0, color: Colors.black)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text('OTT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              ottBox('assets/netflix_logo.png', '넷플릭스', 0),
              SizedBox(width: 20),
              ottBox('assets/tving_logo.png', '티빙', 1),
              SizedBox(width: 20),
              ottBox('assets/wavve_logo.png', '웨이브', 2),
            ]),
            SizedBox(height: 50),
            Align(alignment: Alignment.centerLeft, child: Text('역할', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(child: Padding(padding: const EdgeInsets.only(right: 4.0), child: roleButton('방장', isLeader == true, true))),
                Expanded(child: Padding(padding: const EdgeInsets.only(left: 4.0), child: roleButton('멤버', isLeader == false, false))),
              ],
            ),
            SizedBox(height: 50),
            if (hasSelectedService) Container(
              height: 100,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('구독 금액', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(subscriptionText, style: TextStyle(fontSize: 20, color: Colors.black)),
                ],
              ),
            ),
            if (!hasSelectedService) Container(
              height: 100,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Center(
                child: Text("서비스를 선택해주세요", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: sendAutoMatchingRequest, // 자동매칭 버튼 클릭 시 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffffdf24),
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('자동매칭', style: TextStyle(fontSize: 26)),
            ),
          ],
        ),
      ),
    );
  }
}
