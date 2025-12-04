import Config

config :explore, ExploreWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_tower_defense_game_development_only_12345678901234567890",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:explore, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:explore, ~w(--watch)]}
  ]

config :explore, ExploreWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/explore_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :explore, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
