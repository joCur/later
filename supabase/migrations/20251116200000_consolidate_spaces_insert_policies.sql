-- Consolidate spaces INSERT policies to resolve conflict
-- Problem: Two INSERT policies ("Anonymous users limited to 1 space" and "Users can insert own spaces")
-- Both apply to authenticated users, causing permission denied
-- Solution: Drop separate policies and create single unified INSERT policy

-- Drop the conflicting policies
DROP POLICY IF EXISTS "Anonymous users limited to 1 space" ON spaces;
DROP POLICY IF EXISTS "Users can insert own spaces" ON spaces;

-- Create unified INSERT policy with both owner check and anonymous limit
CREATE POLICY "Users can insert own spaces with limits"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  -- Must be owner
  user_id = auth.uid()
  AND
  -- If anonymous, enforce 1 space limit
  (
    (SELECT is_anonymous FROM auth.users WHERE id = auth.uid()) = false
    OR
    (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 1
  )
);
