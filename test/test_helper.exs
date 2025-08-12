ExUnit.start()

# Configure Phoenix for testing
Application.put_env(:phoenix, :json_library, Jason)

# Import test helpers
Code.require_file("support/chart_test_helpers.ex", __DIR__)
