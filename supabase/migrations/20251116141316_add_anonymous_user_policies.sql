-- Anonymous User RLS Policies Migration
-- Adds policies to limit anonymous users' resource creation

-- Policy: Limit anonymous users to 1 space
CREATE POLICY "Anonymous users limited to 1 space"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 1
    ELSE true
  END
);

-- Policy: Limit anonymous users to 20 notes per space
CREATE POLICY "Anonymous users limited to 20 notes per space"
ON notes FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (
      SELECT COUNT(*)
      FROM notes n
      WHERE n.user_id = auth.uid() AND n.space_id = notes.space_id
    ) < 20
    ELSE true
  END
);

-- Policy: Limit anonymous users to 10 todo lists per space
CREATE POLICY "Anonymous users limited to 10 todo lists per space"
ON todo_lists FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (
      SELECT COUNT(*)
      FROM todo_lists tl
      WHERE tl.user_id = auth.uid() AND tl.space_id = todo_lists.space_id
    ) < 10
    ELSE true
  END
);

-- Policy: Limit anonymous users to 5 custom lists per space
CREATE POLICY "Anonymous users limited to 5 custom lists per space"
ON lists FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (
      SELECT COUNT(*)
      FROM lists l
      WHERE l.user_id = auth.uid() AND l.space_id = lists.space_id
    ) < 5
    ELSE true
  END
);
