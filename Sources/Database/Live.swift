import Either
import Models
import PointFreePrelude
import PostgresKit
import Prelude
import Stripe

extension Client {
  public static func live(
    pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) -> Self {
    Self(
      addUserIdToSubscriptionId: { userId, subscriptionId in
        try await pool.sqlDatabase.raw(
          """
          UPDATE "users"
          SET "subscription_id" = \(bind: subscriptionId)
          WHERE "users"."id" = \(bind: userId)
          """
        )
        .run()
      },
      createEnterpriseAccount: { companyName, domain, subscriptionId in
        try await pool.sqlDatabase.raw(
          """
          INSERT INTO "enterprise_accounts"
          ("company_name", "domain", "subscription_id")
          VALUES
          (\(bind: companyName), \(bind: domain), \(bind: subscriptionId))
          RETURNING *
          """
        )
        .first(decoding: EnterpriseAccount.self)
      },
      createEnterpriseEmail: { email, userId in
        try await pool.sqlDatabase.raw(
          """
          INSERT INTO "enterprise_emails"
          ("email", "user_id")
          VALUES
          (\(bind: email), \(bind: userId))
          RETURNING *
          """
        )
        .first(decoding: EnterpriseEmail.self)
      },
      createFeedRequestEvent: { type, userAgent, userId in
        try await pool.sqlDatabase.raw(
          """
          INSERT INTO "feed_request_events"
          ("type", "user_agent", "user_id")
          VALUES
          (\(bind: type.rawValue), \(bind: userAgent), \(bind: userId))
          ON CONFLICT ("type", "user_agent", "user_id") DO UPDATE
          SET "count" = "feed_request_events"."count" + 1
          """
        )
        .run()
      },
      createGift: { request in
        try await requireSome(
          pool.sqlDatabase.raw(
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
              \(bind: request.deliverAt),
              \(bind: request.fromEmail),
              \(bind: request.fromName),
              \(bind: request.message),
              \(bind: request.monthsFree),
              \(bind: request.stripePaymentIntentId),
              \(bind: request.toEmail),
              \(bind: request.toName)
            )
            RETURNING *
            """
          )
          .first(decoding: Gift.self)
        )
      },
      createSubscription: { stripeSubscription, userId, isOwnerTakingSeat, referrerId in
        let subscription = try await pool.sqlDatabase.raw(
          """
          INSERT INTO "subscriptions" ("stripe_subscription_id", "stripe_subscription_status", "user_id")
          VALUES (\(bind: stripeSubscription.id), \(bind: stripeSubscription.status), \(bind: userId))
          RETURNING *
          """
        )
        .first(decoding: Models.Subscription.self)
        if isOwnerTakingSeat {
          try await pool.sqlDatabase.raw(
            """
            UPDATE "users"
            SET "subscription_id" = \(bind: subscription?.id), "referrer_id" = \(bind: referrerId)
            WHERE "users"."id" = \(bind: subscription?.userId)
            """
          )
          .run()
        }
        return subscription
      },
      deleteEnterpriseEmail: { userId in
        try await pool.sqlDatabase.raw(
          """
          DELETE FROM "enterprise_emails"
          WHERE "user_id" = \(bind: userId)
          """
        )
        .run()
      },
      deleteTeamInvite: { id in
        try await pool.sqlDatabase.raw(
          """
          DELETE FROM "team_invites"
          WHERE "id" = \(bind: id)
          """
        )
        .run()
      },
      execute: { sql in
        try await pool.sqlDatabase.raw(sql).all()
      },
      fetchAdmins: {
        try await pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "users"
          WHERE "users"."is_admin" = TRUE
          """
        )
        .all(decoding: Models.User.self)
      },
      fetchEmailSettingsForUserId: { userId in
        try await pool.sqlDatabase.raw(
          """
          SELECT "newsletter", "user_id"
          FROM "email_settings"
          WHERE "user_id" = \(bind: userId)
          """
        )
        .all(decoding: EmailSetting.self)
      },
      fetchEnterpriseAccountForDomain: { domain in
        try await pool.sqlDatabase.raw(
          """
          SELECT "company_name", "domain", "id", "subscription_id"
          FROM "enterprise_accounts"
          WHERE "domain" = \(bind: domain)
          LIMIT 1
          """
        )
        .first(decoding: EnterpriseAccount.self)
      },
      fetchEnterpriseAccountForSubscription: { subscriptionId in
        try await pool.sqlDatabase.raw(
          """
          SELECT "company_name", "domain", "id", "subscription_id"
          FROM "enterprise_accounts"
          WHERE "subscription_id" = \(bind: subscriptionId)
          LIMIT 1
          """
        )
        .first(decoding: EnterpriseAccount.self)
      },
      fetchEnterpriseEmails: {
        try await pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "enterprise_emails"
          """
        )
        .all(decoding: EnterpriseEmail.self)
      },
      fetchEpisodeCredits: { userId in
        try await pool.sqlDatabase.raw(
          """
          SELECT "episode_sequence", "user_id"
          FROM "episode_credits"
          WHERE "user_id" = \(bind: userId)
          """
        )
        .all(decoding: EpisodeCredit.self)
      },
      fetchEpisodeProgress: { userId, sequence in
        pool.sqlDatabase.raw(
          """
          SELECT "percent"
          FROM "episode_progresses"
          WHERE "user_id" = \(bind: userId)
          AND "episode_sequence" = \(bind: sequence)
          """
        )
        .first()
        .map { try? $0?.decode(column: "percent") }
      },
      fetchFreeEpisodeUsers: {
        pool.sqlDatabase.raw(
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
        .all(decoding: Models.User.self)
      },
      fetchGift: { id in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "gifts"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
        .first(decoding: Gift.self)
        .mapExcept(requireSome)
      },
      fetchGiftByStripePaymentIntentId: { paymentIntentId in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "gifts"
          WHERE "stripe_payment_intent_id" = \(bind: paymentIntentId)
          LIMIT 1
          """
        )
        .first(decoding: Gift.self)
        .mapExcept(requireSome)
      },
      fetchGiftsToDeliver: {
        pool.sqlDatabase.raw(
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
        .all(decoding: Gift.self)
      },
      fetchSubscriptionById: { id in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "subscriptions"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
        .first(decoding: Models.Subscription.self)
      },
      fetchSubscriptionByOwnerId: { ownerId in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "subscriptions"
          WHERE "user_id" = \(bind: ownerId)
          ORDER BY "created_at" DESC
          LIMIT 1
          """
        )
        .first(decoding: Models.Subscription.self)
      },
      fetchSubscriptionTeammatesByOwnerId: { ownerId in
        pool.sqlDatabase.raw(
          """
          SELECT "users".*
          FROM "users"
          INNER JOIN "subscriptions" ON "users"."subscription_id" = "subscriptions"."id"
          WHERE "subscriptions"."user_id" = \(bind: ownerId)
          """
        )
        .all(decoding: Models.User.self)
      },
      fetchTeamInvite: { id in
        pool.sqlDatabase.raw(
          """
          SELECT "created_at", "email", "id", "inviter_user_id"
          FROM "team_invites"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
        .first(decoding: TeamInvite.self)
      },
      fetchTeamInvites: { inviterId in
        pool.sqlDatabase.raw(
          """
          SELECT "created_at", "email", "id", "inviter_user_id"
          FROM "team_invites"
          WHERE "inviter_user_id" = \(bind: inviterId)
          """
        )
        .all(decoding: TeamInvite.self)
      },
      fetchUserByGitHub: { gitHubUserId in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "users"
          WHERE "github_user_id" = \(bind: gitHubUserId)
          LIMIT 1
          """
        )
        .first(decoding: Models.User.self)
      },
      fetchUserById: { id in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "users"
          WHERE "id" = \(bind: id)
          LIMIT 1
          """
        )
        .first(decoding: Models.User.self)
      },
      fetchUserByReferralCode: { referralCode in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "users"
          WHERE "referral_code" = \(bind: referralCode)
          LIMIT 1
          """
        )
        .first(decoding: Models.User.self)
      },
      fetchUserByRssSalt: { salt in
        pool.sqlDatabase.raw(
          """
          SELECT *
          FROM "users"
          WHERE "rss_salt" = \(bind: salt)
          LIMIT 1
          """
        )
        .first(decoding: Models.User.self)
      },
      fetchUsersSubscribedToNewsletter: { newsletter, nonsubscriberOrSubscriber in
        let condition: SQLQueryString
        switch nonsubscriberOrSubscriber {
        case .none:
          condition = ""
        case .some(.left):
          condition = #" AND "users"."subscription_id" IS NULL"#
        case .some(.right):
          condition = #" AND "users"."subscription_id" IS NOT NULL"#
        }
        return pool.sqlDatabase.raw(
          """
          SELECT "users".*
          FROM "email_settings" LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
          WHERE "email_settings"."newsletter" = \(bind: newsletter)\(condition)
          """
        )
        .all(decoding: Models.User.self)
      },
      fetchUsersToWelcome: { weeksAgo in
        let daysAgo = weeksAgo * 7
        let startDate: SQLQueryString = "CURRENT_DATE - INTERVAL '\(raw: "\(daysAgo)") DAY'"
        let endDate: SQLQueryString = "CURRENT_DATE - INTERVAL '\(raw: "\(daysAgo - 1)") DAY'"

        return pool.sqlDatabase.raw(
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
        .all(decoding: Models.User.self)
      },
      incrementEpisodeCredits: { userIds in
        let ids: SQLQueryString = """
          \(raw: userIds.map { "'\($0.rawValue.uuidString)'" }.joined(separator: ", "))
          """
        return pool.sqlDatabase.raw(
          """
          UPDATE "users"
          SET "episode_credit_count" = "episode_credit_count" + 1
          WHERE "id" IN (\(ids))
          RETURNING *
          """
        )
        .all(decoding: Models.User.self)
      },
      insertTeamInvite: { email, inviterUserId in
        pool.sqlDatabase.raw(
          """
          INSERT INTO "team_invites" ("email", "inviter_user_id")
          VALUES (\(bind: email), \(bind: inviterUserId))
          RETURNING *
          """
        )
        .first(decoding: TeamInvite.self)
        .mapExcept(requireSome)
      },
      migrate: {
        let database = pool.database(logger: Logger(label: "Postgres"))
        return sequence([
          database.run(#"CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "heroku_ext""#)
            .catch { _ in database.run(#"CREATE EXTENSION IF NOT EXISTS "pgcrypto""#) },
          database.run(#"CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "heroku_ext""#)
            .catch { _ in database.run(#"CREATE EXTENSION IF NOT EXISTS "uuid-ossp""#) },
          database.run(#"CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "heroku_ext""#)
            .catch { _ in database.run(#"CREATE EXTENSION IF NOT EXISTS "citext""#) },
          database.run(
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
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "subscriptions" (
              "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
              "user_id" uuid REFERENCES "users" ("id") NOT NULL,
              "stripe_subscription_id" character varying NOT NULL,
              "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
              "updated_at" timestamp without time zone
            );
            """
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "team_invites" (
              "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
              "email" character varying,
              "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
              "inviter_user_id" uuid REFERENCES "users" ("id") NOT NULL
            )
            """
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "email_settings" (
              "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
              "newsletter" character varying,
              "user_id" uuid REFERENCES "users" ("id") NOT NULL
            )
            """
          ),
          database.run(
            """
            ALTER TABLE "subscriptions"
            ADD COLUMN IF NOT EXISTS
            "stripe_subscription_status" character varying NOT NULL DEFAULT 'active'
            """
          ),
          database.run(
            """
            ALTER TABLE "users"
            ADD COLUMN IF NOT EXISTS
            "is_admin" boolean NOT NULL DEFAULT FALSE
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_subscriptions_on_stripe_subscription_id"
            ON "subscriptions" ("stripe_subscription_id")
            """
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "episode_credits" (
              "episode_sequence" integer,
              "user_id" uuid REFERENCES "users" ("id") NOT NULL
            )
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_credits_on_episode_sequence_and_user_id"
            ON "episode_credits" ("episode_sequence", "user_id")
            """
          ),
          database.run(
            """
            ALTER TABLE "users"
            ADD COLUMN IF NOT EXISTS
            "episode_credit_count" integer NOT NULL DEFAULT 0
            """
          ),
          database.run(
            """
            ALTER TABLE "episode_credits"
            ADD COLUMN IF NOT EXISTS
            "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
            """
          ),
          database.run(
            """
            ALTER TABLE "users"
            ADD COLUMN IF NOT EXISTS
            "rss_salt" uuid DEFAULT uuid_generate_v1mc() NOT NULL
            """
          ),
          database.run(
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
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_feed_request_events_on_type_user_agent_user_id"
            ON "feed_request_events" ("type", "user_agent", "user_id")
            """
          ),
          database.run(
            """
            ALTER TABLE "feed_request_events"
            ADD COLUMN IF NOT EXISTS
            "updated_at" timestamp without time zone DEFAULT NOW() NOT NULL
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_email_settings_on_newsletter_user_id"
            ON "email_settings" ("newsletter", "user_id")
            """
          ),
          database.run(
            """
            CREATE OR REPLACE FUNCTION update_updated_at()
            RETURNS TRIGGER AS $$
            BEGIN
              NEW."updated_at" = NOW();
              RETURN NEW;
            END;
            $$ LANGUAGE PLPGSQL;
            """
          ),
          database.run(
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
          ),
          database.run(
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
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_accounts_on_domain"
            ON "enterprise_accounts" ("domain")
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_accounts_on_subscription_id"
            ON "enterprise_accounts" ("subscription_id")
            """
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "enterprise_emails" (
              "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
              "email" character varying NOT NULL,
              "user_id" uuid REFERENCES "users" ("id") NOT NULL,
              "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
              "updated_at" timestamp without time zone
            )
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_emails_on_email"
            ON "enterprise_emails" (lower("email"))
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_emails_on_user_id"
            ON "enterprise_emails" ("user_id")
            """
          ),
          database.run(
            """
            ALTER TABLE "users"
            ADD FOREIGN KEY ("subscription_id") REFERENCES "subscriptions" ("id")
            """
          ),
          database.run(
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
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_progresses_on_episode_sequence_user_id"
            ON "episode_progresses" ("episode_sequence", "user_id")
            """
          ),
          database.run(
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
          ),
          database.run(
            """
            ALTER TABLE "users"
            ADD COLUMN IF NOT EXISTS
            "referral_code" character varying DEFAULT gen_shortid('users', 'referral_code') NOT NULL
            """
          ),
          database.run(
            """
            ALTER TABLE "users"
            ADD COLUMN IF NOT EXISTS
            "referrer_id" uuid REFERENCES "users" ("id")
            """
          ),
          database.run(
            """
            ALTER TABLE "subscriptions"
            ADD COLUMN IF NOT EXISTS
            "team_invite_code" character varying DEFAULT gen_shortid('subscriptions', 'team_invite_code') NOT NULL
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_users_referral_code"
            ON "users" ("referral_code")
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_subscriptions_team_invite_code"
            ON "subscriptions" ("team_invite_code")
            """
          ),
          database.run(
            """
            ALTER TABLE "subscriptions"
            ADD COLUMN IF NOT EXISTS
            "deactivated" boolean NOT NULL DEFAULT FALSE
            """
          ),
          database.run(
            """
            ALTER TABLE "users"
            ALTER COLUMN "rss_salt" TYPE citext
            """
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_users_on_rss_salt"
            ON "users" ("rss_salt")
            """
          ),
          database.run(
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
          ),
          database.run(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS "index_gifts_on_stripe_payment_intent_id"
            ON "gifts" ("stripe_payment_intent_id")
            """
          ),
          database.run(
            """
            ALTER TABLE "gifts"
            ADD COLUMN IF NOT EXISTS "stripe_subscription_id" character varying
            """
          ),
          database.run(
            """
            ALTER TABLE "gifts"
            DROP COLUMN IF EXISTS "stripe_coupon_id"
            """
          ),
          database.run(
            """
            ALTER TABLE "gifts"
            ADD COLUMN IF NOT EXISTS
            "delivered" boolean NOT NULL DEFAULT FALSE
            """
          ),
          database.run(
            """
            ALTER TABLE "gifts"
            ADD COLUMN IF NOT EXISTS
            "stripe_payment_intent_status" character varying NOT NULL DEFAULT '\(raw: PaymentIntent.Status.requiresPaymentMethod.rawValue)'
            """
          ),
        ])
        .map(const(unit))

      },
      redeemEpisodeCredit: { episodeSequence, userId in
        pool.sqlDatabase.raw(
          """
          INSERT INTO "episode_credits" ("episode_sequence", "user_id")
          VALUES (\(bind: episodeSequence), \(bind: userId))
          """
        )
        .run()
      },
      removeTeammateUserIdFromSubscriptionId: { teammateUserId, subscriptionId in
        pool.sqlDatabase.raw(
          """
          UPDATE "users"
          SET "subscription_id" = NULL
          WHERE "users"."id" = \(bind: teammateUserId)
          AND "users"."subscription_id" = \(bind: subscriptionId)
          """
        )
        .run()
      },
      sawUser: { userId in
        pool.sqlDatabase.raw(
          """
          UPDATE "users"
          SET "updated_at" = NOW()
          WHERE "id" = \(bind: userId)
          """
        )
        .run()
      },
      updateEmailSettings: { settings, userId in
        guard let settings = settings else { return pure(unit) }

        let deleteEmailSettings = pool.sqlDatabase.raw(
          """
          DELETE FROM "email_settings"
          WHERE "user_id" = \(bind: userId)
          """
        )
        .run()

        let updateEmailSettings = sequence(
          settings.map { type in
            pool.sqlDatabase.raw(
              """
              INSERT INTO "email_settings" ("newsletter", "user_id")
              VALUES (\(bind: type), \(bind: userId))
              """
            )
            .run()
          }
        )
        .map(const(unit))

        return sequence([deleteEmailSettings, updateEmailSettings])
          .map(const(unit))
      },
      updateEpisodeProgress: { episodeSequence, percent, userId in
        pool.sqlDatabase.raw(
          """
          INSERT INTO "episode_progresses" ("episode_sequence", "percent", "user_id")
          VALUES (\(bind: episodeSequence), \(bind: percent), \(bind: userId))
          ON CONFLICT ("episode_sequence", "user_id") DO UPDATE
          SET "percent" = \(bind: percent)
          """
        )
        .run()
      },
      updateGift: { id, stripeSubscriptionId in
        pool.sqlDatabase.raw(
          """
          UPDATE "gifts"
          SET "stripe_subscription_id" = \(bind: stripeSubscriptionId)
          WHERE "id" = \(bind: id)
          RETURNING *
          """
        )
        .first(decoding: Gift.self)
        .mapExcept(requireSome)
      },
      updateGiftStatus: { id, status, delivered in
        pool.sqlDatabase.raw(
          """
          UPDATE "gifts"
          SET "stripe_payment_intent_status" = \(bind: status), "delivered" = \(bind: delivered)
          WHERE "id" = \(bind: id)
          RETURNING *
          """
        )
        .first(decoding: Gift.self)
        .mapExcept(requireSome)
      },
      updateStripeSubscription: { stripeSubscription in
        pool.sqlDatabase.raw(
          """
          UPDATE "subscriptions"
          SET "stripe_subscription_status" = \(bind: stripeSubscription.status)
          WHERE "subscriptions"."stripe_subscription_id" = \(bind: stripeSubscription.id)
          RETURNING *
          """
        )
        .first(decoding: Models.Subscription.self)
      },
      updateUser: { userId, name, email, episodeCreditCount, rssSalt in
        pool.sqlDatabase.raw(
          """
          UPDATE "users"
          SET "name" = COALESCE(\(bind: name), "name"),
            "email" = COALESCE(\(bind: email), "email"),
            "episode_credit_count" = COALESCE(\(bind: episodeCreditCount), "episode_credit_count"),
            "rss_salt" = COALESCE(\(bind: rssSalt), "rss_salt")
          WHERE "id" = \(bind: userId)
          """
        )
        .run()
      },
      upsertUser: { envelope, email, now in
        pool.sqlDatabase.raw(
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
        .first(decoding: Models.User.self)
      }
    )
  }
}
