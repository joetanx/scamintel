CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    object_id TEXT NOT NULL,
    display_name TEXT,
    email TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, object_id)
);

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY,
    reporter_user_id UUID NULL REFERENCES users(id),
    channel TEXT NOT NULL CHECK (channel IN ('web', 'email', 'telegram')),
    channel_message_id TEXT NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    subject TEXT,
    body_text TEXT NOT NULL,
    processing_status TEXT NOT NULL DEFAULT 'pending',
    assessment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS entities (
    id UUID PRIMARY KEY,
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    matches TEXT NOT NULL DEFAULT 'none' CHECK (matches IN ('scamintel', 'microsoft_ti', 'public_web', 'none')),
    evidence_ref TEXT,
    confidence TEXT NOT NULL DEFAULT 'medium' CHECK (confidence IN ('low', 'medium', 'high')),
    flag_for_scamintel BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_entities_type_value ON entities (type, value);

CREATE TABLE IF NOT EXISTS assessments (
    id UUID PRIMARY KEY,
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    verdict TEXT NOT NULL CHECK (verdict IN ('suspected_scam', 'likely_benign', 'inconclusive')),
    rationale TEXT NOT NULL,
    actor_type TEXT NOT NULL CHECK (actor_type IN ('agent', 'staff')),
    actor_user_id UUID NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (report_id, version)
);