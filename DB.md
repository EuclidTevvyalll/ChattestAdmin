# ForgeLink Database Schema (Admin Reference)

This document describes the database tables used by the ForgeLink Admin Dashboard.

## Table `profiles`
Stores user profile information.

| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| `id` | `uuid` | Primary Key | Linked to Auth ID |
| `username` | `text` | Unique, Not Null | System username |
| `nickname` | `text` | Nullable | Display name |
| `avatar_url` | `text` | Nullable | Profile picture URL |
| `is_online` | `boolean` | Default: `false` | Presence status |
| `updated_at` | `timestamptz` | Default: `now()` | Last update timestamp |
| `is_admin` | `boolean` | Default: `false` | Admin permission flag |
| `is_banned` | `boolean` | Default: `false` | User ban status |

---

## Table `reports`
Stores content and user reports for moderation.

| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| `id` | `uuid` | Primary Key | Unique report ID |
| `reporter_id` | `uuid` | FK (profiles) | User who reported |
| `target_id` | `uuid` | Not Null | ID of reported user/message |
| `target_type` | `text` | Not Null | `user` or `message` |
| `reason` | `text` | Not Null | Category of violation |
| `details` | `text` | Nullable | Additional context |
| `status` | `text` | Default: `'pending'` | `pending`, `resolved`, `dismissed` |
| `created_at` | `timestamptz` | Default: `now()` | When the report was filed |

---

## Table `rooms`
Conversations (Direct, Groups, Channels).

| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| `id` | `uuid` | Primary Key | Room ID |
| `type` | `text` | Not Null | `direct`, `group`, `channel` |
| `name` | `text` | Nullable | Group/Channel name |
| `avatar_url` | `text` | Nullable | Room icon |
| `created_by` | `uuid` | FK (profiles) | Creator/Owner |
| `created_at` | `timestamptz` | Default: `now()` | Creation time |

---

## Table `messages`
All chat messages.

| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| `id` | `uuid` | Primary Key | Message ID |
| `room_id` | `uuid` | FK (rooms) | Parent room |
| `profile_id` | `uuid` | FK (profiles) | Sender ID |
| `content` | `text` | Not Null | Message body |
| `created_at` | `timestamptz` | Default: `now()` | Sending time |
| `is_edited` | `boolean` | Default: `false` | Edit status |
