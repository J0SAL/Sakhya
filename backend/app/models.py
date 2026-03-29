"""
models.py — SQLAlchemy ORM models.
Mirrors the Flutter UserProfile and DaySummary shapes.
"""
from sqlalchemy import Boolean, Column, Integer, String, Text
from .database import Base


class UserRecord(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    occupation = Column(String, default="Tailoring")
    monthly_goal = Column(Integer, default=5000)
    family_size = Column(Integer, default=4)
    location = Column(String, default="Rajasthan, India")
    daily_income_min = Column(Integer, default=300)
    daily_income_max = Column(Integer, default=700)
    daily_expense_min = Column(Integer, default=100)
    daily_expense_max = Column(Integer, default=250)
    total_savings = Column(Integer, default=0)
    lifetime_reward_points = Column(Integer, default=0)
    streak_days = Column(Integer, default=0)
    last_completed_date = Column(String, default="")
    lessons_completed = Column(Integer, default=0)


class DaySummaryRecord(Base):
    __tablename__ = "day_summaries"

    # Composite PK: user_id + date
    user_id = Column(String, primary_key=True)
    date = Column(String, primary_key=True)

    income_earned = Column(Integer, default=0)
    ghar_allocation = Column(Integer, default=0)
    dhanda_allocation = Column(Integer, default=0)
    household_expense = Column(Integer, default=0)
    savings = Column(Integer, default=0)
    reward_delta = Column(Integer, default=0)
    learning_reward_delta = Column(Integer, default=0)
    scam_reward_delta = Column(Integer, default=0)
    allocation_correct = Column(Boolean, default=False)
    scam_completed = Column(Boolean, default=False)
    scam_correct = Column(Boolean, default=False)
    lessons_attempted = Column(Integer, default=0)
    lessons_correct = Column(Integer, default=0)
    tasks_completed = Column(Text, default="[]")   # JSON array stored as text
    used_laxmi_didi_help = Column(Boolean, default=False)
