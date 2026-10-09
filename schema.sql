-- ==========================================================
-- FitTrack - Online Fitness Training Platform
-- PostgreSQL Database Schema (Compatible with Supabase)
-- ==========================================================

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'TRAINER', 'USER')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index on email for fast authentication lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- 2. WORKOUT PLANS TABLE
CREATE TABLE IF NOT EXISTS workout_plans (
    id SERIAL PRIMARY KEY,
    trainer_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20) NOT NULL CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    duration INT NOT NULL, -- Duration in weeks
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workout_trainer ON workout_plans(trainer_id);
CREATE INDEX IF NOT EXISTS idx_workout_status ON workout_plans(status);

-- 3. EXERCISES TABLE
CREATE TABLE IF NOT EXISTS exercises (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    muscle_group VARCHAR(50) NOT NULL,
    sets INT DEFAULT 3,
    reps INT DEFAULT 12,
    duration INT DEFAULT 0 -- Duration in seconds (or minutes)
);

-- 4. PLAN_EXERCISES (Bridge table: Workout Plans <-> Exercises)
CREATE TABLE IF NOT EXISTS plan_exercises (
    id SERIAL PRIMARY KEY,
    plan_id INT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
    exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    CONSTRAINT uq_plan_exercise UNIQUE(plan_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_plan_ex_plan ON plan_exercises(plan_id);
CREATE INDEX IF NOT EXISTS idx_plan_ex_exercise ON plan_exercises(exercise_id);

-- 5. PROGRESS TABLE
CREATE TABLE IF NOT EXISTS progress (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight NUMERIC(5,2) NOT NULL,
    height NUMERIC(5,2),
    body_measurement VARCHAR(150),
    fitness_goal VARCHAR(150),
    record_date DATE DEFAULT CURRENT_DATE
);

CREATE INDEX IF NOT EXISTS idx_progress_user ON progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_date ON progress(record_date);

-- 6. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    sender_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiver_id);

-- 7. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read);

-- 8. SYSTEM SETTINGS TABLE
CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    setting_name VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. USER ENROLLED WORKOUT PLANS (User follows workout plan)
CREATE TABLE IF NOT EXISTS user_workout_plans (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id INT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'DROPPED')),
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_plan UNIQUE(user_id, plan_id)
);

CREATE INDEX IF NOT EXISTS idx_user_plans_user ON user_workout_plans(user_id);

-- 10. USER EXERCISE COMPLETIONS TABLE (Tracks daily/weekly exercise completions)
CREATE TABLE IF NOT EXISTS user_exercise_completions (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id INT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
    exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    completed_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_plan_ex_date UNIQUE (user_id, plan_id, exercise_id, completed_date)
);

CREATE INDEX IF NOT EXISTS idx_user_ex_comp_date ON user_exercise_completions(user_id, completed_date);
