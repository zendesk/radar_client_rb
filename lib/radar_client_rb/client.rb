require_relative './legacy_client.rb'

# Backwards compatibility with 1.0.4
Radar::Client = Radar::LegacyClient
