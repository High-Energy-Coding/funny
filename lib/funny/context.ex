defmodule Funny.Context do
  @moduledoc """
  The current authentication context.

  All service context functions are invoked in the context of some actor.
  This could be a user executing anonymously, a user after login, or an
  automated data feed authenticating with an API key.

  Scopes define functional permissions in alignment with
  [OAuth 2.0 Scopes](https://oauth.net/2/scope/).

  > Note: The current implementation defines no scopes, and is permissive
  across all functionality.
  """

  alias Funny.Catalog.Person

  defstruct actor: nil, scopes: []

  # This will eventually be a schema like User.t() or Vendor.t()
  @type actor :: nil | Person.t()

  @type t :: %__MODULE__{actor: actor, scopes: list(String.t())}
end
