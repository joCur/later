-- Fix Anonymous User RLS Policies
-- Replace JWT claim check with direct database lookup

-- Drop old policies
DROP POLICY IF EXISTS "Anonymous users limited to 1 space" ON spaces;
DROP POLICY IF EXISTS "Anonymous users limited to 5 space" ON spaces;
DROP POLICY IF EXISTS "Anonymous users limited to 20 notes per space" ON notes;
DROP POLICY IF EXISTS "Anonymous users limited to 10 todo lists per space" ON todo_lists;
DROP POLICY IF EXISTS "Anonymous users limited to 5 custom lists per space" ON lists;

-- Policy: Limit anonymous users to 1 space (FIXED)
CREATE POLICY "Anonymous users limited to 1 space"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    -- Check is_anonymous directly from auth.users table
    WHEN (SELECT is_anonymous FROM auth.users WHERE id = auth.uid()) = true
    THEN (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 1
    ELSE true
  END
);

-- Policy: Limit anonymous users to 20 notes per space (FIXED)
CREATE POLICY "Anonymous users limited to 20 notes per space"
ON notes FOR INSERT
TO authenticated
WITH CHECK (
  -- Allow if not anonymous, OR if anonymous and under limit
  (SELECT is_anonymous FROM auth.users WHERE id = auth.uid()) = false
  OR
  (
    SELECT COUNT(*)
    FROM notes
    WHERE user_id = auth.uid() AND space_id = notes.space_id
  ) < 20
);

-- Policy: Limit anonymous users to 10 todo lists per space (FIXED)
CREATE POLICY "Anonymous users limited to 10 todo lists per space"
ON todo_lists FOR INSERT
TO authenticated
WITH CHECK (
  -- Allow if not anonymous, OR if anonymous and under limit
  (SELECT is_anonymous FROM auth.users WHERE id = auth.uid()) = false
  OR
  (
    SELECT COUNT(*)
    FROM todo_lists
    WHERE user_id = auth.uid() AND space_id = todo_lists.space_id
  ) < 10
);

-- Policy: Limit anonymous users to 5 custom lists per space (FIXED)
CREATE POLICY "Anonymous users limited to 5 custom lists per space"
ON lists FOR INSERT
TO authenticated
WITH CHECK (
  -- Allow if not anonymous, OR if anonymous and under limit
  (SELECT is_anonymous FROM auth.users WHERE id = auth.uid()) = false
  OR
  (
    SELECT COUNT(*)
    FROM lists
    WHERE user_id = auth.uid() AND space_id = lists.space_id
  ) < 5
);
