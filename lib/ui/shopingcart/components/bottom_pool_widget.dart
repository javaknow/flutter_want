

import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/ui/shopingcart/model/itemPoolBarModel.dart';

class BottomPoolWidget extends StatelessWidget {
  final ItemPoolBarModel itemPoolBarModel;
  const BottomPoolWidget({Key key, this.itemPoolBarModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
      height: 45,
      decoration: BoxDecoration(
          color: backWhite,
          border: Border(top: BorderSide(color: lineColor,width: 0.5))
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小计：¥${itemPoolBarModel.subtotalPrice}',
                  style: t14redBold,
                ),
                Text(
                  '${itemPoolBarModel.promTip.replaceAll('#', '')}',
                  style: t12black,
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              height: double.infinity,
              color: backRed,
              alignment: Alignment.center,
              child: Text(
                '去购物车',
                style: t16white,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}