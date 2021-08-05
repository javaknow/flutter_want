import 'package:flutter/material.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/ui/router/router.dart';

typedef void EditPress();

class CartNavBarWidget extends StatelessWidget {
  final bool isEdit;
  final EditPress editPress;

  const CartNavBarWidget({Key key, this.isEdit, this.editPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _navBar(context);
  }

  _navBar(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(bottom: BorderSide(color: backColor,width: 1))
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '购物车',
                style: t16black,
              ),
            ),
          ),
          isEdit
              ? Container()
              : GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/lingquan.png'),
                      ),
                    ),
                    child: Text(
                      '领券',
                      style: t12white,
                    ),
                  ),
                  onTap: () {
                    Routers.push(Routers.webView, context,
                        {'url': 'https://m.you.163.com/coupon/cartCoupon'});
                  },
                ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              if (editPress != null) {
                editPress();
              }
            },
            child: Text(
              isEdit ? '完成' : '编辑',
              style: t14black,
            ),
          )
        ],
      ),
    );
  }
}