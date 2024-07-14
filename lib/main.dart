import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  ComponentsGame game = ComponentsGame();
  runApp(GameWidget(game: game));
}

class ComponentsGame extends FlameGame with TapDetector, HasCollisionDetection {
  late GroupAnimation groupAnimation;

  @override
  Future<void> onLoad() async {
    groupAnimation = GroupAnimation();
    addAll([
      BgImage(),
       BridAnimationSprite(),
      groupAnimation,
      Bird(),
    ]);
  }

  @override
  void onTap (){
    groupAnimation.flying();
  }
}

///============simple sprite==================>
class Bird extends SpriteComponent{


  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bird.png');
    size = Vector2(200, 150);
    anchor = Anchor.bottomCenter; // Set the anchor as needed
    position = Vector2(200, 200);
  }
}

///=============just animation==============>
class BridAnimationSprite extends SpriteAnimationComponent
    with HasGameRef<ComponentsGame> {
  @override
  Future<void> onLoad() async {
    final spriteSheet = await Flame.images.load('bird.png');
    final spriteSize = Vector2(1000, 500);
    final animationSprite = SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
            amount: 2,
            stepTime: 0.01,
            textureSize: spriteSize
        )
    );

    this.animation = animationSprite;
    size = spriteSize;
    position = Vector2(300,100);
  }
}

///==================Back ground================>
class BgImage extends SpriteComponent with HasGameRef<ComponentsGame> {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bg.jpg');
    // size = Vector2(gameRef.size.y, gameRef.size.x);
    ///======fill this full=====>
    size = gameRef.size;
    position = Vector2(0, 0);
  }
}

///================group animation sprite==================>
class GroupAnimation extends SpriteAnimationGroupComponent with HasGameRef<ComponentsGame> {
  @override
  Future<void> onLoad() async{
    final middle = await gameRef.loadSprite('bird_midflap.png');
    final down = await gameRef.loadSprite('bird_downflap.png');
    final up = await gameRef.loadSprite('bird_upflap.png');


    animations = {
      BirdMovment.middle: SpriteAnimation.spriteList([middle], stepTime: 0.1),
      BirdMovment.down : SpriteAnimation.spriteList([down], stepTime: .1),
      BirdMovment.up : SpriteAnimation.spriteList([up], stepTime: 0.1)
    };

    current = BirdMovment.middle;
    size = Vector2(50, 50);
    position = gameRef.size / 2;
  }


  @override
  void update(double dt) {
    super.update(dt);
    position.y += 100 *dt;

    if(position.y < 1 || position.y > gameRef.size.y){
      print("========game over");
    }
    print('=====$dt');
  }

  void flying(){
    add(MoveByEffect(Vector2(0, -200), EffectController(
      duration: 0.3,
      curve: Curves.decelerate),
      onComplete: () => current = BirdMovment.down,
    ));
    current = BirdMovment.up;
  }
}

enum BirdMovment{up, down, middle}


