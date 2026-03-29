"""
schemas.py — Pydantic v2 request/response schemas.
Field names match the Flutter JSON keys exactly.
"""
from typing import List
from pydantic import BaseModel


class UserProfileSchema(BaseModel):
    id: str
    name: str
    occupation: str = "Tailoring"
    monthlyGoal: int = 5000
    familySize: int = 4
    location: str = "Rajasthan, India"
    dailyIncomeMin: int = 300
    dailyIncomeMax: int = 700
    dailyExpenseMin: int = 100
    dailyExpenseMax: int = 250
    totalSavings: int = 0
    lifetimeRewardPoints: int = 0
    streakDays: int = 0
    lastCompletedDate: str = ""
    lessonsCompleted: int = 0


class DaySummarySchema(BaseModel):
    userId: str
    date: str
    incomeEarned: int = 0
    gharAllocation: int = 0
    dhandaAllocation: int = 0
    householdExpense: int = 0
    savings: int = 0
    rewardDelta: int = 0
    learningRewardDelta: int = 0
    scamRewardDelta: int = 0
    allocationCorrect: bool = False
    scamCompleted: bool = False
    scamCorrect: bool = False
    lessonsAttempted: int = 0
    lessonsCorrect: int = 0
    tasksCompleted: List[str] = []
    usedLaxmiDidiHelp: bool = False


class SyncResponse(BaseModel):
    status: str = "synced"
