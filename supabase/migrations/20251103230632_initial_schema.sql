-- Initial Schema Migration for Later App
-- Creates tables for spaces, notes, todo_lists, todo_items, lists, and list_items

-- Create spaces table
CREATE TABLE spaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    icon TEXT,
    color TEXT,
    is_archived BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create notes table
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    space_id UUID REFERENCES spaces(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    tags TEXT[],
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create todo_lists table
CREATE TABLE todo_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    space_id UUID REFERENCES spaces(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create todo_items table
CREATE TABLE todo_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    todo_list_id UUID REFERENCES todo_lists(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT false NOT NULL,
    due_date TIMESTAMPTZ,
    priority TEXT,
    tags TEXT[],
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create lists table
CREATE TABLE lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    space_id UUID REFERENCES spaces(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    icon TEXT,
    style TEXT DEFAULT 'bullets' NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create list_items table
CREATE TABLE list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID REFERENCES lists(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    is_checked BOOLEAN DEFAULT false NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create indexes for performance
CREATE INDEX idx_spaces_user_id ON spaces(user_id);
CREATE INDEX idx_notes_user_space_sort ON notes(user_id, space_id, sort_order);
CREATE INDEX idx_todo_lists_user_space ON todo_lists(user_id, space_id);
CREATE INDEX idx_todo_items_list_sort ON todo_items(todo_list_id, sort_order);
CREATE INDEX idx_lists_user_space ON lists(user_id, space_id);
CREATE INDEX idx_list_items_list_sort ON list_items(list_id, sort_order);
