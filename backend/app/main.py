"""
main.py — FastAPI application for Sakhya Phase-III backend.
Provides health check and sync endpoints for UserProfile and DaySummary.
Only used by the Flutter app when internet is available.
"""
import json
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from .database import Base, engine, get_session
from .models import DaySummaryRecord, UserRecord
from .schemas import DaySummarySchema, SyncResponse, UserProfileSchema

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create tables on startup if they don't exist."""
    logger.info("🚀 Starting Sakhya backend — running DB migrations...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    logger.info("✅ DB tables ready.")
    yield
    logger.info("🛑 Shutting down Sakhya backend.")


app = FastAPI(
    title="Sakhya Sync API",
    description="Offline-first sync backend for the Sakhya financial literacy app.",
    version="1.0.0",
    lifespan=lifespan,
)

# Allow all origins — the app runs on a mobile device, not a browser
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Health ─────────────────────────────────────────────────────────────────────

@app.get("/health", tags=["Health"])
async def health():
    """
    Liveness probe. Flutter checks this before deciding whether to sync.
    Returns {"status": "ok"} when the backend + DB are reachable.
    """
    try:
        async with get_session() as session:
            await session.execute(text("SELECT 1"))
        return {"status": "ok"}
    except Exception as exc:
        logger.error("Health check failed: %s", exc)
        return {"status": "error", "detail": str(exc)}


# ── Sync: User ─────────────────────────────────────────────────────────────────

@app.post("/sync/user", response_model=SyncResponse, tags=["Sync"])
async def sync_user(payload: UserProfileSchema):
    """
    Upsert a UserProfile into the online DB.
    Called by Flutter after every local user save, only when online.
    """
    async with get_session() as session:
        existing = await session.get(UserRecord, payload.id)
        if existing:
            existing.name = payload.name
            existing.occupation = payload.occupation
            existing.monthly_goal = payload.monthlyGoal
            existing.family_size = payload.familySize
            existing.location = payload.location
            existing.daily_income_min = payload.dailyIncomeMin
            existing.daily_income_max = payload.dailyIncomeMax
            existing.daily_expense_min = payload.dailyExpenseMin
            existing.daily_expense_max = payload.dailyExpenseMax
            existing.total_savings = payload.totalSavings
            existing.lifetime_reward_points = payload.lifetimeRewardPoints
            existing.streak_days = payload.streakDays
            existing.last_completed_date = payload.lastCompletedDate
            existing.lessons_completed = payload.lessonsCompleted
        else:
            session.add(UserRecord(
                id=payload.id,
                name=payload.name,
                occupation=payload.occupation,
                monthly_goal=payload.monthlyGoal,
                family_size=payload.familySize,
                location=payload.location,
                daily_income_min=payload.dailyIncomeMin,
                daily_income_max=payload.dailyIncomeMax,
                daily_expense_min=payload.dailyExpenseMin,
                daily_expense_max=payload.dailyExpenseMax,
                total_savings=payload.totalSavings,
                lifetime_reward_points=payload.lifetimeRewardPoints,
                streak_days=payload.streakDays,
                last_completed_date=payload.lastCompletedDate,
                lessons_completed=payload.lessonsCompleted,
            ))
    logger.info("✅ Synced user: %s (%s)", payload.id, payload.name)
    return SyncResponse()


# ── Sync: Day Summary ──────────────────────────────────────────────────────────

@app.post("/sync/summary", response_model=SyncResponse, tags=["Sync"])
async def sync_summary(payload: DaySummarySchema):
    """
    Upsert a DaySummary into the online DB.
    Called by Flutter after every local summary save, only when online.
    """
    tasks_json = json.dumps(payload.tasksCompleted, ensure_ascii=False)
    async with get_session() as session:
        existing = await session.get(DaySummaryRecord, (payload.userId, payload.date))
        if existing:
            existing.income_earned = payload.incomeEarned
            existing.ghar_allocation = payload.gharAllocation
            existing.dhanda_allocation = payload.dhandaAllocation
            existing.household_expense = payload.householdExpense
            existing.savings = payload.savings
            existing.reward_delta = payload.rewardDelta
            existing.learning_reward_delta = payload.learningRewardDelta
            existing.scam_reward_delta = payload.scamRewardDelta
            existing.allocation_correct = payload.allocationCorrect
            existing.scam_completed = payload.scamCompleted
            existing.scam_correct = payload.scamCorrect
            existing.lessons_attempted = payload.lessonsAttempted
            existing.lessons_correct = payload.lessonsCorrect
            existing.tasks_completed = tasks_json
            existing.used_laxmi_didi_help = payload.usedLaxmiDidiHelp
        else:
            session.add(DaySummaryRecord(
                user_id=payload.userId,
                date=payload.date,
                income_earned=payload.incomeEarned,
                ghar_allocation=payload.gharAllocation,
                dhanda_allocation=payload.dhandaAllocation,
                household_expense=payload.householdExpense,
                savings=payload.savings,
                reward_delta=payload.rewardDelta,
                learning_reward_delta=payload.learningRewardDelta,
                scam_reward_delta=payload.scamRewardDelta,
                allocation_correct=payload.allocationCorrect,
                scam_completed=payload.scamCompleted,
                scam_correct=payload.scamCorrect,
                lessons_attempted=payload.lessonsAttempted,
                lessons_correct=payload.lessonsCorrect,
                tasks_completed=tasks_json,
                used_laxmi_didi_help=payload.usedLaxmiDidiHelp,
            ))
    logger.info("✅ Synced summary: user=%s date=%s", payload.userId, payload.date)
    return SyncResponse()
