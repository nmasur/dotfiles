inputs: _final: prev: {
  tree-sitter-grammars = prev.tree-sitter-grammars // {

    # Fix: bash highlighting doesn't work as of this commit:
    # https://github.com/NixOS/nixpkgs/commit/49cce41b7c5f6b88570a482355d9655ca19c1029
    tree-sitter-bash = prev.tree-sitter-grammars.tree-sitter-bash.overrideAttrs (old: {
      src = inputs.tree-sitter-bash;
    });

    # Fix: invalid node in position. Broken as of this commit (replaced with newer):
    # https://github.com/NixOS/nixpkgs/commit/8ec3627796ecc899e6f47f5bf3c3220856ead9c5
    tree-sitter-python = prev.tree-sitter-grammars.tree-sitter-python.overrideAttrs (old: {
      src = inputs.tree-sitter-python;
    });

    # Fix: invalid structure in position.
    tree-sitter-lua = prev.tree-sitter-grammars.tree-sitter-lua.overrideAttrs (old: {
      src = inputs.tree-sitter-lua;
    });

    # Add grammars not in nixpks
    tree-sitter-ini = prev.tree-sitter.buildGrammar {
      language = "ini";
      version = "1.0.0";
      src = inputs.tree-sitter-ini;
    };
    tree-sitter-puppet = prev.tree-sitter.buildGrammar {
      language = "puppet";
      version = "1.0.0";
      src = inputs.tree-sitter-puppet;
    };
    tree-sitter-rasi = prev.tree-sitter.buildGrammar {
      language = "rasi";
      version = "0.1.1";
      src = inputs.tree-sitter-rasi;
    };
    tree-sitter-vimdoc = prev.tree-sitter.buildGrammar {
      language = "vimdoc";
      version = "2.1.0";
      src = inputs.tree-sitter-vimdoc;
    };
  };
}
