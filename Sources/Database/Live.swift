import Models
import PointFreePrelude
import PostgresKit
import Stripe

extension Client {
  public static func live(
    pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) -> Self {
    Self(
      addUserIdToSubscriptionId: { userId, subscriptionId in
        try await pool.sqlDatabase.run(
          """
          UPDATE "users"
          SET "subscription_id" = \(bind: subscriptionId)
          WHERE "users"."id" = \(bind: userId)
          """
        )
      },
      createEnterpriseAccount: { companyName, domain, subscriptionId in
        try await pool.sqlDatabase.first(
          """
          INSERT INTO "enterprise_accounts"
          ("company_name", "domain", "subscription_id")
          VALUES
          (\(bind: companyName), \(bind: domain), \(bind: subscriptionId))
          RETURNING *
          """
        )
      },
      createEnterpriseEmail: { email, userId in
        try await pool.sqlDatabase.first(
          """
          INSERT INTO "enterprise_emails"
          ("email", "user_id")
          VALUES
          (\(bind: email), \(bind: userId))
          RETURNING *
          """
        )
      },
      createFeedRequestEvent: { type, userAgent, userId in
        try await pool.sqlDatabase.run(
          """
          INSERT INTO "feed_request_events"
          ("type", "user_agent", "user_id")
          VALUES
          (\(bind: type.rawValue), \(bind: userAgent), \(bind: userId))
          ON CONFLICT ("type", "user_agent", "user_id") DO UPDATE
          SET "count" = "feed_request_events"."count" + 1
          """
        )
      },
      createGift: {
        deliverAt, fromEmail, fromName, message, monthsFree, stripePaymentIntentId, toEmail, toName
        in
        try await pool.sqlDatabase.first(
          """
          INSERT INTO "gifts" (
            "deliver_at",
            "from_email",
            "from_name",
            "message",
            "months_free",
            "stripe_payment_intent_id",
            "to_email",
            "to_name"
          )
          VALUES (
            \(bind: deliverAt),
            \(bind: fromEmail),
            \(bind: fromName),
            \(bind: message),
            \(bind: monthsFree),
            \(bind: stripePaymentIntentId),
            \(bind: toEmail),
            \(bind: toName)
          )
          RETURNING *
          """
        )
      },
      createSubscription: { stripeSubscription, userId, isOwnerTakingSeat, referrerId in
        let subscription = try await pool.sqlDatabase.first(
          """
          INSERT INTO "subscriptions" ("stripe_subscription_id", "stripe_subscription_status", "user_id")
          VALUES (\(bind: stripeSubscription.id), \(bind: stripeSubscription.status), \(bind: userId))
          RETURNING *
          """,
          decoding: Models.Subscription.self
        )
        if isOwnerTakingSeat {
          try await pool.sqlDatabase.run(
            """
            UPDATE "users"
            SET "subscription_id" = \(bind: subscription.id), "referrer_id" = \(bind: referrerId)
            WHERE "users"."id" = \(bind: subscription.userId)
            """
          )
        }
        return subscription
      },
      deleteEnterpriseEmail: { userId in
        try await pool.sqlDatabase.run(
          """
          DELETE FROM "enterprise_emails"
          WHERE "user_id" = \(bind: userId)
          """
        )
      },
      deleteTeamInvite: { id in
        try await pool.sqlDatabase.run(
          """
          DELETE FROM "team_invites"
          WHERE "id" = \(bind: id)
          """
        )
      },
      execute: { sql in
        try await pool.sqlDatabase.raw(sql).all()
      },
      fetchAdmins: {
        try await pool.sqlDatabase.all(
          """
          SELECT *
          FROM "users"
          WHERE "users"."is_admin" = TRUE
          """
        )
      },
      fetchEmailSettingsForUserId: { userId in
        try await pool.sqlDatabase.all(
          """
          SELECT "newsletter", "user_id"
          FROM "email_settings"
          WHERE "user_id" = \(bind: userId)
          """
        )
      },
      fetchEnterpriseAccountForDomain: { domain in
        try await pool.sqlDatabase.first(
          """
          SELECT "company_name", "domain", "id", "subscription_id"
          FROM "enterprise_accounts"
          WHERE "domain" = \(bind: domain)
          LIMIT 1
          """
        )
      },
      fetchEnterpriseAccountForSubscription: { subscriptionId in
        try await pool.sqlDatabase.first(
          """
          SELECT "company_name", "domain", "id", "subscription_id"
          FROM "enterprise_accounts"
          WHERE "subscription_id" = \(bind: subscriptionId)
          LIMIT 1
          """
        )
      },
      fetchEnterpriseEmails: {
        try await pool.sqlDatabase.all(
          """
          SELECT *
          FROM "enterprise_emails"
          """
        )
      },
      fetchEpisodeCredits: { userId in
        try await pool.sqlDatabase.all(
          """
          SELECT "episode_sequence", "user_id"
          FROM "episode_credits"
          WHERE "user_id" = \(bind: userId)
          """
        )
      },
      fetchEpisodeProgress: { userId, sequence in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "episode_progresses"
          WHERE "user_id" = \(bind: userId)
          AND "episode_sequence" = \(bind: sequence)
          """
        )
      },
      fetchEpisodeProgresses: { userId -> [EpisodeProgress] in
        try await pool.sqlDatabase.all(
          """
          SELECT *
          FROM "episode_progresses"
          WHERE "user_id" = \(bind: userId)
          """
        )
      },
      fetchFreeEpisodeUsers: {
        try await pool.sqlDatabase.all(
          """
          SELECT "users".*
          FROM "users"
          LEFT JOIN "subscriptions" ON "subscriptions"."id" = "users"."subscription_id"
          LEFT JOIN "email_settings" ON "email_settings"."user_id" = "users"."id"
          WHERE (
            "subscriptions"."stripe_subscription_status" IS NULL
              OR "subscriptions"."stripe_subscription_status" != \(bind: Stripe.Subscription.Status.active)
          )
          AND "email_settings"."newsletter" = \(bind: EmailSetting.Newsletter.newEpisode)
          """
        )
      },
      fetchGift: { id in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "gifts"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
      },
      fetchGiftByStripePaymentIntentId: { paymentIntentId in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "gifts"
          WHERE "stripe_payment_intent_id" = \(bind: paymentIntentId)
          LIMIT 1
          """
        )
      },
      fetchGiftsToDeliver: {
        try await pool.sqlDatabase.all(
          """
          SELECT * FROM "gifts"
          WHERE "stripe_subscription_id" IS NULL
          AND "stripe_payment_intent_status" = \(bind: PaymentIntent.Status.succeeded)
          AND NOT "delivered"
          AND (
            "deliver_at" <= CURRENT_DATE
              OR "deliver_at" IS NULL
          )
          """
        )
      },
      fetchLivestreams: {
        try await pool.sqlDatabase.all(
          """
          SELECT * FROM "livestreams"
          """
        )
      },
      fetchSubscriptionById: { id in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "subscriptions"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
      },
      fetchSubscriptionByOwnerId: { ownerId in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "subscriptions"
          WHERE "user_id" = \(bind: ownerId)
          ORDER BY "created_at" DESC
          LIMIT 1
          """
        )
      },
      fetchSubscriptionByTeamInviteCode: { teamInviteCode in
        try await pool.sqlDatabase.first(
          """
          SELECT "subscriptions".*
          FROM "subscriptions"
          WHERE "subscriptions"."team_invite_code" = \(bind: teamInviteCode)
          """
        )
      },
      fetchSubscriptionTeammatesByOwnerId: { ownerId in
        try await pool.sqlDatabase.all(
          """
          SELECT "users".*
          FROM "users"
          INNER JOIN "subscriptions" ON "users"."subscription_id" = "subscriptions"."id"
          WHERE "subscriptions"."user_id" = \(bind: ownerId)
          """
        )
      },
      fetchTeamInvite: { id in
        try await pool.sqlDatabase.first(
          """
          SELECT "created_at", "email", "id", "inviter_user_id"
          FROM "team_invites"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
      },
      fetchTeamInvites: { inviterId in
        try await pool.sqlDatabase.all(
          """
          SELECT "created_at", "email", "id", "inviter_user_id"
          FROM "team_invites"
          WHERE "inviter_user_id" = \(bind: inviterId)
          """
        )
      },
      fetchUserByGitHub: { gitHubUserId in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "users"
          WHERE "github_user_id" = \(bind: gitHubUserId)
          LIMIT 1
          """
        )
      },
      fetchUserById: { id in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "users"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
      },
      fetchUserByReferralCode: { referralCode in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "users"
          WHERE "referral_code" = \(bind: referralCode)
          LIMIT 1
          """
        )
      },
      fetchUserByRssSalt: { salt in
        try await pool.sqlDatabase.first(
          """
          SELECT *
          FROM "users"
          WHERE "rss_salt" = \(bind: salt)
          LIMIT 1
          """
        )
      },
      fetchUsersSubscribedToNewsletter: { newsletter, nonsubscriberOrSubscriber in
        let condition: SQLQueryString
        switch nonsubscriberOrSubscriber {
        case nil:
          condition = ""
        case .nonSubscriber:
          condition = #" AND "users"."subscription_id" IS NULL"#
        case .subscriber:
          condition = #" AND "users"."subscription_id" IS NOT NULL"#
        }
        return try await pool.sqlDatabase.all(
          """
          SELECT "users".*
          FROM "email_settings" LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
          WHERE "email_settings"."newsletter" = \(bind: newsletter)\(condition)
          """
        )
      },
      fetchUsersToWelcome: { weeksAgo in
        let daysAgo = weeksAgo * 7
        let startDate: SQLQueryString = "CURRENT_DATE - INTERVAL '\(raw: "\(daysAgo)") DAY'"
        let endDate: SQLQueryString = "CURRENT_DATE - INTERVAL '\(raw: "\(daysAgo - 1)") DAY'"

        return try await pool.sqlDatabase.all(
          """
          SELECT
          "users".*
          FROM
          "email_settings"
          LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
          LEFT JOIN "subscriptions" on "users"."id" = "subscriptions"."user_id"
          WHERE
          "email_settings"."newsletter" = \(bind: EmailSetting.Newsletter.welcomeEmails)
          AND "users"."created_at" BETWEEN \(startDate) AND \(endDate)
          AND "users"."subscription_id" IS NULL
          AND "subscriptions"."user_id" IS NULL;
          """
        )
      },
      incrementEpisodeCredits: { userIds in
        let ids: SQLQueryString = """
          \(raw: userIds.map { "'\($0.rawValue.uuidString)'" }.joined(separator: ", "))
          """
        return try await pool.sqlDatabase.all(
          """
          UPDATE "users"
          SET "episode_credit_count" = "episode_credit_count" + 1
          WHERE "id" IN (\(ids))
          RETURNING *
          """
        )
      },
      insertTeamInvite: { email, inviterUserId in
        try await pool.sqlDatabase.first(
          """
          INSERT INTO "team_invites" ("email", "inviter_user_id")
          VALUES (\(bind: email), \(bind: inviterUserId))
          RETURNING *
          """
        )
      },
      migrate: {
        let database = pool.sqlDatabase
        for `extension` in ["pgcrypto", "uuid-ossp", "citext"] {
          do {
            try await database.run(
              """
              CREATE EXTENSION IF NOT EXISTS "\(raw: `extension`)" WITH SCHEMA "heroku_ext"
              """
            )
          } catch {
            try await database.run(
              """
              CREATE EXTENSION IF NOT EXISTS "\(raw: `extension`)"
              """
            )
          }
        }
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "users" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "email" citext NOT NULL UNIQUE,
            "github_user_id" integer UNIQUE,
            "github_access_token" character varying,
            "name" character varying,
            "subscription_id" uuid,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "updated_at" timestamp without time zone
          )
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "subscriptions" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "user_id" uuid REFERENCES "users" ("id") NOT NULL,
            "stripe_subscription_id" character varying NOT NULL,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "updated_at" timestamp without time zone
          );
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "team_invites" (
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "email" character varying,
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "inviter_user_id" uuid REFERENCES "users" ("id") NOT NULL
          )
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "email_settings" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "newsletter" character varying,
            "user_id" uuid REFERENCES "users" ("id") NOT NULL
          )
          """
        )
        try await database.run(
          """
          ALTER TABLE "subscriptions"
          ADD COLUMN IF NOT EXISTS
          "stripe_subscription_status" character varying NOT NULL DEFAULT 'active'
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ADD COLUMN IF NOT EXISTS
          "is_admin" boolean NOT NULL DEFAULT FALSE
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_subscriptions_on_stripe_subscription_id"
          ON "subscriptions" ("stripe_subscription_id")
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "episode_credits" (
            "episode_sequence" integer,
            "user_id" uuid REFERENCES "users" ("id") NOT NULL
          )
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_credits_on_episode_sequence_and_user_id"
          ON "episode_credits" ("episode_sequence", "user_id")
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ADD COLUMN IF NOT EXISTS
          "episode_credit_count" integer NOT NULL DEFAULT 0
          """
        )
        try await database.run(
          """
          ALTER TABLE "episode_credits"
          ADD COLUMN IF NOT EXISTS
          "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ADD COLUMN IF NOT EXISTS
          "rss_salt" uuid DEFAULT uuid_generate_v1mc() NOT NULL
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "feed_request_events" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "type" character varying NOT NULL,
            "user_agent" character varying NOT NULL,
            "user_id" uuid REFERENCES "users" ("id"),
            "count" integer NOT NULL DEFAULT 1,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
          )
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_feed_request_events_on_type_user_agent_user_id"
          ON "feed_request_events" ("type", "user_agent", "user_id")
          """
        )
        try await database.run(
          """
          ALTER TABLE "feed_request_events"
          ADD COLUMN IF NOT EXISTS
          "updated_at" timestamp without time zone DEFAULT NOW() NOT NULL
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_email_settings_on_newsletter_user_id"
          ON "email_settings" ("newsletter", "user_id")
          """
        )
        try await database.run(
          """
          CREATE OR REPLACE FUNCTION update_updated_at()
          RETURNS TRIGGER AS $$
          BEGIN
            NEW."updated_at" = NOW();
            RETURN NEW;
          END;
          $$ LANGUAGE PLPGSQL;
          """
        )
        try await database.run(
          """
          DO $$
          DECLARE
            "table" text;
          BEGIN
            FOR "table" IN
              SELECT "table_name" FROM "information_schema"."columns"
              WHERE column_name = 'updated_at'
            LOOP
              IF NOT EXISTS (
                SELECT 1 FROM "information_schema"."triggers"
                WHERE "trigger_name" = 'update_updated_at_' || "table"
              ) THEN
                EXECUTE format(
                  '
                  CREATE TRIGGER "update_updated_at_%I"
                  BEFORE UPDATE ON "%I"
                  FOR EACH ROW EXECUTE PROCEDURE update_updated_at()
                  ',
                  "table", "table"
                );
              END IF;
            END LOOP;
          END;
          $$ LANGUAGE PLPGSQL;
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "enterprise_accounts" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "company_name" character varying NOT NULL,
            "domain" character varying NOT NULL,
            "subscription_id" uuid REFERENCES "subscriptions" ("id") NOT NULL,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "updated_at" timestamp without time zone
          )
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_accounts_on_domain"
          ON "enterprise_accounts" ("domain")
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_accounts_on_subscription_id"
          ON "enterprise_accounts" ("subscription_id")
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "enterprise_emails" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "email" character varying NOT NULL,
            "user_id" uuid REFERENCES "users" ("id") NOT NULL,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "updated_at" timestamp without time zone
          )
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_emails_on_email"
          ON "enterprise_emails" (lower("email"))
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_emails_on_user_id"
          ON "enterprise_emails" ("user_id")
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ADD FOREIGN KEY ("subscription_id") REFERENCES "subscriptions" ("id")
          """
        )
        try await database.run(
          #"""
          CREATE TABLE IF NOT EXISTS "episode_progresses" (
          "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
          "episode_sequence" smallint NOT NULL,
          "percent" smallint NOT NULL,
          "user_id" uuid REFERENCES "users" ("id") NOT NULL,
          "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
          "updated_at" timestamp without time zone
          )
          """#
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_progresses_on_episode_sequence_user_id"
          ON "episode_progresses" ("episode_sequence", "user_id")
          """
        )
        try await database.run(
          """
          CREATE OR REPLACE FUNCTION gen_shortid(table_name text, column_name text)
          RETURNS text AS $$
          DECLARE
            id text;
            results text;
            times integer := 0;
          BEGIN
            LOOP
              id := encode(gen_random_bytes(6), 'base64');
              id := replace(id, '/', 'p');
              id := replace(id, '+', 'f');
              EXECUTE 'SELECT '
                || quote_ident(column_name)
                || ' FROM '
                || quote_ident(table_name)
                || ' WHERE '
                || quote_ident(column_name)
                || ' = '
                || quote_literal(id) INTO results;
              IF results IS NULL THEN
                EXIT;
              END IF;
              times := times + 1;
              IF times > 100 THEN
                id := NULL;
                EXIT;
              END IF;
            END LOOP;
            RETURN id;
          END;
          $$ LANGUAGE 'plpgsql';
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ADD COLUMN IF NOT EXISTS
          "referral_code" character varying DEFAULT gen_shortid('users', 'referral_code') NOT NULL
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ADD COLUMN IF NOT EXISTS
          "referrer_id" uuid REFERENCES "users" ("id")
          """
        )
        try await database.run(
          """
          ALTER TABLE "subscriptions"
          ADD COLUMN IF NOT EXISTS
          "team_invite_code" character varying DEFAULT gen_shortid('subscriptions', 'team_invite_code') NOT NULL
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_users_referral_code"
          ON "users" ("referral_code")
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_subscriptions_team_invite_code"
          ON "subscriptions" ("team_invite_code")
          """
        )
        try await database.run(
          """
          ALTER TABLE "subscriptions"
          ADD COLUMN IF NOT EXISTS
          "deactivated" boolean NOT NULL DEFAULT FALSE
          """
        )
        try await database.run(
          """
          ALTER TABLE "users"
          ALTER COLUMN "rss_salt" TYPE citext
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_users_on_rss_salt"
          ON "users" ("rss_salt")
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "gifts" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "deliver_at" timestamp without time zone,
            "from_email" citext NOT NULL,
            "from_name" character varying NOT NULL,
            "message" character varying NOT NULL,
            "months_free" integer NOT NULL,
            "stripe_coupon_id" character varying,
            "stripe_payment_intent_id" character varying NOT NULL,
            "to_email" citext NOT NULL,
            "to_name" character varying NOT NULL,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "updated_at" timestamp without time zone
          )
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_gifts_on_stripe_payment_intent_id"
          ON "gifts" ("stripe_payment_intent_id")
          """
        )
        try await database.run(
          """
          ALTER TABLE "gifts"
          ADD COLUMN IF NOT EXISTS "stripe_subscription_id" character varying
          """
        )
        try await database.run(
          """
          ALTER TABLE "gifts"
          DROP COLUMN IF EXISTS "stripe_coupon_id"
          """
        )
        try await database.run(
          """
          ALTER TABLE "gifts"
          ADD COLUMN IF NOT EXISTS
          "delivered" boolean NOT NULL DEFAULT FALSE
          """
        )
        try await database.run(
          """
          ALTER TABLE "gifts"
          ADD COLUMN IF NOT EXISTS
          "stripe_payment_intent_status" character varying NOT NULL DEFAULT '\(raw: PaymentIntent.Status.requiresPaymentMethod.rawValue)'
          """
        )
        try await database.run(
          """
          ALTER TABLE "episode_progresses"
          ADD COLUMN IF NOT EXISTS
          "is_finished" boolean NOT NULL DEFAULT FALSE
          """
        )
        try await database.run(
          """
          DROP INDEX IF EXISTS "index_episode_progresses_on_episode_sequence_user_id"
          """
        )
        try await database.run(
          """
          CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_progresses_on_user_id_episode_sequence"
          ON "episode_progresses" ("user_id", "episode_sequence")
          """
        )
        try await database.run(
          """
          CREATE TABLE IF NOT EXISTS "livestreams" (
            "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
            "event_id" integer NOT NULL,
            "is_active" boolean NOT NULL DEFAULT FALSE,
            "is_live" boolean NOT NULL DEFAULT FALSE,
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
            "updated_at" timestamp without time zone
          )
          """
        )
      },
      redeemEpisodeCredit: { episodeSequence, userId in
        try await pool.sqlDatabase.run(
          """
          INSERT INTO "episode_credits" ("episode_sequence", "user_id")
          VALUES (\(bind: episodeSequence), \(bind: userId))
          """
        )
      },
      regenerateTeamInviteCode: { subscriptionID in
        try await pool.sqlDatabase.run(
          """
          UPDATE "subscriptions"
          SET "team_invite_code" = gen_shortid('subscriptions', 'team_invite_code')
          where "subscriptions"."id" = \(bind: subscriptionID)
          """
        )
      },
      removeTeammateUserIdFromSubscriptionId: { teammateUserId, subscriptionId in
        try await pool.sqlDatabase.run(
          """
          UPDATE "users"
          SET "subscription_id" = NULL
          WHERE "users"."id" = \(bind: teammateUserId)
          AND "users"."subscription_id" = \(bind: subscriptionId)
          """
        )
      },
      sawUser: { userId in
        try await pool.sqlDatabase.run(
          """
          UPDATE "users"
          SET "updated_at" = NOW()
          WHERE "id" = \(bind: userId)
          """
        )
      },
      updateEmailSettings: { settings, userId in
        guard let settings else { return }
        try await pool.sqlDatabase.run(
          """
          DELETE FROM "email_settings"
          WHERE "user_id" = \(bind: userId)
          """
        )
        for type in settings {
          try await pool.sqlDatabase.run(
            """
            INSERT INTO "email_settings" ("newsletter", "user_id")
            VALUES (\(bind: type), \(bind: userId))
            """
          )
        }
      },
      updateEpisodeProgress: { episodeSequence, percent, isFinished, userId in
        try await pool.sqlDatabase.run(
          """
          INSERT INTO "episode_progresses" ("episode_sequence", "percent", "user_id", "is_finished")
          VALUES (\(bind: episodeSequence), \(bind: percent), \(bind: userId), \(bind: isFinished))
          ON CONFLICT ("episode_sequence", "user_id") DO UPDATE
          SET
            "percent" = \(bind: percent),
            "is_finished" = "episode_progresses"."is_finished" OR \(bind: isFinished)
          """
        )
      },
      updateGift: { id, stripeSubscriptionId in
        try await pool.sqlDatabase.first(
          """
          UPDATE "gifts"
          SET "stripe_subscription_id" = \(bind: stripeSubscriptionId)
          WHERE "id" = \(bind: id)
          RETURNING *
          """
        )
      },
      updateGiftStatus: { id, status, delivered in
        try await pool.sqlDatabase.first(
          """
          UPDATE "gifts"
          SET "stripe_payment_intent_status" = \(bind: status), "delivered" = \(bind: delivered)
          WHERE "id" = \(bind: id)
          RETURNING *
          """
        )
      },
      updateStripeSubscription: { stripeSubscription in
        try await pool.sqlDatabase.first(
          """
          UPDATE "subscriptions"
          SET "stripe_subscription_status" = \(bind: stripeSubscription.status)
          WHERE "subscriptions"."stripe_subscription_id" = \(bind: stripeSubscription.id)
          RETURNING *
          """
        )
      },
      updateUser: { userId, name, email, episodeCreditCount, rssSalt in
        try await pool.sqlDatabase.run(
          """
          UPDATE "users"
          SET "name" = COALESCE(\(bind: name), "name"),
            "email" = COALESCE(\(bind: email), "email"),
            "episode_credit_count" = COALESCE(\(bind: episodeCreditCount), "episode_credit_count"),
            "rss_salt" = COALESCE(\(bind: rssSalt), "rss_salt")
          WHERE "id" = \(bind: userId)
          """
        )
      },
      upsertUser: { envelope, email, now in
        try await pool.sqlDatabase.first(
          """
          INSERT INTO "users"
          ("email", "github_user_id", "github_access_token", "name", "episode_credit_count")
          VALUES (
            \(bind: email),
            \(bind: envelope.gitHubUser.id),
            \(bind: envelope.accessToken.accessToken),
            \(bind: envelope.gitHubUser.name),
            \(bind: now().timeIntervalSince(envelope.gitHubUser.createdAt) < 60*60*24*7 ? 0 : 1)
          )
          ON CONFLICT ("github_user_id") DO UPDATE
          SET "github_access_token" = $3, "name" = $4
          RETURNING *
          """
        )
      }
    )
  }
}
