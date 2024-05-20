import 'package:flutter/cupertino.dart';

class CheckDrawer extends StatefulWidget {
  const CheckDrawer({super.key});

  @override
  _CheckDrawerState createState() => _CheckDrawerState();
}

class _CheckDrawerState extends State<CheckDrawer> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('Survey Form'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}