# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :habit,
  ecto_repos: [Habit.Repo]

# Configures the endpoint
config :habit, HabitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LO7xqoGLEfUulSd5ZCoEh+HiqoI8OqysIa0ozW84YRS6PFhbN+Dba69o1wJeopGL",
  render_errors: [view: HabitWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Habit.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
