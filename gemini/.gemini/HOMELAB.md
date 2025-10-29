# Project: My MkDocs-Material Documentation

## General Instructions:

- All documentation is written in Markdown and generated using the MkDocs with the Material theme.
- Adhere strictly to the MkDocs-Material syntax extensions for features like admonitions, content tabs, and icons.
- Ensure all new pages are added to the `nav` section of the `mkdocs.yml` file to appear in the site navigation.
- All internal links must be relative and point to other `.md` files within the `docs/` directory.

## Markdown Style Guide:

- **Headings:** Use ATX-style headings (`#`, `##`, `###`, etc.). The main page title is always H1 (`#`). Headings should start with emoji.
- **Admonitions:** Use admonitions to highlight important information.
- `!!! note` for general information.
- `!!! code` for computer code and commands.
- `!!! abstract` for referencing files.
- `??? abstract` for long files that need to be collapsed.
- `!!! tip` for helpful advice.
- `!!! warning` for critical warnings or potential issues.
- `!!! danger` for severe risks.
- **Code Blocks:** Always specify the language for syntax highlighting (e.g., ` ```python`). For shell commands, use `shell` or `bash`. Use `ini` for `.env` files.
- **Lists:** Use hyphens (`-`) for unordered lists and numbers (`1.`) for ordered lists.
- **Icons & Emojis:** Use Material Design icons and emojis where appropriate to improve visual communication, e.g., `:material-check-circle:` for success.
- **Icons & Emojis:** Use the short codes for emoji instead of the emoji itself.
- Use 2 spaces for indentation.
- List items that are links should be inclosed with < and >.
- Formatting shall be compatible with markdownlint.

## Sections:

- **References:** Always end a page with a References section.
- References section starts with the :link: emoji.
- References section has a list of relevant links.
- **Config:** Create a config section
- **Installation:** Create an installation section
- **Usage:** Create a usage section

## docs/apps/

- This section contains apps that are installed in my homelab.
- Instructions should be given for installing the app.
- Config

## docs/tools/

- This section contains tools that are used in my homelab.

## Regarding Dependencies:

- The primary dependency is mkdocs-material.
- The project also uses the pymdown-extensions for advanced formatting.
- Mermaid is an acceptable plugin.
- Do not introduce new MkDocs plugins without prior discussion and approval.
