

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."assignee_status_enum" AS ENUM (
    'Assigned',
    'In Progress',
    'Completed'
);


ALTER TYPE "public"."assignee_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."label_status_enum" AS ENUM (
    'Active',
    'Inactive'
);


ALTER TYPE "public"."label_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."member_status_enum" AS ENUM (
    'Active',
    'Inactive'
);


ALTER TYPE "public"."member_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."payment_status_enum" AS ENUM (
    'Pending',
    'Completed',
    'Failed'
);


ALTER TYPE "public"."payment_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."project_status_enum" AS ENUM (
    'Planning',
    'In Progress',
    'Review',
    'Completed'
);


ALTER TYPE "public"."project_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."release_status_enum" AS ENUM (
    'Planning',
    'In Development',
    'Testing',
    'Released'
);


ALTER TYPE "public"."release_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."risk_level_enum" AS ENUM (
    'Low',
    'Medium',
    'High'
);


ALTER TYPE "public"."risk_level_enum" OWNER TO "postgres";


CREATE TYPE "public"."subscription_plan_enum" AS ENUM (
    'Monthly',
    'Yearly'
);


ALTER TYPE "public"."subscription_plan_enum" OWNER TO "postgres";


CREATE TYPE "public"."task_priority_enum" AS ENUM (
    'Low',
    'Medium',
    'High',
    'Critical'
);


ALTER TYPE "public"."task_priority_enum" OWNER TO "postgres";


CREATE TYPE "public"."task_status_enum" AS ENUM (
    'Backlog',
    'In Progress',
    'Testing',
    'Review',
    'Completed'
);


ALTER TYPE "public"."task_status_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.id = auth.uid() AND r.name = 'admin'
  );
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."payment_plans" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "plan_type" "public"."subscription_plan_enum" NOT NULL,
    "price" numeric(12,2) NOT NULL,
    "currency" character varying(10) DEFAULT 'USD'::character varying,
    "duration_in_days" integer NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."payment_plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "subscription_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "amount" numeric(12,2) NOT NULL,
    "currency" character varying(10) DEFAULT 'USD'::character varying,
    "status" "public"."payment_status_enum" DEFAULT 'Pending'::"public"."payment_status_enum",
    "payment_method" character varying(50),
    "transaction_id" character varying(255),
    "paid_at" timestamp without time zone,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."project_members" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid",
    "user_id" "uuid",
    "status" "public"."member_status_enum" DEFAULT 'Active'::"public"."member_status_enum",
    "joined_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."project_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."projects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(200) NOT NULL,
    "description" "text",
    "status" "public"."project_status_enum" DEFAULT 'Planning'::"public"."project_status_enum",
    "progress_percentage" integer DEFAULT 0,
    "budget" numeric(12,2),
    "team_size" integer,
    "risk_level" "public"."risk_level_enum" DEFAULT 'Low'::"public"."risk_level_enum",
    "start_date" "date",
    "end_date" "date",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."projects" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."releases" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(50),
    "description" character varying(300),
    "project_id" "uuid",
    "version" character varying(50) NOT NULL,
    "features" numeric,
    "risk_level" "public"."risk_level_enum" DEFAULT 'Low'::"public"."risk_level_enum",
    "status" "public"."release_status_enum" DEFAULT 'Planning'::"public"."release_status_enum",
    "release_date" "date"
);


ALTER TABLE "public"."releases" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(50) NOT NULL,
    "description" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscriptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "auto_renew" boolean DEFAULT true,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."subscriptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."task_assignees" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "assigned_by" "uuid" NOT NULL,
    "status" "public"."assignee_status_enum" DEFAULT 'Assigned'::"public"."assignee_status_enum",
    "assigned_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."task_assignees" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."task_labels" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "task_id" "uuid",
    "name" character varying(50) NOT NULL,
    "status" "public"."label_status_enum" DEFAULT 'Active'::"public"."label_status_enum"
);


ALTER TABLE "public"."task_labels" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "title" character varying(200) NOT NULL,
    "description" "text",
    "status" "public"."task_status_enum" DEFAULT 'Backlog'::"public"."task_status_enum",
    "priority" "public"."task_priority_enum" DEFAULT 'Medium'::"public"."task_priority_enum",
    "progress_percentage" integer DEFAULT 0,
    "estimated_hours" numeric(6,2),
    "estimated_days" numeric(5,2),
    "start_date" "date",
    "due_date" "date",
    "completed_at" "date",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."tasks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "color_primary" character varying(7) DEFAULT '#FFFFFF'::character varying,
    "color_secondary" character varying(7) DEFAULT '#000000'::character varying,
    "color_accent" character varying(7) DEFAULT '#007BFF'::character varying,
    "application_name" character varying(200) DEFAULT 'MyApp'::character varying,
    "timezone" character varying(50) DEFAULT 'UTC-5'::character varying,
    "support_email" character varying(255) DEFAULT 'support@example.com'::character varying,
    "dark_mode" boolean DEFAULT false,
    "notification" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "full_name" character varying(150) NOT NULL,
    "email" character varying(150) NOT NULL,
    "password_hash" "text" NOT NULL,
    "role_id" "uuid",
    "parent_id" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "status" boolean
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workflows" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(200) NOT NULL,
    "stages" character varying[] NOT NULL,
    "description" "text",
    "created_by" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."workflows" OWNER TO "postgres";


ALTER TABLE ONLY "public"."payment_plans"
    ADD CONSTRAINT "payment_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_transaction_id_key" UNIQUE ("transaction_id");



ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "project_members_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."releases"
    ADD CONSTRAINT "releases_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."task_assignees"
    ADD CONSTRAINT "task_assignees_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."task_labels"
    ADD CONSTRAINT "task_labels_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."task_labels"
    ADD CONSTRAINT "task_labels_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workflows"
    ADD CONSTRAINT "workflows_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "public"."subscriptions"("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "project_members_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");



ALTER TABLE ONLY "public"."project_members"
    ADD CONSTRAINT "project_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."releases"
    ADD CONSTRAINT "releases_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."task_assignees"
    ADD CONSTRAINT "task_assignees_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."task_assignees"
    ADD CONSTRAINT "task_assignees_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."task_assignees"
    ADD CONSTRAINT "task_assignees_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."task_labels"
    ADD CONSTRAINT "task_labels_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");



ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id");



ALTER TABLE ONLY "public"."workflows"
    ADD CONSTRAINT "workflows_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



CREATE POLICY "Allow delete for admin or creator" ON "public"."project_members" FOR DELETE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "project_members"."project_id")))));



CREATE POLICY "Allow delete for admin or creator" ON "public"."projects" FOR DELETE USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow delete for admin or creator" ON "public"."releases" FOR DELETE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "releases"."project_id")))));



CREATE POLICY "Allow delete for admin or creator" ON "public"."task_assignees" FOR DELETE USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."tasks" "t"
  WHERE (("t"."id" = "task_assignees"."task_id") AND ("t"."created_by" = "auth"."uid"()))))));



CREATE POLICY "Allow delete for admin or creator" ON "public"."task_labels" FOR DELETE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "t"."created_by"
   FROM "public"."tasks" "t"
  WHERE ("t"."id" = "task_labels"."task_id")))));



CREATE POLICY "Allow delete for admin or creator" ON "public"."tasks" FOR DELETE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "tasks"."project_id")))));



CREATE POLICY "Allow delete for admin or creator" ON "public"."workflows" FOR DELETE USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow delete for admins" ON "public"."users" FOR DELETE USING (((( SELECT "roles"."name"
   FROM "public"."roles"
  WHERE ("roles"."id" = ( SELECT "users_1"."role_id"
           FROM "public"."users" "users_1"
          WHERE ("users_1"."id" = "auth"."uid"())))))::"text" = 'admin'::"text"));



CREATE POLICY "Allow delete for authenticated users" ON "public"."roles" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Allow delete own or admin" ON "public"."user_settings" FOR DELETE USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "Allow insert for admin creator or member" ON "public"."task_labels" FOR INSERT WITH CHECK (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "t"."created_by"
   FROM "public"."tasks" "t"
  WHERE ("t"."id" = "task_labels"."task_id"))) OR (EXISTS ( SELECT 1
   FROM ("public"."project_members" "pm"
     JOIN "public"."tasks" "t" ON (("t"."project_id" = "pm"."project_id")))
  WHERE (("t"."id" = "task_labels"."task_id") AND ("pm"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow insert for admin creator or member" ON "public"."tasks" FOR INSERT WITH CHECK (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "tasks"."project_id"))) OR (EXISTS ( SELECT 1
   FROM "public"."project_members" "pm"
  WHERE (("pm"."project_id" = "pm"."project_id") AND ("pm"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow insert for admin or creator" ON "public"."project_members" FOR INSERT WITH CHECK (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "project_members"."project_id")))));



CREATE POLICY "Allow insert for admin or creator" ON "public"."releases" FOR INSERT WITH CHECK (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "releases"."project_id")))));



CREATE POLICY "Allow insert for admin or creator" ON "public"."task_assignees" FOR INSERT WITH CHECK (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."tasks" "t"
  WHERE (("t"."id" = "task_assignees"."task_id") AND ("t"."created_by" = "auth"."uid"()))))));



CREATE POLICY "Allow insert for admins" ON "public"."users" FOR INSERT WITH CHECK (((( SELECT "roles"."name"
   FROM "public"."roles"
  WHERE ("roles"."id" = ( SELECT "users_1"."role_id"
           FROM "public"."users" "users_1"
          WHERE ("users_1"."id" = "auth"."uid"())))))::"text" = 'admin'::"text"));



CREATE POLICY "Allow insert for authenticated" ON "public"."projects" FOR INSERT WITH CHECK ((("auth"."uid"() IS NOT NULL) AND ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow insert for authenticated" ON "public"."workflows" FOR INSERT WITH CHECK ((("auth"."uid"() IS NOT NULL) AND ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow insert for authenticated users" ON "public"."roles" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Allow insert own or admin" ON "public"."user_settings" FOR INSERT WITH CHECK ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "Allow select for admin creator or assignee" ON "public"."task_assignees" FOR SELECT USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."tasks" "t"
  WHERE (("t"."id" = "task_assignees"."task_id") AND (("t"."created_by" = "auth"."uid"()) OR ("task_assignees"."user_id" = "auth"."uid"())))))));



CREATE POLICY "Allow select for admin creator or member" ON "public"."project_members" FOR SELECT USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "project_members"."project_id"))) OR (EXISTS ( SELECT 1
   FROM "public"."project_members" "pm"
  WHERE (("pm"."project_id" = "project_members"."project_id") AND ("pm"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow select for admin creator or member" ON "public"."releases" FOR SELECT USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "releases"."project_id"))) OR (EXISTS ( SELECT 1
   FROM "public"."project_members" "pm"
  WHERE (("pm"."project_id" = "pm"."project_id") AND ("pm"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow select for admin creator or member" ON "public"."task_labels" FOR SELECT USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "t"."created_by"
   FROM "public"."tasks" "t"
  WHERE ("t"."id" = "task_labels"."task_id"))) OR (EXISTS ( SELECT 1
   FROM ("public"."project_members" "pm"
     JOIN "public"."tasks" "t" ON (("t"."project_id" = "pm"."project_id")))
  WHERE (("t"."id" = "task_labels"."task_id") AND ("pm"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow select for admin creator or member" ON "public"."tasks" FOR SELECT USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "tasks"."project_id"))) OR (EXISTS ( SELECT 1
   FROM "public"."project_members" "pm"
  WHERE (("pm"."project_id" = "tasks"."project_id") AND ("pm"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow select for admin or creator" ON "public"."projects" FOR SELECT USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow select for admin or creator" ON "public"."workflows" FOR SELECT USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow select for authenticated users" ON "public"."roles" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Allow select own or admin" ON "public"."user_settings" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "Allow select own or admin" ON "public"."users" FOR SELECT USING ((("id" = "auth"."uid"()) OR ((( SELECT "roles"."name"
   FROM "public"."roles"
  WHERE ("roles"."id" = ( SELECT "users_1"."role_id"
           FROM "public"."users" "users_1"
          WHERE ("users_1"."id" = "auth"."uid"())))))::"text" = 'admin'::"text")));



CREATE POLICY "Allow update for admin creator or assignee" ON "public"."task_assignees" FOR UPDATE USING (("public"."is_admin"() OR ("assigned_by" = "auth"."uid"()) OR ("user_id" = "auth"."uid"())));



CREATE POLICY "Allow update for admin creator or assignee" ON "public"."tasks" FOR UPDATE USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow update for admin or creator" ON "public"."project_members" FOR UPDATE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "project_members"."project_id")))));



CREATE POLICY "Allow update for admin or creator" ON "public"."projects" FOR UPDATE USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow update for admin or creator" ON "public"."releases" FOR UPDATE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "projects"."created_by"
   FROM "public"."projects"
  WHERE ("projects"."id" = "releases"."project_id")))));



CREATE POLICY "Allow update for admin or creator" ON "public"."task_labels" FOR UPDATE USING (("public"."is_admin"() OR ("auth"."uid"() = ( SELECT "t"."created_by"
   FROM "public"."tasks" "t"
  WHERE ("t"."id" = "task_labels"."task_id")))));



CREATE POLICY "Allow update for admin or creator" ON "public"."workflows" FOR UPDATE USING (("public"."is_admin"() OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Allow update for authenticated users" ON "public"."roles" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Allow update own or admin" ON "public"."user_settings" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "Allow update own or admin" ON "public"."users" FOR UPDATE USING ((("id" = "auth"."uid"()) OR ((( SELECT "roles"."name"
   FROM "public"."roles"
  WHERE ("roles"."id" = ( SELECT "users_1"."role_id"
           FROM "public"."users" "users_1"
          WHERE ("users_1"."id" = "auth"."uid"())))))::"text" = 'admin'::"text")));



ALTER TABLE "public"."payment_plans" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "payment_plans_delete_admin" ON "public"."payment_plans" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "payment_plans_insert_admin" ON "public"."payment_plans" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "payment_plans_select_authenticated" ON "public"."payment_plans" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "payment_plans_update_admin" ON "public"."payment_plans" FOR UPDATE USING ("public"."is_admin"());



ALTER TABLE "public"."payments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "payments_delete_admin" ON "public"."payments" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "payments_insert_own_or_admin" ON "public"."payments" FOR INSERT WITH CHECK ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "payments_select_own_or_admin" ON "public"."payments" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "payments_update_own_or_admin" ON "public"."payments" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



ALTER TABLE "public"."project_members" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."projects" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."releases" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscriptions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "subscriptions_delete_admin" ON "public"."subscriptions" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "subscriptions_insert_own_or_admin" ON "public"."subscriptions" FOR INSERT WITH CHECK ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "subscriptions_select_own_or_admin" ON "public"."subscriptions" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "subscriptions_update_own_or_admin" ON "public"."subscriptions" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



ALTER TABLE "public"."task_assignees" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."task_labels" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tasks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."workflows" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";


















GRANT ALL ON TABLE "public"."payment_plans" TO "anon";
GRANT ALL ON TABLE "public"."payment_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."payment_plans" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON TABLE "public"."project_members" TO "anon";
GRANT ALL ON TABLE "public"."project_members" TO "authenticated";
GRANT ALL ON TABLE "public"."project_members" TO "service_role";



GRANT ALL ON TABLE "public"."projects" TO "anon";
GRANT ALL ON TABLE "public"."projects" TO "authenticated";
GRANT ALL ON TABLE "public"."projects" TO "service_role";



GRANT ALL ON TABLE "public"."releases" TO "anon";
GRANT ALL ON TABLE "public"."releases" TO "authenticated";
GRANT ALL ON TABLE "public"."releases" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscriptions" TO "service_role";



GRANT ALL ON TABLE "public"."task_assignees" TO "anon";
GRANT ALL ON TABLE "public"."task_assignees" TO "authenticated";
GRANT ALL ON TABLE "public"."task_assignees" TO "service_role";



GRANT ALL ON TABLE "public"."task_labels" TO "anon";
GRANT ALL ON TABLE "public"."task_labels" TO "authenticated";
GRANT ALL ON TABLE "public"."task_labels" TO "service_role";



GRANT ALL ON TABLE "public"."tasks" TO "anon";
GRANT ALL ON TABLE "public"."tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."tasks" TO "service_role";



GRANT ALL ON TABLE "public"."user_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_settings" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."workflows" TO "anon";
GRANT ALL ON TABLE "public"."workflows" TO "authenticated";
GRANT ALL ON TABLE "public"."workflows" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
