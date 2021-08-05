import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constant/colors.dart';
import 'package:flutter_app/constant/fonts.dart';
import 'package:flutter_app/ui/router/router.dart';
import 'package:flutter_app/ui/shopingcart/components/cart_num_filed.dart';
import 'package:flutter_app/ui/shopingcart/model/carItem.dart';
import 'package:flutter_app/ui/shopingcart/model/cartItemListItem.dart';
import 'package:flutter_app/ui/shopingcart/model/redeemModel.dart';
import 'package:flutter_app/utils/toast.dart';
import 'package:flutter_app/widget/cart_check_box.dart';
import 'package:flutter_app/widget/global.dart';
import 'package:flutter_app/widget/shopping_cart_count.dart';
import 'package:flutter_app/widget/timer_text.dart';

typedef void NumChange(num source, num type, num skuId, num cnt, String extId);
typedef void CheckOne(CarItem itemData, num source, num type, num skuId,
    bool check, String extId);

typedef void DeleteCheckItem(
    bool check, CarItem itemData, CartItemListItem item);
typedef void GoRedeem(CarItem itemData);
typedef void SkuClick(CartItemListItem item);

const double _checkBoxWith = 40.0;
const double _imageWith = 90.0;

///购物车条目
class CartItemWidget extends StatelessWidget {
  final SkuClick skuClick;
  final NumChange numChange;
  final CheckOne checkOne;
  final GoRedeem goRedeem;
  final DeleteCheckItem deleteCheckItem;
  final List<CarItem> itemList;
  final bool isEdit;
  final TextEditingController controller;

  const CartItemWidget(
      {Key key,
      this.numChange,
      this.checkOne,
      this.goRedeem,
      this.deleteCheckItem,
      this.itemList,
      this.isEdit,
      this.controller,
      this.skuClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        CarItem itemData = itemList[index];
        List<CartItemListItem> _itemList = [];

        ///换购
        List<AddBuyStepListItem> addBuyStepList = itemData.addBuyStepList;
        if (addBuyStepList != null && addBuyStepList.isNotEmpty) {
          addBuyStepList.forEach((element_1) {
            var addBuyItemList = element_1.addBuyItemList;
            if (addBuyItemList != null && addBuyItemList.isNotEmpty) {
              addBuyItemList.forEach((element_2) {
                if (element_2.checked) {
                  _itemList.add(element_2);
                }
              });
            }
          });
        }
        var cartItemList = itemData.cartItemList;
        _itemList.addAll(cartItemList);

        List<Widget> itemItems = [];
        if (index != 0) {
          itemItems.add(_line());
        }

        ///换购，满减
        itemItems.add(_redeem(itemData, index, context));
        List<Widget> goodWidget = _itemList.map<Widget>((item) {
          return _buildItem(context, itemData, item, index);
        }).toList();
        itemItems.addAll(goodWidget);
        return Column(
          children: itemItems,
        );
      },
      itemCount: itemList.length,
    );
  }

  /// 有效商品列表Item
  _buildItem(BuildContext context, CarItem itemData, CartItemListItem item,
      int index) {
    List<String> cartItemTips = item.cartItemTips;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///顶部活动
          _buildActivity(item),

          ///主体
          _buildMainContent(itemData, item, index, context),

          ///比加入时省多钱
          _buildSaveMoney(item),

          ///自营仓库免邮
          _freeShipping(item),
          _cartItemTips(cartItemTips),
          SizedBox(height: 10),
          Divider(
            indent: _checkBoxWith,
            height: 1,
          )
        ],
      ),
    );
  }

  _buildActivity(CartItemListItem item) {
    if (item.timingPromotion == null || item.timingPromotion == '') {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(left: _checkBoxWith, top: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: backYellow, width: 0.5)),
            child: Text(
              '${item.timingPromotion}',
              style: t12Orange,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              '${item.finishTip}',
              style: t12black,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            child: TimerText(
              time: item.remainTime ~/ 1000,
              textStyle: t12blackbold,
            ),
          ),
        ],
      ),
    );
  }

  ///免邮
  _freeShipping(CartItemListItem item) {
    if (item.warehouseInfo == null) {
      return Container();
    }
    var warehouseInfo = item.warehouseInfo;
    return Container(
      margin: EdgeInsets.only(left: _checkBoxWith, top: 8, right: 10),
      child: Row(
        children: [
          Image.asset(
            'assets/images/house_icon.png',
            width: 14,
            height: 14,
          ),
          SizedBox(width: 5),
          Text(
            '${warehouseInfo.desc}',
            style: t12grey,
          ),
        ],
      ),
    );
  }

  _cartItemTips(List<String> cartItemTips) {
    return (cartItemTips == null || cartItemTips.length == 0)
        ? Container()
        : Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            margin: EdgeInsets.only(left: _checkBoxWith, right: 10, top: 8),
            decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cartItemTips.map((item) {
                return Container(
                  child: Text(
                    '• $item',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }

  _buildMainContent(CarItem itemData, CartItemListItem item, int index,
      BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          ///选择⭕️
          _buildCheckBox(itemData, item, index),

          ///图片
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  color: backGrey, borderRadius: BorderRadius.circular(4)),
              height: _imageWith,
              width: _imageWith,
              child: CachedNetworkImage(imageUrl: item.pic ?? ''),
            ),
            onTap: () {
              _goDetail(context, item);
            },
          ),
          _buildDes(item, context)
        ],
      ),
    );
  }

  _buildDes(CartItemListItem item, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isEdit
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(left: 10),
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: t14black,
                          children: [
                            TextSpan(
                                text:
                                    '${item.promTag ?? (item.id == 0 ? '换购' : '')}',
                                style: t14Yellow),
                            TextSpan(text: '${item.itemName ?? ''}'),
                          ],
                        ),
                      ),
                    ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: lineColor, width: 0.5),
                    borderRadius: BorderRadius.circular(2),
                    color: Color(0xFFFAFAFA),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 2),
                        child: Text(
                          '${_specValue(item)}',
                          style: t12grey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      item.id != 0
                          ? Image.asset(
                              'assets/images/arrow_down.png',
                              width: 10,
                              height: 10,
                            )
                          : Container()
                    ],
                  ),
                ),
                onTap: () {
                  if (item.id != 0) {
                    if (skuClick != null) {
                      skuClick(item);
                    }
                  }
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        '¥${item.actualPrice}',
                        style: t14blackBold,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          item.retailPrice > item.actualPrice
                              ? '¥${item.retailPrice}'
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: textGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: CartCount(
                        number: item.cnt,
                        min: 1,
                        max: item.id == 0 ? 1 : item.sellVolume,
                        onChange: (numValue) {
                          if (numChange != null) {
                            numChange(item.source, item.type, item.skuId,
                                numValue, item.extId);
                          }
                        },
                        numClick: () {
                          if (item.id != 0) {
                            _showNumClickDialog(context, item);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          _goDetail(context, item);
        },
      ),
    );
  }

  _showNumClickDialog(BuildContext context, CartItemListItem item) {
    controller.text = item.cnt.toString();
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
                // border: Border.all(color: textGrey, width: 1),
                // borderRadius: BorderRadius.circular(4),
                ),
            child: CartTextFiled(
              controller: controller,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                '取消',
                style: t16grey,
              ),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                '确认',
                style: t16red,
              ),
              onPressed: () {
                if (!controller.text.isEmpty) {
                  if (num.parse(controller.text.toString()) > item.sellVolume) {
                    Toast.show('不能超过最大库存量(${item.sellVolume})', context,
                        duration: 3);
                    return;
                  }
                  numChange(item.source, item.type, item.skuId,
                      num.parse(controller.text.toString()), item.extId);
                  Navigator.of(context).pop();
                  // item.cnt = int.parse(controller.text.toString());
                }
              },
            ),
          ],
        );
      },
    );
  }

  _buildSaveMoney(CartItemListItem item) {
    return item.priceReductDesc == null || item.priceReductDesc.isEmpty
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            margin: EdgeInsets.only(
                left: _checkBoxWith + _imageWith + 10, right: 10),
            decoration: BoxDecoration(
                border: Border.all(color: backYellow, width: 0.5),
                borderRadius: BorderRadius.circular(2)),
            child: Text(
              '${item.priceReductDesc}',
              style: t10Orange,
            ),
          );
  }

  ///左侧选择框，编辑框
  _buildCheckBox(CarItem itemData, CartItemListItem item, int index) {
    if (isEdit) {
      return Container(
        width: _checkBoxWith,
        child: CartCheckBox(
          canCheck: true,
          onCheckChanged: (check) {
            if (deleteCheckItem != null) {
              deleteCheckItem(check, itemData, item);
            }
          },
        ),
      );
    } else {
      return Container(
        width: _checkBoxWith,
        child: InkWell(
          onTap: () {
            if (itemData.canCheck || item.checked) {
              if (checkOne != null) {
                if (item.id != 0 && item.id != null) {
                  checkOne(itemData, item.source, item.type, item.skuId,
                      !item.checked, item.extId);
                }
              }
            }
          },
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(2),
              child: item.id == 0
                  ? Icon(
                      Icons.check_circle,
                      size: 22,
                      color: Color(0xFFDBDBDB),
                    )
                  : (item.checked
                      ? Icon(
                          Icons.check_circle,
                          size: 22,
                          color: redColor,
                        )
                      : Icon(
                          Icons.brightness_1_outlined,
                          size: 22,
                          color: itemData.canCheck
                              ? Color(0xFFDBDBDB)
                              : Color(0xFFF7F6FA),
                        )),
            ),
          ),
        ),
      );
    }
  }

  _redeem(CarItem itemData, int index, BuildContext context) {
    if (itemData.promTip != null) {
      if (itemData.promType == 4) {
        ///换购
        return Container(
          color: backWhite,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      margin: EdgeInsets.only(left: _checkBoxWith / 2),
                      decoration: BoxDecoration(
                        color: redLightColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        index == 0 ? '全场换购' : '换购',
                        style: t12white,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${itemData.promTip}',
                          style: t14black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Text(
                            '${itemData.promotionBtn == 3 ? '再逛逛' : '去凑单'}',
                            style: t12red,
                          ),
                          arrowRightRed10Icon
                        ],
                      ),
                      onTap: () {
                        Routers.push(Routers.webView, context, {
                          'url':
                              'https://m.you.163.com/cart/itemPool?promotionId=${itemData.promId}'
                        });
                      },
                    )
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF7F5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  margin: EdgeInsets.fromLTRB(_checkBoxWith, 0, 15, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          itemData.promSatisfy ? '去换购商品' : '查看换购商品',
                          style: t12black,
                        ),
                      ),
                      arrowRightIcon
                    ],
                  ),
                ),
                onTap: () {
                  if (goRedeem != null) {
                    goRedeem(itemData);
                  }
                },
              ),
            ],
          ),
        );
      } else if (itemData.promType == 108) {
        ///满减
        return Container(
          color: backWhite,
          padding: EdgeInsets.only(left: _checkBoxWith, top: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 6),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: redLightColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '满额减',
                  style: t12white,
                ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${itemData.promTip}',
                  style: t14black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              GestureDetector(
                child: Row(
                  children: [
                    Text(
                      '去凑单',
                      style: t12red,
                    ),
                    arrowRightRed10Icon
                  ],
                ),
                onTap: () {
                  Routers.push(Routers.webView, context, {
                    'url':
                        'https://m.you.163.com/cart/itemPool?promotionId=${itemData.promId}'
                  });
                },
              )
            ],
          ),
        );
      }
    }
    return Container();
  }

  _specValue(CartItemListItem item) {
    List<SpecListItem> specList = item.specList;
    String specName = '';
    for (var value in specList) {
      specName += value.specValue;
      specName += "; ";
    }
    var replaceRange =
        specName.replaceRange(specName.length - 2, specName.length - 1, "");
    return replaceRange;
  }

  void _goDetail(BuildContext context, CartItemListItem itemData) {
    Routers.push(
        Routers.goodDetailTag, context, {'id': itemData.itemId.toString()});
  }

  _line() {
    return Container(
      height: 10,
      color: backColor,
    );
  }
}