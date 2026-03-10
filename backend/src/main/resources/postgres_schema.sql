-- PostgreSQL schema for Tourism-Themed Real Estate Platform
-- This mirrors the current JPA entities and Flutter models.

-- Drop tables in dependency-safe order (optional, comment out in production)
-- DROP TABLE IF EXISTS project_milestones CASCADE;
-- DROP TABLE IF EXISTS expressions_of_interest CASCADE;
-- DROP TABLE IF EXISTS projects CASCADE;
-- DROP TABLE IF EXISTS land_utilities CASCADE;
-- DROP TABLE IF EXISTS lands CASCADE;
-- DROP TABLE IF EXISTS destinations CASCADE;
-- DROP TABLE IF EXISTS password_reset_tokens CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- USERS
CREATE TABLE IF NOT EXISTS users (
    id           BIGSERIAL PRIMARY KEY,
    email        VARCHAR(255) NOT NULL,
    password     VARCHAR(255) NOT NULL,
    role         VARCHAR(50)  NOT NULL, -- INVESTOR, LANDOWNER, ADMIN
    reset_token  VARCHAR(255),
    min_budget   DOUBLE PRECISION,
    max_budget   DOUBLE PRECISION,
    risk_profile VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- LANDS
CREATE TABLE IF NOT EXISTS lands (
    id              BIGSERIAL PRIMARY KEY,
    owner_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(255),
    location        VARCHAR(255),
    size            DOUBLE PRECISION,
    zoning          VARCHAR(255),
    stage           VARCHAR(255),
    legal_documents TEXT,
    phone_number    VARCHAR(50),
    review_status   VARCHAR(50),
    admin_notes     TEXT
);

-- LAND UTILITIES (ElementCollection)
CREATE TABLE IF NOT EXISTS land_utilities (
    land_id BIGINT NOT NULL REFERENCES lands(id) ON DELETE CASCADE,
    utility VARCHAR(255) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_land_utilities_land_id ON land_utilities(land_id);

-- DESTINATIONS (destination intelligence)
CREATE TABLE IF NOT EXISTS destinations (
    id               BIGSERIAL PRIMARY KEY,
    name             VARCHAR(255),
    tourists_per_year INTEGER,
    hotel_occupancy  DOUBLE PRECISION,
    growth_rate      DOUBLE PRECISION
);

-- PROJECTS (tourism projects backed by approved land)
CREATE TABLE IF NOT EXISTS projects (
    id                  BIGSERIAL PRIMARY KEY,
    land_id             BIGINT REFERENCES lands(id) ON DELETE SET NULL,
    project_name        VARCHAR(255) NOT NULL,
    location            VARCHAR(255) NOT NULL,
    land_size           DOUBLE PRECISION NOT NULL DEFAULT 0,
    investment_required DOUBLE PRECISION NOT NULL DEFAULT 0,
    expected_roi        DOUBLE PRECISION NOT NULL DEFAULT 0,
    expected_irr        DOUBLE PRECISION NOT NULL DEFAULT 0,
    stage               VARCHAR(50) NOT NULL -- maps ProjectStage enum
);

CREATE INDEX IF NOT EXISTS idx_projects_land_id ON projects(land_id);

-- EXPRESSIONS OF INTEREST (EOIs)
CREATE TABLE IF NOT EXISTS expressions_of_interest (
    id              BIGSERIAL PRIMARY KEY,
    investor_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    project_id      BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    status          VARCHAR(50) NOT NULL, -- SUBMITTED, etc.
    submission_date TIMESTAMP WITHOUT TIME ZONE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_eoi_investor_project
    ON expressions_of_interest(investor_id, project_id);

-- PROJECT MILESTONES (lifecycle tracker)
CREATE TABLE IF NOT EXISTS project_milestones (
    id          BIGSERIAL PRIMARY KEY,
    project_id  BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    milestone   VARCHAR(255) NOT NULL,
    description TEXT,
    date        DATE,
    status      VARCHAR(50) NOT NULL -- MilestoneStatus enum
);

CREATE INDEX IF NOT EXISTS idx_project_milestones_project_id
    ON project_milestones(project_id);

-- PASSWORD RESET TOKENS (if using separate table; align with PasswordResetToken entity)
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id         BIGSERIAL PRIMARY KEY,
    email      VARCHAR(255) NOT NULL,
    otp        VARCHAR(20)  NOT NULL,
    expires_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

