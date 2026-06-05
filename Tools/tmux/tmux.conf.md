
Here is a clean, practical `~/.tmux.conf` as a DevOps/Kubernetes/Linux user.

It gives you:

- Easy prefix: `Ctrl + a`
- Mouse support
- Vim-like pane movement
- Fast pane/window navigation
- Better copy mode
- Clean status bar
- True color support
- Useful reload shortcut
- Bigger scrollback history

Create/edit:

```bash
nano /home/hady/.tmux.conf
```

Paste this:

```tmux
##### ==============================
##### Hady's tmux configuration
##### Path: /home/hady/.tmux.conf
##### ==============================


##### ------------------------------
##### Prefix key
##### ------------------------------

# Use Ctrl+a instead of default Ctrl+b
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix


##### ------------------------------
##### General behavior
##### ------------------------------

# Start window and pane numbering from 1
set -g base-index 1
setw -g pane-base-index 1

# Automatically renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback history
set -g history-limit 50000

# Faster key response
set -s escape-time 10

# Enable mouse support
set -g mouse on

# Use vi-style keys in copy mode
setw -g mode-keys vi

# Enable focus events for better editor behavior
set -g focus-events on

# Set default terminal capabilities
set -g default-terminal "tmux-256color"

# True color support
set -ga terminal-overrides ",xterm-256color:Tc"


##### ------------------------------
##### Reload config
##### ------------------------------

# Reload tmux config with Prefix + r
bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded ✅"


##### ------------------------------
##### Pane splitting
##### ------------------------------

# Split panes using intuitive keys
unbind '"'
unbind %

# Prefix + | = vertical split
bind | split-window -h -c "#{pane_current_path}"

# Prefix + - = horizontal split
bind - split-window -v -c "#{pane_current_path}"

# Keep new windows in the current directory
bind c new-window -c "#{pane_current_path}"


##### ------------------------------
##### Pane navigation
##### ------------------------------

# Vim-style pane movement
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Move between panes without prefix using Alt + arrows
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Resize panes using Prefix + H/J/K/L
bind H resize-pane -L 5
bind J resize-pane -D 5
bind K resize-pane -U 5
bind L resize-pane -R 5


##### ------------------------------
##### Window navigation
##### ------------------------------

# Alt + h/l to move between windows
bind -n M-h previous-window
bind -n M-l next-window

# Prefix + Tab switches to last window
bind Tab last-window


##### ------------------------------
##### Copy mode
##### ------------------------------

# Prefix + [ enters copy mode
bind [ copy-mode

# In copy mode:
# v starts selection
# y copies selection
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

# Copy to system clipboard using xclip if installed
# Install with: sudo apt install xclip
bind-key -T copy-mode-vi Y send -X copy-pipe-and-cancel "xclip -selection clipboard"


##### ------------------------------
##### Pane / window helpers
##### ------------------------------

# Prefix + x kills pane with confirmation
bind x kill-pane

# Prefix + X kills window with confirmation
bind X kill-window

# Prefix + q shows pane numbers
bind q display-panes

# Prefix + m toggles pane zoom
bind m resize-pane -Z


##### ------------------------------
##### Status bar
##### ------------------------------

# Status bar position
set -g status-position bottom
set -g status-interval 5

# Status colors
set -g status-style bg=colour235,fg=colour250

# Left side: session name
set -g status-left-length 40
set -g status-left "#[fg=colour46,bold] #S #[fg=colour240]| "

# Right side: date/time and host
set -g status-right-length 100
set -g status-right "#[fg=colour240]| #[fg=colour39]%Y-%m-%d #[fg=colour46]%H:%M #[fg=colour240]| #[fg=colour214]#H "

# Window style
setw -g window-status-format " #[fg=colour244]#I:#W "
setw -g window-status-current-format " #[fg=colour16,bg=colour46,bold]#I:#W "

# Pane border colors
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=colour46


##### ------------------------------
##### Messages
##### ------------------------------

set -g message-style bg=colour236,fg=colour46,bold
set -g display-time 2000


##### ------------------------------
##### Quality of life
##### ------------------------------

# Allow terminal titles
set -g set-titles on
set -g set-titles-string "#S:#W"

# Do not rename windows automatically too aggressively
setw -g automatic-rename on
set -g allow-rename off
```

Then reload it:

```bash
tmux source-file /home/hady/.tmux.conf
```

Or inside tmux:

```bash
Ctrl + a
r
```

Important shortcuts:

```text
Ctrl + a then |      split vertical
Ctrl + a then -      split horizontal
Ctrl + a then h/j/k/l move between panes
Alt + arrows         move between panes directly
Ctrl + a then c      new window
Alt + h / Alt + l    previous / next window
Ctrl + a then m      zoom pane
Ctrl + a then [      copy mode
v                    start selection in copy mode
y                    copy selection inside tmux
Y                    copy selection to system clipboard if xclip installed
Ctrl + a then r      reload config
```

