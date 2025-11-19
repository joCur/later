-- Add Full-Text Search Support
-- Adds tsvector columns and GIN indexes for fast full-text search across all content types
-- Uses German text search configuration for proper stemming (e.g., "laufen" matches "läuft", "lief")
--
-- NOTE: This migration uses 'german' language configuration for all full-text search indexes.
-- To support additional languages in the future:
--   1. Add a language column to relevant tables (e.g., user preferences or per-document language)
--   2. Create separate tsvector columns for each supported language
--   3. Update search queries to target the appropriate language-specific column
--   4. Consider using 'simple' configuration for language-agnostic substring matching
-- For MVP, German configuration provides good results for the target user base.

-- Add tsvector column to notes table (generated from title + content)
ALTER TABLE notes
ADD COLUMN fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('german', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('german', coalesce(content, '')), 'B')
) STORED;

-- Add tsvector column to todo_lists table (generated from name + description)
ALTER TABLE todo_lists
ADD COLUMN fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('german', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('german', coalesce(description, '')), 'B')
) STORED;

-- Add tsvector column to lists table (generated from name)
ALTER TABLE lists
ADD COLUMN fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('german', coalesce(name, '')), 'A')
) STORED;

-- Add tsvector column to todo_items table (generated from title + description)
ALTER TABLE todo_items
ADD COLUMN fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('german', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('german', coalesce(description, '')), 'B')
) STORED;

-- Add tsvector column to list_items table (generated from title + notes)
ALTER TABLE list_items
ADD COLUMN fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('german', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('german', coalesce(notes, '')), 'B')
) STORED;

-- Create GIN indexes on all fts columns for fast full-text search
CREATE INDEX idx_notes_fts ON notes USING GIN (fts);
CREATE INDEX idx_todo_lists_fts ON todo_lists USING GIN (fts);
CREATE INDEX idx_lists_fts ON lists USING GIN (fts);
CREATE INDEX idx_todo_items_fts ON todo_items USING GIN (fts);
CREATE INDEX idx_list_items_fts ON list_items USING GIN (fts);

-- Create GIN indexes on tags arrays for fast tag filtering
CREATE INDEX idx_notes_tags ON notes USING GIN (tags);
CREATE INDEX idx_todo_items_tags ON todo_items USING GIN (tags);

-- Create composite indexes for space-scoped search (space_id + updated_at pattern)
-- These help with filtering by space and sorting by updated_at
CREATE INDEX idx_notes_space_updated ON notes(space_id, updated_at DESC);
CREATE INDEX idx_todo_lists_space_updated ON todo_lists(space_id, updated_at DESC);
CREATE INDEX idx_lists_space_updated ON lists(space_id, updated_at DESC);

-- Note: Child items (todo_items, list_items) don't need space_id indexes
-- since they're accessed via JOIN with their parent tables
