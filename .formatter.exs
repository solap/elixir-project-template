[
  import_deps: [:ecto, :ecto_sql, :phoenix, :absinthe],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,lib_internal,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs"
  ]
]
