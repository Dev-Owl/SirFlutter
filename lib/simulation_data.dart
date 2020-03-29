//This class contains all needed information to run the simulation
class SirSimulation {
  bool settingsShown = false;
  bool simulationRunning = false;
  int totalPersons = 100;
  int startInfected = 1;
  int infectionRate = 10;
  int speed = 20;
  int recoveryTime = 5;

  SirSimulation(
      {this.totalPersons = 100,
      this.startInfected = 1,
      this.infectionRate = 10,
      this.speed = 20,
      this.recoveryTime = 5});

  SirSimulation copy() {
    return SirSimulation(
        infectionRate: infectionRate,
        totalPersons: totalPersons,
        startInfected: startInfected,
        speed: speed,
        recoveryTime: recoveryTime)
      ..settingsShown = settingsShown
      ..simulationRunning = simulationRunning;
  }

  void reset() {
    simulationRunning = false;
    totalPersons = 100;
    startInfected = 1;
    infectionRate = 10;
    speed = 10;
    recoveryTime = 50;
  }
}
