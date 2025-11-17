-- Fix spaces INSERT policy issue
-- The "Users can access own spaces" policy has FOR ALL but only USING clause
-- This causes INSERT to fail because it needs WITH CHECK for inserts

-- Drop and recreate the base spaces policy with proper INSERT support
DROP POLICY IF EXISTS "Users can access own spaces" ON spaces;

-- Create separate policies for different operations
-- SELECT, UPDATE, DELETE: Use USING clause
CREATE POLICY "Users can view own spaces"
ON spaces FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Users can update own spaces"
ON spaces FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own spaces"
ON spaces FOR DELETE
USING (user_id = auth.uid());

-- INSERT: Use WITH CHECK clause (works with anonymous limit policy)
CREATE POLICY "Users can insert own spaces"
ON spaces FOR INSERT
WITH CHECK (user_id = auth.uid());
