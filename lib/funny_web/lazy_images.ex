defmodule FunnyWeb.LazyImages do
  use Phoenix.HTML

  def lazy_img(source, attrs \\ []) do
    image_attrs =
      attrs
      |> Keyword.update(
        :class,
        "js-lazy-load styles-lazy-load",
        fn current_class ->
          current_class <> " js-lazy-load styles-lazy-load"
        end
      )
      |> Keyword.put(:data_src, source)

    ~E"""
    <%= img_tag( nil, image_attrs) %>
    """
  end
end
