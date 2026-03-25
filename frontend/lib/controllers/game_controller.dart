import 'dart:collection';
import 'package:flutter/material.dart';

enum GameState {
  startDay,
  playingTask,
}

enum EventTask {
  scamCall,
  buySupplies,
  laxmiQuiz,
}

class GameController extends ChangeNotifier {
  int rewardPoints = 0;
  int homePotBalance = 0;
  int businessPotBalance = 0;
  int unallocatedIncome = 0;
  int streakDays = 2; 

  // Global Engine State
  GameState currentState = GameState.startDay;
  Queue<EventTask> dailyTasks = Queue<EventTask>();
  EventTask? currentTask;

  GameController() {}

  void startNewDay(int newIncome) {
    unallocatedIncome += newIncome;
    notifyListeners();
  }

  bool allocateIncome(String pot, int amount) {
    if (unallocatedIncome >= amount) {
      unallocatedIncome -= amount;
      if (pot == 'Home') {
        homePotBalance += amount;
      } else {
        businessPotBalance += amount;
      }
      
      // Automatic Transition trigger when successfully budgeted
      if (unallocatedIncome == 0) {
        _generateTasks();
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  void _generateTasks() {
    dailyTasks.clear();
    // 1. Mandatory Scam Call event
    dailyTasks.add(EventTask.scamCall);

    // 2. Conditional Financial Module based on generated Wealth
    if (businessPotBalance >= 100) {
      dailyTasks.add(EventTask.buySupplies);
    } else {
      dailyTasks.add(EventTask.laxmiQuiz);
    }

    _nextTask();
  }

  void completeCurrentTask(int rewardGranted, {int businessDeduction = 0}) {
    rewardPoints += rewardGranted;
    businessPotBalance -= businessDeduction;
    if (rewardPoints < 0) rewardPoints = 0;
    
    _nextTask();
  }

  void _nextTask() {
    if (dailyTasks.isEmpty) {
      // Loop resets!
      currentState = GameState.startDay;
    } else {
      currentTask = dailyTasks.removeFirst();
      currentState = GameState.playingTask;
    }
    notifyListeners();
  }

  bool buyItemWithPoints(int pointsCost) {
    if (rewardPoints >= pointsCost) {
      rewardPoints -= pointsCost;
      notifyListeners();
      return true;
    }
    return false;
  }
}
