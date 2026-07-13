defmodule Plausible.Cldr do
  @moduledoc false

  use Cldr, locales: ["fi", "en"], providers: [Cldr.Number, Money]
end
