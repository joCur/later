-- Fix permission denied error when RLS policies try to read auth.users
-- Problem: Policies check (SELECT is_anonymous FROM auth.users WHERE id = auth.uid())
-- But authenticated users don't have SELECT permission on auth.users table
-- Solution: Create SECURITY DEFINER function that runs with elevated privileges

-- Create function to check if current user is anonymous
-- SECURITY DEFINER means it runs with the privileges of the user who created it (postgres)
CREATE OR REPLACE FUNCTION public.is_anonymous_user()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT COALESCE(
    (SELECT is_anonymous FROM auth.users WHERE id = auth.uid()),
    false
  );
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_anonymous_user() TO authenticated;

-- Now update all policies to use this function instead of direct auth.users query

-- 1. Fix spaces INSERT policy
DROP POLICY IF EXISTS "Users can insert own spaces with limits" ON spaces;

CREATE POLICY "Users can insert own spaces with limits"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  -- Must be owner
  user_id = auth.uid()
  AND
  -- If anonymous, enforce 1 space limit
  (
    public.is_anonymous_user() = false
    OR
    (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 1
  )
);

-- 2. Fix notes INSERT policy
DROP POLICY IF EXISTS "Anonymous users limited to 20 notes per space" ON notes;

CREATE POLICY "Anonymous users limited to 20 notes per space"
ON notes FOR INSERT
TO authenticated
WITH CHECK (
  public.is_anonymous_user() = false
  OR
  (SELECT COUNT(*) FROM notes WHERE user_id = auth.uid() AND space_id = notes.space_id) < 20
);

-- 3. Fix todo_lists INSERT policy
DROP POLICY IF EXISTS "Anonymous users limited to 10 todo lists per space" ON todo_lists;

CREATE POLICY "Anonymous users limited to 10 todo lists per space"
ON todo_lists FOR INSERT
TO authenticated
WITH CHECK (
  public.is_anonymous_user() = false
  OR
  (SELECT COUNT(*) FROM todo_lists WHERE user_id = auth.uid() AND space_id = todo_lists.space_id) < 10
);

-- 4. Fix lists INSERT policy
DROP POLICY IF EXISTS "Anonymous users limited to 5 custom lists per space" ON lists;

CREATE POLICY "Anonymous users limited to 5 custom lists per space"
ON lists FOR INSERT
TO authenticated
WITH CHECK (
  public.is_anonymous_user() = false
  OR
  (SELECT COUNT(*) FROM lists WHERE user_id = auth.uid() AND space_id = lists.space_id) < 5
);
