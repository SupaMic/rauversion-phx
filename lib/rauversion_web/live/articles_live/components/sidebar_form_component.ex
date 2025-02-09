defmodule RauversionWeb.ArticlesLive.SidebarFormComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  # use Phoenix.LiveComponent
  use RauversionWeb, :live_component

  alias Rauversion.{Posts}

  @impl true
  def update(%{post: post} = assigns, socket) do
    post = Posts.get_post!(post.id)
    changeset = Posts.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Posts.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    post_params =
      post_params
      |> Map.put("cover", List.first(files_for(socket, :cover)))

    IO.inspect(post_params)

    case Posts.update_post_attributes(socket.assigns.post, post_params) do
      {:ok, _post} ->
        # IO.inspect(post)

        {
          :noreply,
          socket
          |> put_flash(:info, "post updated successfully")
          # |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="z-[500]-- pointer-events-none fixed-- inset-y-0 right-0 flex max-w-full pl-10 w-1/4">
      <!--
        Slide-over panel, show/hide based on slide-over state.

        Entering: "transform transition ease-in-out duration-500 sm:duration-700"
          From: "translate-x-full"
          To: "translate-x-0"
        Leaving: "transform transition ease-in-out duration-500 sm:duration-700"
          From: "translate-x-0"
          To: "translate-x-full"
      -->
      <div class="z-[500] dark:border-l-2 dark:border-white pointer-events-auto w-screen max-w-md h-screen fixed inset-y-0 right-0">

        <.form
          let={f}
          for={@changeset}
          id="post-form-2"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          multipart={true}
          class="flex h-full flex-col divide-y divide-gray-200 dark:divide-gray-800 dark:bg-black bg-white shadow-xl"
        >
          <div class="h-0 flex-1 overflow-y-auto">
            <div class="bg-brand-700 py-6 px-4 sm:px-6">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-medium text-white" id="slide-over-title"> <%= gettext "New article" %> </h2>
                <div class="ml-3 flex h-7 items-center">
                  <button phx-click="toggle-panel" type="button" class="rounded-md bg-brand-700 text-brand-200 hover:text-white focus:outline-none focus:ring-2 focus:ring-white" @click="open = false">
                    <span class="sr-only"><%= gettext "Close panel" %></span>
                    <svg class="h-6 w-6" x-description="Heroicon name: outline/x" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                  </button>
                </div>
              </div>
              <div class="mt-1">
                <p class="text-sm text-brand-300">
                <%= gettext "Get started by filling in the information below to create your new article." %>
                </p>
              </div>
            </div>
            <div class="flex flex-1 flex-col justify-between dark:bg-black dark:text-white">
              <div class="divide-y divide-gray-200 dark:divide-gray-800 px-4 sm:px-6">

                <div class="sm:grid sm:grid-cols-1 sm:gap-4 sm:items-start sm:border-gray-200 sm:pt-5">
                  <label for="cover-photo" class="block text-sm font-medium text-gray-700 dark:text-gray-300 sm:mt-px sm:pt-2">

                    <%= gettext "Cover photo" %>

                  </label>

                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 dark:border-gray-700 border-dashed rounded-md"
                      phx-drop-target={@uploads.cover.ref}>
                      <div class="space-y-1 text-center">


                        <%= if Rauversion.Posts.blob_for(@post, "cover") == nil do %>

                          <svg class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-100" stroke="currentColor" fill="none" viewBox="0 0 48 48" aria-hidden="true">
                            <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
                          </svg>

                        <% else %>
                          <%= img_tag(Rauversion.Posts.proxy_cover_representation_url(@post, %{resize_to_limit: "300x70"}), class: "object-center object-cover group-hover:opacity-75") %>
                        <% end %>

                        <div class="flex text-sm text-gray-600 dark:text-gray-400 py-3">
                          <label class="relative cursor-pointer rounded-md font-medium text-brand-600 hover:text-brand-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-brand-500">
                            <span>
                              <%= gettext "Upload a track Cover" %>
                            </span>
                            <.live_file_input upload={@uploads.cover} class="hidden" />
                            <% #= live_file_input @uploads.cover, class: "hidden" %>
                          </label>
                          <p class="pl-1">
                            <%= gettext "or drag and drop" %>
                          </p>
                        </div>

                        <div>
                          <%= for entry <- @uploads.cover.entries do %>
                            <div class="flex items-center space-x-2">
                              <.live_img_preview entry={entry} width={300} />
                              <div class="text-xl font-bold">
                                <%= entry.progress %>%
                              </div>
                            </div>
                          <% end  %>

                          <%= for {_ref, msg, } <- @uploads.cover.errors do %>
                            <%= Phoenix.Naming.humanize(msg) %>
                          <% end %>
                        </div>

                        <p class="text-xs text-gray-500">
                          <%= gettext "PNG, JPG, GIF up to 10MB" %>
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="space-y-6 pt-6 pb-5">
                  <div>
                    <%= label f, :title, class: "block text-sm font-medium text-gray-900 dark:text-gray-100" %>
                    <div class="mt-1">
                      <%= text_input f, :title, class: "block w-full rounded-md border-gray-300 shadow-sm focus:border-brand-500 focus:ring-brand-500 sm:text-sm dark:bg-gray-900 dark:text-gray-100" %>
                      <%= error_tag f, :title %>
                    </div>
                  </div>
                  <div>
                    <%= label f, :excerpt, class: "block text-sm font-medium text-gray-900 dark:text-gray-100" %>
                    <div class="mt-1">
                      <%= textarea f, :excerpt, class: "block w-full rounded-md border-gray-300 shadow-sm focus:border-brand-500 focus:ring-brand-500 sm:text-sm dark:bg-gray-900 dark:text-gray-100" %>
                      <%= error_tag f, :excerpt %>
                    </div>
                  </div>

                  <fieldset>
                    <legend class="text-sm font-medium text-gray-900 dark:text-gray-100">Privacy</legend>
                    <div class="mt-2 space-y-5">
                      <div class="relative flex items-start">
                        <div class="absolute flex h-5 items-center">
                          <%= radio_button(f, :private, false, class: "h-4 w-4 border-gray-300 text-brand-600 focus:ring-brand-500") %>
                        </div>
                        <div class="pl-7 text-sm">
                          <label for="privacy-public" class="font-medium text-gray-900 dark:text-gray-100">
                          <%= gettext "Public access" %>
                          </label>
                          <p id="privacy-public-description" class="text-gray-500">
                          <%= gettext "Everyone with the link will see this article." %>
                          </p>
                        </div>
                      </div>
                      <div>
                        <div class="relative flex items-start">
                          <div class="absolute flex h-5 items-center">
                            <%= radio_button(f, :private, true, class: "h-4 w-4 border-gray-300 text-brand-600 focus:ring-brand-500") %>
                          </div>
                          <div class="pl-7 text-sm">
                            <label for="privacy-private-to-article" class="font-medium text-gray-900 dark:text-gray-100">
                            <%= gettext "Private to article members " %>
                            </label>
                            <p id="privacy-private-to-article-description" class="text-gray-500">
                            <%= gettext "Only members of this article would be able to access." %>
                            </p>
                          </div>
                        </div>
                      </div>

                      <% # IO.inspect(f) %>
                      <% #= f.data.state %>
                      <% #= f.data.private %>

                      <div>
                        <div class="relative flex items-start">
                          <div class="absolute flex h-5 items-center">
                            <%= checkbox(f, :state, checked_value: "published", unchecked_value: "draft", class: "h-4 w-4 border-gray-300 text-brand-600 focus:ring-brand-500") %>
                          </div>
                          <div class="pl-7 text-sm">
                            <label for="privacy-published-to-article" class="font-medium text-gray-900 dark:text-gray-100">
                              <%= gettext "Published on platform" %>
                            </label>
                            <p id="privacy-published-to-article-description" class="text-gray-500">
                              <%= gettext "Article will be plublished on blog listing." %>
                            </p>
                          </div>
                        </div>
                      </div>

                    </div>
                  </fieldset>
                </div>

                <%= form_input_renderer(f, %{
                  name: :category_id,
                  type: :select,
                  options: Rauversion.Categories.list_categories |> Enum.map(fn x -> {x.name, x.id} end),
                  wrapper_class: ""
                }) %>

                <div class="pt-4 pb-6">
                  <div class="flex text-sm">
                    <a href="#" class="group inline-flex items-center font-medium text-brand-600 hover:text-brand-900">
                      <svg class="h-5 w-5 text-brand-500 group-hover:text-brand-900" x-description="Heroicon name: solid/link" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                        <path fill-rule="evenodd" d="M12.586 4.586a2 2 0 112.828 2.828l-3 3a2 2 0 01-2.828 0 1 1 0 00-1.414 1.414 4 4 0 005.656 0l3-3a4 4 0 00-5.656-5.656l-1.5 1.5a1 1 0 101.414 1.414l1.5-1.5zm-5 5a2 2 0 012.828 0 1 1 0 101.414-1.414 4 4 0 00-5.656 0l-3 3a4 4 0 105.656 5.656l1.5-1.5a1 1 0 10-1.414-1.414l-1.5 1.5a2 2 0 11-2.828-2.828l3-3z" clip-rule="evenodd"></path>
                      </svg>
                      <span class="ml-2">
                        <%= gettext "Copy link" %>
                      </span>
                    </a>
                  </div>
                  <div class="mt-4 flex text-sm">
                    <a href="#" class="group inline-flex items-center text-gray-500 hover:text-gray-900 dark:text-gray-100">
                      <svg class="h-5 w-5 text-gray-400 dark:text-gray-100 group-hover:text-gray-500" x-description="Heroicon name: solid/question-mark-circle" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clip-rule="evenodd"></path>
                      </svg>
                      <span class="ml-2">
                      <%= gettext "Learn more about sharing " %>
                      </span>
                    </a>
                  </div>
                </div>

              </div>
            </div>
          </div>
          <div class="flex flex-shrink-0 justify-end px-4 py-4 dark:bg-gray-900">
            <button
              type="button"
              class="rounded-md border border-gray-300 bg-white dark:border-gray-700 dark:bg-black py-2 px-4 text-sm font-medium text-gray-700 dark:text-gray-300 shadow-sm hover:bg-gray-50 dark:hover:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2"
              phx-click="toggle-panel">
              <%= gettext "Cancel" %>
            </button>

            <%= submit gettext("Save"), phx_disable_with: gettext("Saving..."), class: "ml-4 inline-flex justify-center rounded-md border border-transparent bg-brand-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2" %>
          </div>
        </.form>
      </div>
    </div>

    """
  end
end
