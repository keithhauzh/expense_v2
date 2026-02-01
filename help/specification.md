# Expense V2 Project Specification & Documentation

> **Description:**  
> This is a set of requirements and implementation notes for my personal project.  
> **Note to self:** Implement requirements in order.

# TODOS:
TODO: check if going back in navigation allows not signed in user to write stuff anyway. []
TODO: in the pie chart, for uncategorized expenses, show a section for them. []
TODO: make sure navigator pop doesn't crash the app, check for !mounted on everything. []
TODO: rework group view ui. []
TODO: denormalization applied. []
TODO: test if login fields function properly (normalized/trimmed usernames and emails, invalid emails). []
TODO: check if all backend apis have auth verification handling. []
TODO: show percentage of expenses according to total expense in group per group. []
TODO: dialog for confirmation on sign out. []
TODO: delete unused pages. []
TODO: check all apis for duplicate groups and categories when creating (prevent duplicates). []

## Important Concepts to Remember for This Project

### Denormalization
- Delegate calculations or accumulations to write events.
- Example: `totalExpenses` should be a field in a group so that we don’t need to sum each expense per account every time we read a group’s expenses.
- **Edit:** Due to the data structure of the project, I decided to use a normalized data structure.
  - Reading expenses per group is still performant since expenses have a `groupId` field.
  - After MVP, additional metadata may be denormalized if it is easy to maintain.

---

## Reminders
- Error handling should be the first priority; ensure the app is stable against exceptions.
- Validation for every field.
  - Each page should have validation regardless of whether it is a complete form.
  - Any switch between pages should first validate respective fields to improve UX and ensure completeness.
- The nature of this project prevents duplicates of:
  - usernames
  - group names
  - category names  
  Ensure validation prevents duplicates.

---

## Current Implementation Practices

### Dialogs
- Use `SingleChildScrollView` with a nested `Column`.
  - If content does not fit on screen, it becomes scrollable.
  - Prevents overlapping elements.
  - ScrollView shrinks to content size (fixed size).
  - Spacing issues can be solved with `SizedBox(height: ...)`.
- Without a `ScrollView`:
  - Spacing depends on window size.
  - Large windows cause strange scaling since dialogs scale with the window.

---

## Data Structure (in Dartlang and Flutter)

### Accounts
**MVP**
- `docId`
- `username`

**Additional Features**
- `dateCreated`

---

### Expenses
**MVP**
- `docId`
- `name`
- `amount`
- `description`
- `whoPaid`
- `group` 
- `category`

**Additional Features**
- `dateCreated`

---

### Groups
**MVP**
- `docId`
- `name`
- `description`

**Additional Features**
- `dateCreated`
- `ownerId`
- `memberCount` (denormalized)

---

### Categories
**MVP**
- `docId`
- `name`

---

## MVP

### Basic CRUD Functionality
- View expenses
- Add expenses
- Delete expenses

**Expense Class Model**
- `id`
- `name`
- `description` (optional)
- `amount`

---

### Account Creation
- Make account
- Login, logout, sign in
- Terminate account (deletes all expenses attached to that account)
**Account Class Model**
- `id`
- `username`
- Attach expenses to account so all expenses have a username.
**Updated Expense Class Model**
- `id`
- `name`
- `description` (optional)
- `amount`
- `username`

---

### Groups (MVP)
- Create groups
- Edit group name
- Add accounts to group
- Accounts can join group
- View total expenses in group (by all members)
- Delete groups (deletes all expenses attached to group)
**Group Class Model**
- `id`
- `name`
- `description`

---

### Sorting
- Sort by dynamic category.
- Add category during expense creation.
  - Adds a new field to expense model: `expenseCategory`.

**Updated Expense Class Model**
- `id`
- `name`
- `description` (optional)
- `amount`
- `username`
- `group` 
- `category`

- Existing categories should appear during expense creation.
- Prevent duplicate category creation.
  - Validation should be **case-insensitive**.
- Sorting in group view should behave the same way.
- Using group (group's name) to find the appropriate expenses, 
also because it makes it faster to read from expenses, you are able to see the 
group's names on the expenses 

---

### Percentage of Expenses in Group
- View percentage of money spent by each account in a group.

---

## Additional Features

### Log deletions
- Because of the nature of the project, it might be a good idea to track logs, so that families who create groups in order to track expenses might want to know if someone has deleted an expense from the group that they previously had registered

### Additional Metadata
- View creation date and time of expense.
- View creation date and time of group.
- View how many groups are attached to a category.
- View number of members in a group.
  - Add `memberNumber` field to group.
  - Update immediately on member changes.

---

### Summary Views
- Dashboard/summary page:
  - View personal expenses.
  - View group expenses.
- Possible chart:
  - Shows which group you spent the most in.
  - Sorted ascending or descending.
- Possible extension:
  - Monthly summary of expenses.
  - Low priority (complex).

---

### Graphical Improvements
- Use pie charts for percentages.
- Summary views:
  - Accounts/categories annotated by percentage.
  - Color-coded:
    - Highest spender: red
    - Second: yellow
    - Third: green
    - etc.

---

### Budgets
- Add budgets:
  - Per group
  - Personal
- Visual indication when budget is exceeded.

---

### Permissions and Authorization
- Group creator (owner) has special permissions:
  - Can freely remove accounts from group.

---

### Customization
- Themes.

---

### Advanced Deletion
- Delete all expenses in a group.
- Leave or remove yourself from a group.
- Expenses should not be orphaned:
  - Leaving a group deletes your expenses from that group.
- Possible extension:
  - Dialog to choose:
    - Delete expenses
    - Retain expenses as groupless.

---

### Group Invitations
- Change joining flow:
  - Owner sends invitation.
  - Account can accept or decline.

---

### Bills
- Bills are mini-groups.
- Can belong to a group or be standalone.
- Belong to multiple accounts.
- Used for atomic payments where it’s clear who paid what.

---

## Extras

### Probable Marks Distribution
1. Functionality according to proposal — **50%**
2. Code quality, documentation for complex logic, error feedback — **10%**
3. UI (responsive, user-friendly, launcher icon) — **15%**
4. Consistent GitHub commits & repository structure — **10%**
5. Presentation — **10%**
6. On-time submission, constraints (e.g. file size) — **5%**

