# 🔍 qfsearch.nvim

A lightweight Neovim plugin that filters your Quickfix list by searching the **entire contents** of the files, rather than just the Quickfix preview snippet.

## ✨ The Problem It Solves
Standard Quickfix filtering (like `cfilter` or `getqflist()`) only searches the small text preview loaded in the Quickfix window. 

If you are working with virtual files—like Java classes decompiled by JDTLS (`jdt://...`)—standard tools like `grep` or `rg` cannot search them. **qfsearch.nvim** forces Neovim to load the buffers into memory, scans every line for your keyword, and rebuilds the Quickfix list with only the matching files.

## 📦 Installation

Install with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "CodesWithRobi/qfsearch.nvim",
  opts = {
    auto_open = true, -- Automatically open the quickfix window if matches are found
  },
  keys = {
    -- Optional: Create a keymap to quickly bring up the command prompt
    { "<leader>qs", ":QfSearch ", desc = "Quickfix Deep Search" },
  },
}

```

## 🚀 Usage

Populate your Quickfix list (e.g., finding all implementations or references), then run:

```vim
:QfSearch <your_keyword>

```

**Example:**

```vim
:QfSearch getLocalizedMessage

```

The plugin will scan all files currently in the Quickfix list, keep only the files that actually contain `getLocalizedMessage` anywhere in their source code, and update the list.

## ⚙️ Configuration

The plugin comes with the following default configuration:

```lua
require("qfsearch").setup({
  auto_open = true, -- Set to false if you don't want the Quickfix window to open automatically
})

```
