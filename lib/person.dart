import 'dart:math';
import 'dart:ui';
import 'package:box2d_flame/box2d.dart';
import 'package:flutter/material.dart';
import 'package:sirflutter/simulation_flame.dart';

enum PersonState { Open, Sick, Recovered }

class Person {
  final FlameGame game;
  //Physic objects
  Body body;
  CircleShape shape;
  //Scale to get from rad/s to something in the game, I like the number 5
  double sensorScale = 5;
  //Draw class
  Paint paint;
  //Initial acceleration -> no movement as its (0,0)
  Vector2 acceleration = Vector2.zero();
  double finalScale = 0;
  double size = 7;
  //Colors
  final Color open = Colors.blue;
  final Color sick = Colors.red;
  final Color recover = Colors.green;
  final Random rnd = Random();
  double lastSpeedChange = 6;
  double sickTime = 0;
  PersonState currentState = PersonState.Open;

  //Generate the Person and phisyc behind
  Person(this.game, Vector2 position,
      {PersonState startingState = PersonState.Open}) {
    finalScale = game.screenRect.width / game.scale;
    shape = CircleShape(); //build in shape, just set the radius

    shape.radius = size;
    currentState = startingState ?? PersonState.Open;
    paint = Paint();
    paint.color = _getCurrentColor();

    BodyDef bd = BodyDef();
    bd.linearVelocity = acceleration;
    bd.position = position;
    bd.fixedRotation = false;
    bd.bullet = false;
    bd.type = BodyType.DYNAMIC;
    body = game.world.createBody(bd);
    body.userData = this;

    FixtureDef fd = FixtureDef();
    fd.density = 1;
    fd.restitution = 0;
    fd.friction = 0;
    fd.shape = shape;
    body.createFixtureFromFixtureDef(fd);
    var factor = rnd.nextDouble() > .5 ? 1.0 : -1.0;
    acceleration = Vector2(
        max(1, rnd.nextInt(game.sirSimulation.speed).toDouble()) * factor,
        max(1, rnd.nextInt(game.sirSimulation.speed).toDouble()) * factor);
  }

  Color _getCurrentColor() {
    switch (currentState) {
      case PersonState.Recovered:
        {
          return recover;
        }
      case PersonState.Sick:
        {
          return sick;
        }
      default:
        {
          return open;
        }
    }
  }

  //Draw the person
  void render(Canvas c) {
    //Simply draw the circle
    c.drawCircle(Offset(body.position.x, body.position.y), shape.radius, paint);
  }
  

  void update(double t) {
    //Our person has to move, every frame by its accelartion. If frame rates drop it will move slower...
    if (!game.screenRect.overlaps(
        Rect.fromLTWH(body.position.x, body.position.y, size, size))) {
      acceleration = Vector2.zero();
    }
    if (lastSpeedChange < 3) {
      lastSpeedChange += t;
    } else {
      lastSpeedChange = 0;
      acceleration = Vector2(
          max(5, rnd.nextInt(game.sirSimulation.speed).toDouble()) * (rnd.nextDouble() > .5 ? 1.0 : -1.0),
          max(5, rnd.nextInt(game.sirSimulation.speed).toDouble()) * (rnd.nextDouble() > .5 ? 1.0 : -1.0));
      body.linearVelocity = acceleration;
    }
    if(currentState == PersonState.Sick){
      sickTime +=t;
    }
    if(sickTime >= game.sirSimulation.recoveryTime){
      changeState(PersonState.Recovered);
    }
  }

  void changeState(PersonState sick) {
    currentState = sick;
    paint.color = _getCurrentColor();
  }
}
