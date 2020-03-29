import 'dart:math';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/flame.dart';
import 'package:flame/game/game.dart';
import 'package:flutter/material.dart';
import 'package:sirflutter/person.dart';
import 'package:sirflutter/simulation_data.dart';

typedef dayFinishedCallback = Function(
    int day, int susceptible, int infectious, int recovered);

class FlameGame extends Game implements ContactListener, ContactFilter {
  SirSimulation sirSimulation = SirSimulation();
  final VoidCallback noInfectedLeft;
  final Random random = Random();
  final textStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
  );
  static const int WORLD_POOL_SIZE = 100;
  static const int WORLD_POOL_CONTAINER_SIZE = 10;
  //Main physic object -> our game world
  World world;
  //Zero vector -> no gravity
  final Vector2 _gravity = Vector2.zero();
  //Scale factore for our world
  final int scale = 7;
  //Size of the screen from the resize event
  Rect screenRect;
  final List<Person> persons = List<Person>();
  double days = 0;
  final dayFinishedCallback dayFinished;
  FlameGame(this.dayFinished, this.noInfectedLeft) {
    world = new World.withPool(
        _gravity, DefaultWorldPool(WORLD_POOL_SIZE, WORLD_POOL_CONTAINER_SIZE));
    world.setContactFilter(this);
    world.setContactListener(this);
    initialize();
  }

  Future initialize() async {
    //Call the resize as soon as flutter is ready
    resize(await Flame.util.initialDimensions());
    reset(sirSimulation);
  }

  void resize(Size size) {
    if (screenRect != null) {
      return;
    }
    //Store size and related rectangle
    screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    super.resize(size);
  }

  bool get _runSimulation {
    return sirSimulation.simulationRunning && screenRect != null;
  }

  void reset(SirSimulation simulation) {
    sirSimulation = simulation;
    persons.forEach((p) => world.destroyBody(p.body));
    persons.clear();
    var infectedRemaning = sirSimulation.startInfected;
    for (var i = 0; i < sirSimulation.totalPersons; i++) {
      var state = PersonState.Open;
      if (infectedRemaning > 0) {
        state = PersonState.Sick;
        infectedRemaning -= 1;
      }
      persons.add(Person(this, _getRandomPointInFrame(), startingState: state));
    }
    days = 0;
  }

  Vector2 _getRandomPointInFrame() {
    return Vector2(
      max<double>(16, random.nextInt(screenRect.width.toInt() - 16).toDouble()),
      max<double>(
          16, random.nextInt(screenRect.height.toInt() - 16).toDouble()),
    );
  }

  @override
  void render(Canvas canvas) {
    if (persons.length > 0 && screenRect != null) {
      persons.forEach((person) => person.render(canvas));
      final textSpan = TextSpan(
        text: 'Days: ${days.toStringAsFixed(2)}\n'
            'Susceptible: ${persons.where((p) => p.currentState == PersonState.Open).length}\n'
            'Infectious: ${persons.where((p) => p.currentState == PersonState.Sick).length}\n'
            'Recovered: ${persons.where((p) => p.currentState == PersonState.Recovered).length}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: screenRect.width,
      );
      final offset = Offset(3, 5);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  void update(double t) {
    if (_runSimulation) {
      world.stepDt(t, 100, 100);
      persons.forEach((person) => person.update(t));
      dayFinished(
        (days + t).toInt(),
        persons.where((p) => p.currentState == PersonState.Open).length,
        persons.where((p) => p.currentState == PersonState.Sick).length,
        persons.where((p) => p.currentState == PersonState.Recovered).length,
      );
      days += t;
      if (persons.where((p) => p.currentState == PersonState.Sick).length ==
          0) {
        sirSimulation.simulationRunning = false;
        noInfectedLeft();
      }
    }
  }

  @override
  void beginContact(Contact contact) {
    var personA = contact.fixtureA.getBody().userData as Person;
    var personB = contact.fixtureB.getBody().userData as Person;
    //If both have the same state no change is required
    if (personA.currentState == personB.currentState) {
      return;
    }
    var rnd = random.nextInt(100);
    if (personA.currentState == PersonState.Open &&
        personB.currentState == PersonState.Sick) {
      //Possible to infect a person
      if (sirSimulation.infectionRate >= rnd) {
        personA.changeState(PersonState.Sick);
      }
    } else if (personA.currentState == PersonState.Sick &&
        personB.currentState == PersonState.Open) {
      if (sirSimulation.infectionRate >= rnd) {
        personB.changeState(PersonState.Sick);
      }
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}

  @override
  bool shouldCollide(Fixture fixtureA, Fixture fixtureB) {
    //Everything we simulate should collide
    return true;
  }
}
