/* Prism grammar for LFE (Lisp Flavoured Erlang) — hand-written, standalone
 * (depends only on Prism core). Prism ships no LFE grammar, and its `lisp`
 * fallback only catches `defun`/`let` on real LFE, so this blog (LFE-first)
 * carries its own. Appended into assets/js/prism.js by scripts/fetch-prism.sh.
 *
 * `lykn` (a Lisp born from LFE) is aliased to this grammar.
 */
(function (Prism) {
  var lfe = {
    comment: { pattern: /;.*/, greedy: true },
    string: { pattern: /"(?:\\.|[^"\\])*"/, greedy: true },
    // LFE special forms, matched only in call-head position (right after `(`).
    keyword: {
      pattern: /(\()(?:defmodule|defun|defmacro|defrecord|defsyntax|deftype|defstruct|deftest|behaviou?r|module|export|export-macro|import|include-lib|include-file|match-lambda|lambda|let\*?|letrec\*?|flet|fletrec|case|cond|if|when|unless|receive|after|try|catch|throw|begin|progn|do|andalso|orelse|fun|quote|quasiquote|backquote|unquote|unquote-splicing|eval-when-compile|maybe|set)(?=[\s()])/,
      lookbehind: true
    },
    boolean: /\b(?:true|false|undefined)\b/,
    number: {
      pattern: /(^|[\s()'`,#])[+-]?(?:\d+#[0-9a-zA-Z]+|\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)(?=[\s()]|$)/,
      lookbehind: true
    },
    // Capitalised or _-led symbols are variables (Erlang/LFE convention).
    variable: {
      pattern: /(^|[\s()'`,])[A-Z_][\w-]*(?=[\s()]|$)/,
      lookbehind: true
    },
    // Call head right after `(` — allows `mod:fun` and lisp-y symbol names.
    function: {
      pattern: /(\()[a-z][\w-]*(?::[a-z][\w-]*)?[!?*+<>=/']*(?=[\s()])/,
      lookbehind: true
    },
    // 'atom and bare lowercase atoms used as data.
    atom: {
      pattern: /'[a-zA-Z_][\w-]*[!?*+<>=/]?|(^|[\s()])[a-z][\w-]*[!?*+<>=/]?(?=[\s()]|$)/,
      lookbehind: true,
      alias: 'symbol'
    },
    punctuation: /[()[\]{}#'`,]/
  };
  Prism.languages.lfe = lfe;
  Prism.languages.lykn = lfe;
}(Prism));
