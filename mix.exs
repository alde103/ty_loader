defmodule TyLoader.MixProject do
  use Mix.Project

  def project do
    [
      app: :ty_loader,
      version: "0.1.0",
      elixir: "~> 1.10",
      name: "Ty_Loader",
      description: description(),
      package: package(),
      source_url: "https://github.com/valiot/ty_loader",
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_targets: ["all"],
      make_clean: ["clean"],
      make_executable: make_executable(),
      make_makefile: "src/Makefile",
      make_error_message: make_error_message(),
      make_env: &make_env/0,
      docs: [extras: ["README.md"], main: "readme"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps()
    ]
  end

  defp make_env() do
    base =
      Mix.Project.compile_path()
      |> Path.join("..")
      |> Path.expand()

    %{
      "MIX_ENV" => to_string(Mix.env()),
      "PREFIX" => Path.join(base, "priv"),
      "BUILD" => Path.join(base, "obj")
    }
    |> Map.merge(ei_env())
  end

  defp ei_env() do
    case System.get_env("ERL_EI_INCLUDE_DIR") do
      nil ->
        %{
          "ERL_EI_INCLUDE_DIR" => "#{:code.root_dir()}/usr/include",
          "ERL_EI_LIBDIR" => "#{:code.root_dir()}/usr/lib"
        }

      _ ->
        %{}
    end
  end

  defp make_executable do
    case :os.type() do
      {:win32, _} ->
        "mingw32-make"

      _ ->
        :default
    end
  end

  @windows_mingw_error_msg """
  You may need to install mingw-w64 and make sure that it is in your PATH. Test this by
  running `gcc --version` on the command line.
  If you do not have mingw-w64, one method to install it is by using
  Chocolatey. See http://chocolatey.org to install Chocolatey and run the
  following from and command prompt with administrative privileges:
  `choco install mingw`
  """

  defp make_error_message do
    case :os.type() do
      {:win32, _} -> @windows_mingw_error_msg
      _ -> :default
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Elixir wrapper for `teensy_loader_cli` (Command line Teensy Loader)."
  end

  defp package() do
    [
      files: [
        "lib",
        "src/teensy_loader_cli/*.[ch]",
        "src/Makefile",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      maintainers: ["valiot"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/valiot/snapex7"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.5", runtime: false},
      {:ex_doc, "~> 0.19", only: :dev},
      {:muontrap, "~> 0.5.0"}
    ]
  end
end
