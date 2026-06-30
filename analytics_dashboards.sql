-- Run this after creating the `calor-97932.analytics_views` dataset.
-- These views power the activation, AI logging, meal plan, gym, restaurant,
-- paywall, and retention dashboards described in docs/analytics.md.

CREATE OR REPLACE VIEW `calor-97932.analytics_views.calor_events` AS
SELECT
  _TABLE_SUFFIX AS table_suffix,
  PARSE_DATE('%Y%m%d', event_date) AS event_day,
  TIMESTAMP_MICROS(event_timestamp) AS event_ts,
  user_pseudo_id,
  event_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'surface') AS surface,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'item_type') AS item_type,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source') AS source,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'screen_name') AS screen_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'action_name') AS action_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'algorithm_version') AS algorithm_version,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'candidate_count') AS candidate_count,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'visible_count') AS visible_count,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'selected_rank') AS selected_rank,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'calories_bucket') AS calories_bucket,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'time_of_day_bucket') AS time_of_day_bucket,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'meal_type') AS meal_type,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'provider') AS provider,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'gym_name') AS gym_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'class_status') AS class_status,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'restaurant') AS restaurant,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'order_route') AS order_route,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'trigger') AS trigger,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'plan') AS plan,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'feature_name') AS feature_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'permission_name') AS permission_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'permission_status') AS permission_status,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'metric_name') AS metric_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'value_bucket') AS value_bucket,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'city') AS city,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'success') AS success
FROM `calor-97932.analytics_517822938.events_*`;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.activation_daily` AS
SELECT
  event_day,
  COUNTIF(event_name = 'onboarding_started') AS onboarding_started,
  COUNTIF(event_name = 'onboarding_completed') AS onboarding_completed,
  COUNTIF(event_name = 'sign_up') AS sign_ups,
  COUNTIF(event_name = 'login') AS logins,
  COUNTIF(event_name = 'food_logged') AS food_logs,
  COUNT(DISTINCT IF(event_name = 'food_logged', user_pseudo_id, NULL)) AS users_logged_food
FROM `calor-97932.analytics_views.calor_events`
GROUP BY event_day;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.ai_logging_funnel_daily` AS
SELECT
  event_day,
  source,
  COUNTIF(event_name = 'screen_view' AND screen_name = 'Camera') AS camera_views,
  COUNTIF(event_name = 'pending_meal_action' AND action_name IN ('created', 'queued_from_camera', 'queued_from_gallery')) AS pending_created,
  COUNTIF(event_name = 'food_scan' AND success = 1) AS analysis_success,
  COUNTIF(event_name = 'food_scan' AND success = 0) AS analysis_failed,
  COUNTIF(event_name = 'food_logged') AS food_logged
FROM `calor-97932.analytics_views.calor_events`
WHERE event_name IN ('screen_view', 'pending_meal_action', 'food_scan', 'food_logged')
GROUP BY event_day, source;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.pending_meal_funnel_daily` AS
SELECT
  event_day,
  source,
  COUNTIF(action_name = 'created') AS created,
  COUNTIF(action_name = 'analysis_ready') AS analysis_ready,
  COUNTIF(action_name = 'analysis_failed') AS analysis_failed,
  COUNTIF(action_name = 'quick_saved') AS quick_saved,
  COUNTIF(action_name = 'review_saved') AS review_saved,
  COUNTIF(action_name = 'quick_save_failed') AS quick_save_failed
FROM `calor-97932.analytics_views.calor_events`
WHERE event_name = 'pending_meal_action'
GROUP BY event_day, source;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.meal_plan_restaurant_daily` AS
SELECT
  event_day,
  meal_type,
  restaurant,
  order_route,
  COUNTIF(event_name = 'meal_plan_viewed') AS plan_views,
  COUNTIF(event_name = 'meal_plan_generated') AS plan_generated,
  COUNTIF(event_name = 'food_logged' AND source IN ('meal_plan_card', 'meal_detail')) AS meal_plan_logs,
  COUNTIF(event_name = 'restaurant_viewed') AS restaurant_view_events,
  COUNT(DISTINCT IF(event_name = 'restaurant_viewed', user_pseudo_id, NULL)) AS restaurant_view_users,
  COUNTIF(event_name = 'meal_order_clicked') AS order_click_events
FROM `calor-97932.analytics_views.calor_events`
WHERE event_name IN ('meal_plan_viewed', 'meal_plan_generated', 'food_logged', 'restaurant_viewed', 'meal_order_clicked')
GROUP BY event_day, meal_type, restaurant, order_route;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.gym_funnel_daily` AS
SELECT
  event_day,
  city,
  provider,
  gym_name,
  COUNTIF(event_name = 'gym_selected') AS gym_selected,
  COUNTIF(event_name = 'gym_booking_opened') AS booking_opened,
  COUNTIF(event_name = 'workout_class_action' AND class_status = 'Done') AS class_done
FROM `calor-97932.analytics_views.calor_events`
WHERE event_name IN ('gym_selected', 'gym_booking_opened', 'workout_class_action')
GROUP BY event_day, city, provider, gym_name;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.choice_set_daily` AS
SELECT
  event_day,
  surface,
  item_type,
  source,
  algorithm_version,
  COUNT(*) AS choice_set_presented_events,
  COUNT(DISTINCT user_pseudo_id) AS choice_set_users,
  AVG(candidate_count) AS avg_candidate_count,
  AVG(visible_count) AS avg_visible_count
FROM `calor-97932.analytics_views.calor_events`
WHERE event_name = 'choice_set_presented'
GROUP BY event_day, surface, item_type, source, algorithm_version;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.choice_selection_daily` AS
SELECT
  event_day,
  surface,
  item_type,
  action_name,
  source,
  algorithm_version,
  selected_rank,
  restaurant,
  meal_type,
  provider,
  city,
  order_route,
  COUNT(*) AS choice_selected_events,
  COUNT(DISTINCT user_pseudo_id) AS choice_selected_users,
  AVG(selected_rank) AS avg_selected_rank
FROM `calor-97932.analytics_views.calor_events`
WHERE event_name = 'choice_selected'
GROUP BY
  event_day,
  surface,
  item_type,
  action_name,
  source,
  algorithm_version,
  selected_rank,
  restaurant,
  meal_type,
  provider,
  city,
  order_route;

CREATE OR REPLACE VIEW `calor-97932.analytics_views.retention_by_first_logging_source` AS
WITH first_log AS (
  SELECT
    user_pseudo_id,
    MIN(event_day) AS first_food_log_day,
    ARRAY_AGG(source IGNORE NULLS ORDER BY event_ts LIMIT 1)[SAFE_OFFSET(0)] AS first_logging_source
  FROM `calor-97932.analytics_views.calor_events`
  WHERE event_name = 'food_logged'
  GROUP BY user_pseudo_id
),
activity AS (
  SELECT DISTINCT user_pseudo_id, event_day
  FROM `calor-97932.analytics_views.calor_events`
  WHERE event_name IN ('session_start', 'food_logged')
)
SELECT
  first_log.first_food_log_day,
  first_log.first_logging_source,
  COUNT(DISTINCT first_log.user_pseudo_id) AS cohort_users,
  COUNT(DISTINCT IF(DATE_DIFF(activity.event_day, first_log.first_food_log_day, DAY) = 1, activity.user_pseudo_id, NULL)) AS d1_returned,
  COUNT(DISTINCT IF(DATE_DIFF(activity.event_day, first_log.first_food_log_day, DAY) BETWEEN 1 AND 7, activity.user_pseudo_id, NULL)) AS d7_returned,
  COUNT(DISTINCT IF(DATE_DIFF(activity.event_day, first_log.first_food_log_day, DAY) BETWEEN 1 AND 14, activity.user_pseudo_id, NULL)) AS d14_returned
FROM first_log
LEFT JOIN activity USING (user_pseudo_id)
GROUP BY first_log.first_food_log_day, first_log.first_logging_source;
