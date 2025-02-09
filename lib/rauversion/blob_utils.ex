defmodule Rauversion.BlobUtils do
  def create_blob(file) do
    ActiveStorage.Blob.create_and_upload!(
      %ActiveStorage.Blob{},
      io: {:path, file.path},
      filename: file.filename,
      content_type: file.content_type,
      identify: true
    )
  end

  #  TODO: maybe copy here the live-upload
  def attach_file_with_blob(struct, kind, file) do
    blob = Rauversion.BlobUtils.create_blob(file)
    Rauversion.BlobUtils.attach_file(struct, kind, blob)
  end

  def attach_file(struct = %Ecto.Changeset{}, kind, blob) do
    cover = apply(struct.data.__struct__, :"#{kind}", [struct.data])
    apply(cover.__struct__, :attach, [cover, blob])
  end

  def attach_file(struct, kind, blob) do
    cover = apply(struct.__struct__, :"#{kind}", [struct])
    apply(cover.__struct__, :attach, [cover, blob])
  end

  def fallback_image(url \\ nil) do
    RauversionWeb.Router.Helpers.static_path(
      RauversionWeb.Endpoint,
      url || "/images/daniel-schludi-mbGxz7pt0jM-unsplash-sqr-s.png"
    )
  end

  def blob_url(user, kind) do
    kind_blob = :"#{kind}_blob"

    case user do
      nil ->
        Rauversion.BlobUtils.fallback_image()

      %{^kind_blob => nil} ->
        Rauversion.BlobUtils.fallback_image()

      %{^kind_blob => %ActiveStorage.Blob{} = blob} ->
        blob |> ActiveStorage.url()

      %{^kind_blob => %Ecto.Association.NotLoaded{}} ->
        user = user |> Rauversion.Repo.preload(kind_blob)

        apply(__MODULE__, :blob_url, [user, kind])
    end
  end

  def blob_for(track, kind) do
    kind_blob = :"#{kind}_blob"

    # a = Rauversion.Accounts.get_user_by_username("michelson") |> Rauversion.Repo.preload(:avatar_blob)
    case track do
      nil ->
        nil

      %{^kind_blob => nil} ->
        nil

      %{^kind_blob => %ActiveStorage.Blob{} = blob} ->
        blob

      %{^kind_blob => %Ecto.Association.NotLoaded{}} ->
        track = track |> Rauversion.Repo.preload(kind_blob)
        apply(__MODULE__, :blob_for, [track, kind])
    end
  end

  def variant_url(track, kind, options \\ %{resize_to_limit: "100x100"}, fallback \\ nil) do
    case blob_for(track, kind) do
      nil ->
        if fallback, do: fallback.(), else: fallback_image()

      blob ->
        variant =
          ActiveStorage.Blob.Representable.variant(blob, options)
          |> ActiveStorage.Variant.processed()

        ActiveStorage.storage_redirect_url(variant, options)
        # |> ActiveStorage.Variant.url()
    end
  end

  def blob_url_for(track, kind) do
    blob = blob_for(track, kind)
    ActiveStorage.service_blob_url(blob)
  end

  def blob_proxy_url(track, kind) do
    blob = blob_for(track, kind)
    ActiveStorage.blob_proxy_url(blob)
  end

  def blob_representation_proxy_url(struct, kind, options \\ %{}) do
    namespace = ActiveStorage.routes_prefix()
    # sign_option = [expires_in: 3600]
    sign_option = []

    blob = __MODULE__.blob_for(struct, kind)

    case blob do
      %ActiveStorage.Blob{} = blob ->
        variant = ActiveStorage.Blob.Representable.variant(blob, options)
        filename = ActiveStorage.Blob.filename(blob)
        variation_key = variant.variation.__struct__.key(variant.variation)
        signed_blob_id = ActiveStorage.verifier().sign(blob.id)

        "#{namespace}/representations/proxy/#{signed_blob_id}/#{variation_key}/#{filename.filename}"

      _ ->
        fallback_image()
    end
  end

  def process_one_upload(struct, attrs, kind) do
    # IO.inspect(struct)

    case struct do
      %{valid?: true} ->
        # IO.inspect(attrs)

        case attrs do
          %{^kind => [file | _]} ->
            Rauversion.BlobUtils.attach_file_with_blob(struct, kind, file)
            struct

          _ ->
            struct
        end

      _ ->
        struct
    end
  end
end
