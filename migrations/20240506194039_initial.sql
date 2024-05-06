-- Add migration script here
CREATE EXTENSION "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4 (),
  username VARCHAR NOT NULL,
  password VARCHAR NOT NULL,
  salt VARCHAR NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT NOW (),
  created_by UUID REFERNECES users (id) NULL,
  modified TIMESTAMP NOT NULL DEFAULT NOW (),
  modified_by UUID REFERENCES users (id) NULL
);

-- Maintains the teams within the system
CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4 (),
  team_name VARCHAR NOT NULL,
  parent_id UUID REFERENCES teams (id) NULL,
  description VARCHAR NULL,
  created TIMESTAMP NOT NULL DEFAULT NOW (),
  created_by UUID REFERENCES users (id) NOT NULL,
  modified TIMESTAMP NOT NULL DEFAULT NOW (),
  modified_by UUID REFERENCES users (id) NOT NULL
);

CREATE TABLE IF NOT EXISTS team_members (
  user_id UUID REFERENCES users (id) NOT NULL,
  team_id UUID REFERENCES teams (id) NOT NULL,
  team_role VARCHAR NOT NULL DEFAULT 'DEFAULT',
  -- Timelines
  created TIMESTAMP NOT NULL DEFAULT NOW (),
  created_by UUID REFERENCES users (id) NOT NULL,
  modified TIMESTAMP NOT NULL DEFAULT NOW (),
  modified_by UUID REFERENCES users (id) NOT NULL
)
-- Maintains a list of incidents
CREATE TABLE IF NOT EXISTS incidents (
  id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4 (),
  incident_id VARCHAR NOT NULL,
  status VARCHAR NOT NULL DEFAULT 'OPEN',
  assignees JSONB NOT NULL DEFAULT '{}',
  properties JSONB NOT NULL DEFAULT '{}',
  source_name VARCHAR NOT NULL 'MANUAL',
  source_data JSONB NOT NULL DEFAULT '{}',
  -- Timelines
  raised_at TIMESTAMP NOT NULL DEFAULT NOW (),
  closed_at TIMESTAMP NULL,
  created TIMESTAMP NOT NULL DEFAULT NOW (),
  created_by UUID REFERENCES users (id) NOT NULL,
  modified TIMESTAMP NOT NULL DEFAULT NOW (),
  modified_by UUID REFERENCES users (id) NOT NULL
);

CREATE TABLE IF NOT EXISTS incident_commentary (
  id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4 (),
  incident_id UUID REFERENCES incidents (id) NOT NULL,
  commentary TEXT NOT NULL,
  commentary_html TEXT NOT NULL,
  comment_source VARCHAR NOT NULL DEFAULT 'IN_APP',
  -- Timeline
  created TIMESTAMP NOT NULL DEFAULT NOW (),
  created_by UUID REFERENCES users (id) NOT NULL,
  modified TIMESTAMP NOT NULL DEFAULT NOW (),
  modified_by UUID REFERENCES users (id) NOT NULL
);

-- Contains information about updates / changes to an incident
-- we track changes over time to understand when an incident 
-- is happening
CREATE TABLE IF NOT EXISTS incident_event_log (
  id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4 (),
  incident_id UUID REFERENCES incidents (id) NOT NULL,
  operation VARCHAR NOT NULL DEFAULT 'UPDATE',
  property VARCHAR NOT NULL,
  property_value VARCHAR NOT NULL,
  property_type VARCHAR NOT NULL,
  modified TIMESTAMP NOT NULL DEFAULT NOW (),
  modified_by UUID REFERENCES users (id) NULL
);
