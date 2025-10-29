# Gemini Guidelines

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

---

## :rocket: TL;DR

```shell
task install
```

---

## :bulb: Inspiration

Inspiration for this repository has been taken from [jessfraz/dotfiles][2].

---

## :balance_scale: License

​[Apache License 2.0](./LICENSE)

---

## :pencil: Author

​This project was started in 2025 by [Nicholas Wilde][1].

[1]: https://github.com/nicholaswilde/
[2]: https://github.com/jessfraz/dotfiles
[3]: http://nicholaswilde.io/dotfiles2
