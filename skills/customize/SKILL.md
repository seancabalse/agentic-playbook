---
name: customize
description: "Change a playbook default for this project only, with a copy in .playbook/local/. Run only when the user asks."
argument-hint: "[playbook file or topic, e.g. templates/adr.md, the PR template, the react-web stack rules] [the change]"
disable-model-invocation: true
---

# Customise the playbook for this project

Request: $ARGUMENTS

The playbook's files stay general. A project changes one by keeping its own copy at the same path under `.playbook/local/`, which wins over the default everywhere. The session-start hook lists the overrides for plugin users, and the core rules in `AGENTS.md` say to check there first.

1. **Find the file.** Match the request to a path under `${CLAUDE_PLUGIN_ROOT}/` (`principles/`, `templates/`, `stacks/`, `trackers/`). If several fit, list them and ask. Rules that only apply here, and need no playbook file, belong in `AGENTS.md` → "This project" instead: say so, and stop.
2. **Copy it**, unless the project already overrides it: from `${CLAUDE_PLUGIN_ROOT}/<path>` to `.playbook/local/<path>`, creating folders as needed. Where the copy names other playbook files by a full path, write them as playbook-relative paths instead ("the playbook's `templates/adr.md`"): the copy is shared, and the playbook's location differs per person and per install.
3. **Make the change** the user asked for, and only that, keeping the file's structure so the skills that read it still find their sections. Add a one-line HTML comment at the top: what was changed, why, and the date.
4. **Check the readers.** Search the skills and agents for the path, and confirm that each still makes sense with the change: a renamed section, or a removed step a skill relies on, needs the skill's input adjusted. Tell the user about anything that conflicts.
5. **Record it.** Log the decision with `log-decision` ("Project override of <path>: <why>"). Remind the user to commit `.playbook/local/`; it's shared with everyone on the project.

To drop an override, delete the file from `.playbook/local/`; the default applies again at the next session.
