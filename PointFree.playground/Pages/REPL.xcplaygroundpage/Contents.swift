import Either
import PointFree

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

let result = rows(
  """
SELECT
    "users"."email",
    "users"."episode_credit_count",
    "users"."github_user_id",
    "users"."github_access_token",
    "users"."id",
    "users"."is_admin",
    "users"."name",
    "users"."subscription_id"
FROM
    "email_settings"
    LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
WHERE
    "email_settings"."newsletter" = 'newBlogPost'
    AND "users".subscription_id IS NULL
""") as EitherIO<Error, [Database.User]>

result.run.perform().right?.count
