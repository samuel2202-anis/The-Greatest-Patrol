import 'package:flutter/material.dart';

import '../theme.dart';

class FinishWidget extends StatelessWidget {
  const FinishWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: secondColor,
        title: Text('انتهت اللعبة !',style: TextStyle(
          fontSize: 20,
          fontFamily: '18 Khebrat',
          color: primaryColor,
        ),textAlign: TextAlign.center,),
        content: Text('لقد تم تسليم جميع التحديات بنجاح',style: TextStyle(
          fontSize: 16,
          fontFamily: '18 Khebrat',
          color: primaryColor,
        ),textAlign: TextAlign.center,),
        actions: <Widget>[
          TextButton(
            child: Text('اغلاق',style: TextStyle(
              fontSize: 16,
              fontFamily: '18 Khebrat',
              color: primaryColor,
            ),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}