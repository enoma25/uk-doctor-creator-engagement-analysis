-- UK Doctor-Creator Engagement Analysis
-- Database: PostgreSQL (the median query uses PERCENTILE_CONT)
-- Source: HypeAuditor ranking of top UK Health & Medicine Instagram accounts, accessed 26 October 2026.
-- Only individuals presenting as medical doctors are included. Follower and engagement
-- figures are rounded as published (e.g. 5.3K = 5300), so engagement rates are approximate.
-- Engagement rate (ER) = average engagements per post / followers.

-- 1. Create the table ---------------------------------------------------------
DROP TABLE IF EXISTS doctors CASCADE;

CREATE TABLE doctors (
    doctor     TEXT    NOT NULL,
    handle     TEXT    NOT NULL,  -- Instagram handle, without the @
    followers  INTEGER NOT NULL,
    avg_eng    INTEGER NOT NULL,  -- average engagements per post
    auth_eng   INTEGER NOT NULL   -- "authentic" engagements per post (HypeAuditor)
);

-- 2. Load the data ------------------------------------------------------------
INSERT INTO doctors (doctor, handle, followers, avg_eng, auth_eng) VALUES
('Dr Faye Bate',          'drfayebate',          294400,  5300,  4200),
('Dr Monika Sharma',      'lifewithdoctormon',   180400,  2200,  1700),
('Dr Dominic Bray',       'drdominicbray',       434600,  5100,  3800),
('Dr Joshua Wolrich',     'drjoshuawolrich',     451600,  5000,  3900),
('Dr Ewoma Ukeleghe',     'drewomaukeleghe',     412400,  4200,  3000),
('Dr Ahmed El Muntasar',  'theaestheticsdoctor', 1200000, 11300, 6900),
('Dr Hazel Wallace',      'drhazelwallace',      1700000, 14000, 11500),
('Dr Rosh',               'drroshofficial',      587600,  4200,  2300),
('Dr Jonny Betteridge',   'drjb.aesthetics',     404200,  1800,  1300),
('Dr Tara Swart',         'drtaraswart',         847300,  2800,  2300),
('Dr Louise Newson',      'menopause_doctor',    854200,  2200,  1800),
('Dr Rupy Aujla',         'doctors_kitchen',     755100,  1900,  1500),
('Prof Tim Spector',      'tim.spector',         777800,  1900,  1600),
('Dr Emily',              'dr_emily_official',   773000,  1600,  1300),
('Dr Alex George',        'dralexgeorge',        2200000, 2700,  2100),
('Dr Rangan Chatterjee',  'drchatterjee',        1700000, 789,   660);

-- 3. View: one row per doctor with the calculated metrics ---------------------
CREATE OR REPLACE VIEW doctor_metrics AS
SELECT
    doctor,
    handle,
    followers,
    avg_eng,
    auth_eng,
    ROUND(100.0 * avg_eng  / followers, 2) AS er_pct,         -- engagement rate %
    ROUND(100.0 * auth_eng / avg_eng,   0) AS authentic_pct,  -- share of engagement counted as authentic
    CASE
        WHEN followers <  500000  THEN 'Under 500K'
        WHEN followers <= 1000000 THEN '500K to 1M'
        ELSE 'Over 1M'
    END AS band
FROM doctors;

-- 4. Median ER and average engagements by follower band -----------------------
CREATE OR REPLACE VIEW band_summary AS
SELECT
    band,
    COUNT(*)                                                     AS doctors,
    ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY er_pct) AS NUMERIC), 2) AS median_er_pct,
    ROUND(AVG(avg_eng), 0)                                       AS avg_engagements_per_post
FROM doctor_metrics
GROUP BY band;

-- 5. Overall KPIs (for dashboard cards) ---------------------------------------
CREATE OR REPLACE VIEW kpis AS
SELECT
    COUNT(*)                   AS doctors_analysed,
    ROUND(AVG(er_pct), 2)      AS avg_er_pct,
    ROUND(AVG(authentic_pct),0) AS avg_authentic_pct
FROM doctor_metrics;

-- 6. Queries to answer the key questions --------------------------------------

-- Who has the highest engagement rate?
SELECT doctor, handle, followers, er_pct
FROM doctor_metrics
ORDER BY er_pct DESC;

-- Do smaller doctors engage better? (expected: Under 500K highest median ER)
SELECT * FROM band_summary
ORDER BY median_er_pct DESC;

-- Which accounts have the lowest share of authentic engagement? (audience quality check)
SELECT doctor, handle, authentic_pct
FROM doctor_metrics
ORDER BY authentic_pct ASC
LIMIT 5;

-- Smaller doctors vs larger names: engagement per post and ER side by side
SELECT doctor, followers, avg_eng, er_pct
FROM doctor_metrics
WHERE followers < 500000 OR followers > 1000000
ORDER BY followers;
