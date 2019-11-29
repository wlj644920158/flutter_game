import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

class Enemy extends SpriteComponent {
  bool live = true; //是否活着
  int type;
  double fly_speed; //敌机飞行速度

  Size size;

  int blood;

  Enemy.level1() {
    this.width = 57;
    this.height = 43;
    this.sprite = Sprite('enemy1.png');
    this.fly_speed = 6;
    blood = 1;
    type = 1;
  }

  Enemy.level2() {
    this.width = 69;
    this.height = 99;
    this.sprite = Sprite('enemy2.png');
    this.fly_speed = 4;
    type = 2;
    blood = 3;
  }

  Enemy.level3() {
    this.width = 169;
    this.height = 258;
    this.sprite = Sprite('enemy3_n1.png');
    this.fly_speed = 3;
    type = 3;
    blood = 10;
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
