BEGIN;

-- The published taxonomy remains immutable. Tenant-specific accounts are
-- additive and engagement-scoped; presentation changes are append-only.
ALTER TABLE canonical_account
  ADD COLUMN tenant_id uuid REFERENCES tenant(id),
  ADD COLUMN engagement_id uuid REFERENCES engagement(id),
  ADD COLUMN is_protected boolean NOT NULL DEFAULT true,
  ADD COLUMN created_by text,
  ADD COLUMN created_at timestamptz NOT NULL DEFAULT now(),
  ADD CONSTRAINT canonical_account_scope_ck CHECK(
    (tenant_id IS NULL AND engagement_id IS NULL AND is_protected)
    OR (tenant_id IS NOT NULL AND engagement_id IS NOT NULL AND NOT is_protected)
  ),
  ADD CONSTRAINT canonical_account_tenant_engagement_fk
    FOREIGN KEY(tenant_id,engagement_id) REFERENCES engagement(tenant_id,id);

CREATE INDEX canonical_account_engagement_idx
  ON canonical_account(tenant_id,engagement_id,canonical_code)
  WHERE tenant_id IS NOT NULL;

CREATE TABLE engagement_canonical_model_override(
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenant(id),
  engagement_id uuid NOT NULL REFERENCES engagement(id),
  canonical_account_id uuid NOT NULL REFERENCES canonical_account(id),
  version integer NOT NULL CHECK(version > 0),
  display_name text NOT NULL CHECK(btrim(display_name) <> ''),
  presentation_group text,
  display_order integer NOT NULL DEFAULT 0 CHECK(display_order >= 0),
  is_active boolean NOT NULL DEFAULT true,
  change_reason text NOT NULL CHECK(btrim(change_reason) <> ''),
  created_by text NOT NULL CHECK(btrim(created_by) <> ''),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,engagement_id,canonical_account_id,version),
  FOREIGN KEY(tenant_id,engagement_id) REFERENCES engagement(tenant_id,id)
);

CREATE INDEX engagement_canonical_model_current_idx
  ON engagement_canonical_model_override(
    tenant_id,engagement_id,canonical_account_id,version DESC
  );

CREATE RULE engagement_canonical_model_override_no_update AS
  ON UPDATE TO engagement_canonical_model_override DO INSTEAD NOTHING;
CREATE RULE engagement_canonical_model_override_no_delete AS
  ON DELETE TO engagement_canonical_model_override DO INSTEAD NOTHING;

CREATE OR REPLACE FUNCTION prevent_protected_canonical_account_mutation()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.is_protected THEN
    RAISE EXCEPTION 'protected canonical accounts are immutable'
      USING ERRCODE = '55000';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER canonical_account_protected_no_update
BEFORE UPDATE ON canonical_account FOR EACH ROW
EXECUTE FUNCTION prevent_protected_canonical_account_mutation();

CREATE TRIGGER canonical_account_protected_no_delete
BEFORE DELETE ON canonical_account FOR EACH ROW
EXECUTE FUNCTION prevent_protected_canonical_account_mutation();

DROP POLICY canonical_account_authenticated_actor ON canonical_account;
CREATE POLICY canonical_account_select ON canonical_account FOR SELECT TO accounts_app
  USING(
    (tenant_id IS NULL OR tenant_id::text = nullif(current_setting('app.tenant_id',true),''))
    AND EXISTS(
      SELECT 1 FROM tenant_member app_tm
      WHERE app_tm.tenant_id::text = nullif(current_setting('app.tenant_id',true),'')
        AND app_tm.actor_id = nullif(current_setting('app.actor_id',true),'')
    )
  );
CREATE POLICY canonical_account_insert_custom ON canonical_account FOR INSERT TO accounts_app
  WITH CHECK(
    tenant_id::text = nullif(current_setting('app.tenant_id',true),'')
    AND engagement_id IS NOT NULL AND NOT is_protected
    AND EXISTS(
      SELECT 1 FROM tenant_member app_tm
      WHERE app_tm.tenant_id=canonical_account.tenant_id
        AND app_tm.actor_id=nullif(current_setting('app.actor_id',true),'')
    )
  );

ALTER TABLE engagement_canonical_model_override ENABLE ROW LEVEL SECURITY;
ALTER TABLE engagement_canonical_model_override FORCE ROW LEVEL SECURITY;
CREATE POLICY engagement_canonical_model_override_select
  ON engagement_canonical_model_override FOR SELECT TO accounts_app
  USING(
    tenant_id::text = nullif(current_setting('app.tenant_id',true),'')
    AND EXISTS(
      SELECT 1 FROM tenant_member app_tm
      WHERE app_tm.tenant_id=engagement_canonical_model_override.tenant_id
        AND app_tm.actor_id=nullif(current_setting('app.actor_id',true),'')
    )
  );
CREATE POLICY engagement_canonical_model_override_insert
  ON engagement_canonical_model_override FOR INSERT TO accounts_app
  WITH CHECK(
    tenant_id::text = nullif(current_setting('app.tenant_id',true),'')
    AND EXISTS(
      SELECT 1 FROM tenant_member app_tm
      WHERE app_tm.tenant_id=engagement_canonical_model_override.tenant_id
        AND app_tm.actor_id=nullif(current_setting('app.actor_id',true),'')
    )
  );
CREATE POLICY engagement_canonical_model_override_owner
  ON engagement_canonical_model_override TO neondb_owner USING(true) WITH CHECK(true);

GRANT SELECT,INSERT ON canonical_account TO accounts_app;
GRANT SELECT,INSERT ON engagement_canonical_model_override TO accounts_app;
REVOKE UPDATE,DELETE,TRUNCATE ON canonical_account,engagement_canonical_model_override FROM accounts_app,PUBLIC;

INSERT INTO schema_migration(version,description)
VALUES('0029','engagement-scoped governed canonical model overlays')
ON CONFLICT(version) DO NOTHING;

COMMIT;
