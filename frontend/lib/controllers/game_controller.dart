import 'package:flutter/material.dart';

class GameController extends ChangeNotifier {
  int rewardPoints = 0;
  int homePotBalance = 0;
  int businessPotBalance = 0;
  int unallocatedIncome = 0;
  int streakDays = 2; // Duolingo style streak counter

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
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buyItemWithPoints(int pointsCost) {
    if (rewardPoints >= pointsCost) {
      rewardPoints -= pointsCost;
      notifyListeners();
      return true;
    }
    return false;
  }

  void completeScamEncounter(bool success) {
    if (success) {
      rewardPoints += 50;
    } else {
      rewardPoints -= 20;
    }
    notifyListeners();
  }

  void completeUpiPayment() {
    if (businessPotBalance >= 100) {
      businessPotBalance -= 100;
      rewardPoints += 20;
      notifyListeners();
    }
  }
}
