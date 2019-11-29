import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart' as prefix0;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/bullet/bullet.dart';
import 'package:flutter_game/enemy/enemy.dart';


class FlyGame extends Game with PanDetector, TapDetector {
  Size size;

  bool roleSelected = false; //手指按下的时候是否选中了飞机
  bool pauseSelected = false; //手指按下的时候是否暂停按钮
  double lastDx, lastDy; //用来控制飞机的拖拽
  double role_bullet_space = 0.2; //飞机子弹时间间隔
  double role_bullet_time = 0.0;

  int damage = 1; //当前飞机的伤害,后面会加入补给品

  SpriteComponent bg1;
  SpriteComponent bg2;
  AnimationComponent role;
  SpriteComponent pauseBtn;

  List<Enemy> enemies = []; //敌机集合
  List<AnimationComponent> enemy_booms = []; //敌机爆炸集合
  List<Bullet> role_bullets = []; //飞机子弹集合

  TextConfig scoreConfig;
  int score = 0;

  bool paused = false; //当前是否是暂停状态

  FlyGame() {
    bg1 = SpriteComponent.fromSprite(0, 0, new Sprite('background.png'));
    bg2 = SpriteComponent.fromSprite(0, 0, new Sprite('background.png'));
    List<Sprite> roleSprites =
        [1, 2].map((i) => new Sprite('me$i.png')).toList();
    role = AnimationComponent(
        102.0, 126.0, prefix0.Animation.spriteList(roleSprites, stepTime: 0.1));

    pauseBtn = SpriteComponent.fromSprite(60, 45, Sprite('pause_nor.png'));
    scoreConfig = TextConfig(color: Colors.red);
  }

  void generateEnemyBom(int type, double x, double y) {
    if (type == 1) {
      List<Sprite> sprites =
          [1, 2, 3, 4].map((i) => new Sprite('enemy1_down$i.png')).toList();
      var b = AnimationComponent(57.0, 51.0,
          prefix0.Animation.spriteList(sprites, stepTime: 0.1, loop: false),
          destroyOnFinish: true);
      b.x = x;
      b.y = y;
      enemy_booms.add(b);
    } else if (type == 2) {
      List<Sprite> sprites =
          [1, 2, 3, 4].map((i) => new Sprite('enemy2_down$i.png')).toList();
      var b = AnimationComponent(69.0, 99.0,
          prefix0.Animation.spriteList(sprites, stepTime: 0.1, loop: false),
          destroyOnFinish: true);
      b.x = x;
      b.y = y;
      enemy_booms.add(b);
    } else if (type == 3) {
      List<Sprite> sprites = [1, 2, 3, 4, 5, 6]
          .map((i) => new Sprite('enemy3_down$i.png'))
          .toList();
      var b = AnimationComponent(165.0, 261.0,
          prefix0.Animation.spriteList(sprites, stepTime: 0.1, loop: false),
          destroyOnFinish: true);
      b.x = x;
      b.y = y;
      enemy_booms.add(b);
    }
  }

  void generateEnemy(double r) {
    var e;
    if (r < 0.6) {
      e = Enemy.level1();
    } else if (r < 0.9) {
      e = Enemy.level2();
    } else if (r < 1.0) {
      e = Enemy.level3();
    }
    e.resize(size);
    enemies.add(e);
  }

  void generateRoleBullet() {
    var b = Bullet.role();
    b.x = role.x + role.width / 2 - b.width / 2;
    b.y = role.y - b.y;
    role_bullets.add(b);
  }

  void resize(Size size) {
    this.size = size;

    bg1.width = size.width;
    bg1.height = size.height;

    bg1.y = -size.height;

    bg2.y = 0.0;

    bg2.width = size.width;
    bg2.height = size.height;

    role.x = size.width / 2 - role.width / 2;
    role.y = size.height - role.height;

    super.resize(size);
  }

  @override
  void render(Canvas canvas) {
//    Rect bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
//    Paint paint=Paint();
//    paint.color=Colors.grey[400];
//    canvas.drawRect(bgRect, paint);

    canvas.save();
    bg1.render(canvas);
    canvas.restore();

    canvas.save();
    bg2.render(canvas);
    canvas.restore();

    canvas.save();
    role.render(canvas);
    canvas.restore();

    canvas.save();
    pauseBtn.render(canvas);
    canvas.restore();

    enemies.forEach((e) {
      canvas.save();
      e.render(canvas);
      canvas.restore();
    });

    enemy_booms.forEach((e) {
      canvas.save();
      e.render(canvas);
      canvas.restore();
    });

    role_bullets.forEach((b) {
      canvas.save();
      b.render(canvas);
      canvas.restore();
    });

    scoreConfig.render(
        canvas, score.toString(), Position(size.width - 100, 20));
  }

  void update(double t) {
    if (paused) return;
    if (size == null) return;
    role.update(t);
    role_bullet_time += t;

    //先销毁死亡的精灵
    enemies.removeWhere((e) => e.destroy());
    role_bullets.removeWhere((e) => e.destroy());
    enemy_booms.removeWhere((e) => e.destroy());

    //更新背景
    bg1.y += 1.0;
    bg2.y += 1.0;

    if (bg1.y >= size.height) {
      bg1.y = -size.height;
    }

    if (bg2.y >= size.height) {
      bg2.y = -size.height;
    }

    enemies.forEach((e) {
      e.y += e.fly_speed;
      if (e.y > size.height) {
        e.live = false;
      }
    });

    role_bullets.forEach((b) {
      b.y -= b.fly_speed;
      if (b.y < 0) {
        b.live = false;
      }
    });

    //生成敌机
    if (enemies.length < 3) {
      generateEnemy(Random().nextDouble());
    }

    if (role_bullet_time > role_bullet_space) {
      generateRoleBullet();
      role_bullet_time = 0.0;
    }

    //碰撞检测
    role_bullets.forEach((b) {
      enemies.forEach((e) {
        Rect rect = b.toRect().intersect(e.toRect());
        if (rect.width > 1 && rect.height > 1) {
          //发生了碰撞
          e.blood -= damage;
          b.live = false;

          if (e.blood <= 0) {
            e.live = false;

            if (e.type == 1) {
              score += 1;
            } else if (e.type == 2) {
              score += 3;
            } else if (e.type == 3) {
              score += 10;
            }
            generateEnemyBom(e.type, e.x, e.y);
          }
        }
      });
    });

    enemy_booms.forEach((b) {
      b.update(t);
    });
  }

  void onTapDown(TapDownDetails details) {
    if (pauseBtn.toRect().contains(details.globalPosition)) {
      pauseBtn.sprite =
          Sprite(paused ? 'resume_pressed.png' : 'pause_pressed.png');
      pauseSelected = true;
    }
  }

  void onTapUp(TapUpDetails details) {
    if (pauseSelected) {
      paused = !paused;
      pauseBtn.sprite = Sprite(paused ? 'resume_nor.png' : 'pause_nor.png');
    }
  }

  void onPanDown(DragDownDetails details) {
    if (paused) return;
    if (role.toRect().contains(details.globalPosition)) {
      roleSelected = true;
      lastDx = details.globalPosition.dx;
      lastDy = details.globalPosition.dy;
    }
  }

  void onPanStart(DragStartDetails details) {
    if (paused) return;
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (paused) return;
    if (roleSelected) {
      double deltaX = details.globalPosition.dx - lastDx;
      double deltaY = details.globalPosition.dy - lastDy;
      role.x += deltaX;
      role.y += deltaY;
      lastDx = details.globalPosition.dx;
      lastDy = details.globalPosition.dy;
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (paused) return;
    roleSelected = false;
  }

  void onPanCancel() {
    if (paused) return;
    roleSelected = false;
  }
}
