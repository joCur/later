-- Row-Level Security (RLS) Policies Migration
-- Enables RLS and creates policies for multi-tenant data isolation

-- Enable RLS on all tables
ALTER TABLE spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE todo_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE todo_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE list_items ENABLE ROW LEVEL SECURITY;

-- Spaces policies: Users can only access their own spaces
CREATE POLICY "Users can access own spaces"
ON spaces FOR ALL
USING (user_id = auth.uid());

-- Notes policies: Users can only access their own notes
CREATE POLICY "Users can access own notes"
ON notes FOR ALL
USING (user_id = auth.uid());

-- Todo lists policies: Users can only access their own todo lists
CREATE POLICY "Users can access own todo_lists"
ON todo_lists FOR ALL
USING (user_id = auth.uid());

-- Todo items policies: Users can access todo items in their own todo lists
CREATE POLICY "Users can access own todo_items"
ON todo_items FOR ALL
USING (
  todo_list_id IN (
    SELECT id FROM todo_lists WHERE user_id = auth.uid()
  )
);

-- Lists policies: Users can only access their own lists
CREATE POLICY "Users can access own lists"
ON lists FOR ALL
USING (user_id = auth.uid());

-- List items policies: Users can access list items in their own lists
CREATE POLICY "Users can access own list_items"
ON list_items FOR ALL
USING (
  list_id IN (
    SELECT id FROM lists WHERE user_id = auth.uid()
  )
);
