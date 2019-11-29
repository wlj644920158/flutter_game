import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

class Bullet extends SpriteComponent {
  bool live = true; //是否活着
  double fly_speed; //子弹的飞行速度
  Size size;

  Bullet.role() {
    fly_speed = 8;
    width = 8;
    height = 20;
    sprite = Sprite('bullet2.png');
  }

  void resize(Size s) {
    this.size = s;
    x = Random().nextDouble() * size.width;
    y = -this.height;
  }

  /// 判断是否可以被移除了
  bool destroy() {
    return !live;
  }
}
