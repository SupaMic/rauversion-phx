defmodule RauversionWeb.ArticlesLive.ArticlesListComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  # use Phoenix.LiveComponent
  use RauversionWeb, :live_component

  alias Rauversion.{Posts}

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  defp list_posts() do
    Posts.list_posts("published")
    |> Posts.order()
    |> Rauversion.Repo.paginate(page: 1, page_size: 7)
  end

  defp list_latests do
    Posts.list_posts("published")
    |> Posts.order()
    |> Rauversion.Repo.paginate(page: 2, page_size: 7)
  end

  defp list_news() do
    category = Rauversion.Categories.get_category_by_slug!("news")

    Posts.list_posts("published")
    |> Posts.with_category(category)
    |> Posts.order()
    |> Rauversion.Repo.paginate(page: 1, page_size: 7)
  end

  def render(assigns) do
    ~H"""
    <div class="pt-16 pb-20 px-4 sm:px-6 lg:pt-24 lg:pb-28 lg:px-8">
      <div class="relative max-w-lg mx-auto divide-y-2 divide-gray-200 dark:divide-gray-100 lg:max-w-7xl">

        <div>
          <h2 class="text-3xl tracking-tight font-extrabold text-gray-900 dark:text-gray-100 sm:text-4xl">
            <%= gettext("Recent publications") %>
          </h2>

          <p class="mt-3 text-xl text-gray-500 dark:text-gray-300 sm:mt-4">
            <%= gettext "Selected articles & reviews from Rauversion community and editorial" %>
          </p>

        </div>

        <div class="mt-12 grid lg:gap-16 pt-12 lg:grid-cols-6 lg:gap-x-5 lg:gap-y-12">
          <div class="col-span-5 flex lg:flex-row flex-col lg:space-x-4 lg:divide-x-2 lg:divide-y-0 divide-y-2">

            <div class="w-1/4- space-y-4">
              <%= for post <- list_news() do %>
                <.live_component
                  post={post}
                  id={"side-articles-#{post.id}"}
                  module={RauversionWeb.ArticlesLive.ArticleComponent}
                  hide_excerpt={true}
                  truncate_titlesss={true}
                  image_class={nil}
                />
              <% end %>
            </div>

            <div class="lg:px-4 flex-grow space-y-4 pb-4">
              <%= for post <- list_posts() do %>
                <.live_component
                  id={"main-articles-#{post.id}"}
                  post={post}
                  module={RauversionWeb.ArticlesLive.ArticleComponent}
                  image_class={"h-64"}
                />
              <% end %>
            </div>

          </div>

          <div class="col-span-6 lg:col-span-1 space-y-4">
            <h3 class="border-b uppercase">
              <%= gettext("The Latest") %>
            </h3>

            <%= for post <- list_latests() do %>
              <.live_component
                id={"minimal-post-#{post.id}"}
                post={post}
                module={RauversionWeb.Live.ArticlesLive.ArticleSmallComponent}
              />
            <% end %>
          </div>

        </div>


        <.live_component
          id={"sections-reviews"}
          title={"Reviews"}
          category_slug="reviews"
          module={RauversionWeb.ArticlesLive.CategoriesSectionComponent}
        />
      </div>
    </div>
    """
  end
end
