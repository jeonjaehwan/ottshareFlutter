import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ott_share/models/userInfo.dart';
import 'package:ott_share/screen/ChatRoomPage.dart';
import 'package:ott_share/screen/OTTInfoPage.dart';

class AutoMatchingPage extends StatefulWidget {
  final UserInfo? userInfo;

  AutoMatchingPage({Key? key, this.userInfo}) : super(key: key);

  @override
  _AutoMatchingPageState createState() => _AutoMatchingPageState();
}

class _AutoMatchingPageState extends State<AutoMatchingPage> {
  late UserInfo? userInfo;
  int? selectedOttIndex; // 선택된 OTT의 인덱스를 추적하는 변수
  bool? isLeader; // 방장이 선택되었는지 여부를 나타내는 상태
  late bool? isShareRoom;
  bool isStartMatching = false;




  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo;
    isShareRoom = widget.userInfo?.isShareRoom;
    // isShareRoom = true;


    getIsStartMatching().then((value) {
      setState(() {
        isStartMatching = value;
      });
    });

    print('user info = ${widget.userInfo}');

  }

  Future<bool> getIsStartMatching() async {

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/waitingUser/save'),
      headers: {"Content-Type": "application/json"},
    );

    return false;
  }

  Future<void> sendAutoMatchingRequest() async {
    if (selectedOttIndex == null || isLeader == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select both OTT and role.')));
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
        ottTypeString = 'WAVVE';
        break;
      default:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invalid OTT selection')));
        return;
    }

    Map<String, dynamic> requestMap = {
      'ott': ottTypeString,
      'isLeader': isLeader,
    };

    if (userInfo != null) {
      requestMap['userInfo'] = userInfo!.toJson();
    }

    var body = jsonEncode(requestMap);

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/waitingUser/save'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );
  }

  Future<void> navigateToChatRoom() async {
    if (userInfo == null || userInfo!.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User information is incomplete.')));
      return;
    }

    var url =
        Uri.parse('http://localhost:8080/api/ottShareRoom/${userInfo!.userId}');
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var ottShareRoom = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomPage(ottShareRoom: ottShareRoom),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retrieve room information')));
    }
  }

  Widget ottBox(String assetName, String label, int index) {
    bool isSelected = selectedOttIndex == index;
    return ElevatedButton(
        onPressed: () => _onOttTapped(index),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isSelected ? Color(0xffffdf24) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Color(0xffffdf24), width: 2)),
        ),
        child: Container(
            height: 140,
            width: 60,
            child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              Container(
                height: 70,
                child: Image.asset(assetName, width: 50, height: 50),
              ),
              Text(label),
            ]))
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
        backgroundColor: selected ? Color(0xffffdf24) : Colors.white,
        foregroundColor: selected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Color(0xffffdf24), width: 2))
      ),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 20)),
      ),
    );
  }

  void _onOttTapped(int index) {
    setState(() {
      selectedOttIndex = index;
    });
  }

  String _calculateSubscription() {
    if (selectedOttIndex == null) {
      return '';
    } else if (selectedOttIndex == 0) {
      return '27,000 / 3 = 월 9,000원';
    } else if (selectedOttIndex == 1) {
      return '17,000 / 4 = 월 4,250원';
    } else if (selectedOttIndex == 2) {
      return '13,900 / 4 = 월 3,475원';
    }
    return '';
  }

  void _handleAutoMatching() {
    if (selectedOttIndex != null && isLeader != null) {
      if (isLeader!) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OTTInfoPage(
                  selectedOttIndex: selectedOttIndex ?? 0,
                  isLeader: isLeader ?? false,
                  userInfo: userInfo)),
        ).then(
          (value) {
            setState(() {
              isStartMatching = value;
            });
          },
        );
      } else {
        sendAutoMatchingRequest();
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('OTT 서비스와 역할을 모두 선택해주세요.')));
    }
  }



  @override
  Widget build(BuildContext context) {
    String subscriptionText = _calculateSubscription();
    bool hasSelectedService = selectedOttIndex != null;

    

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(
                alignment: Alignment.centerLeft,
                child: Text('OTT',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              ottBox('assets/netflix_logo.png', '넷플릭스', 0),
              SizedBox(width: 20),
              ottBox('assets/tving_logo.png', '티빙', 1),
              SizedBox(width: 20),
              ottBox('assets/wavve_logo.png', '웨이브', 2),
            ]),
            SizedBox(height: 50),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('역할',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: roleButton('방장', isLeader == true, true))),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: roleButton('멤버', isLeader == false, false))),
              ],
            ),
            SizedBox(height: 50),
            if (hasSelectedService)
              Container(
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
                    Text('구독 금액',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text(subscriptionText,
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                  ],
                ),
              ),
            if (!hasSelectedService)
              Container(
                height: 100,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Center(
                  child: Text("서비스를 선택해주세요",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: isShareRoom == true ? navigateToChatRoom : (isStartMatching == true ? null : _handleAutoMatching),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffffdf24),
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isShareRoom == true ? '채팅방 이동' : (isStartMatching == true ? '자동매칭 진행 중' : '자동매칭'),
                  style: TextStyle(fontSize: 26)),
            ),
          ],
        ),
      ),
    );
  }
}
