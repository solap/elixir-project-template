[
  import_deps: [:phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,lib_internal,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs"
  ]
]
