defmodule ExploreWeb.GameLive do
  @moduledoc """
  Main game LiveView for the tower defense game.
  """
  use ExploreWeb, :live_view

  alias Explore.Game.Engine
  alias ExploreWeb.GameComponents

  @impl true
  def mount(params, _session, socket) do
    IO.puts(">>> MOUNT called, connected: #{connected?(socket)}")
    designer_mode = Map.get(params, "designer", "false") == "true"

    # Start a game engine for this session
    {:ok, engine_pid} =
      Engine.start_link(
        designer_mode: designer_mode,
        pubsub_topic: "game:#{socket.id}"
      )

    IO.puts(">>> Engine started: #{inspect(engine_pid)}")

    # Subscribe to game updates
    Phoenix.PubSub.subscribe(Explore.PubSub, "game:#{socket.id}")

    # Start the game
    Engine.start_game(engine_pid, "level_01")

    game_state = Engine.get_state(engine_pid)
    IO.puts(">>> Game state loaded, world state: #{game_state.world.state}")
    IO.puts(">>> Available towers: #{inspect(game_state.available_towers)}")

    socket =
      socket
      |> assign(:engine_pid, engine_pid)
      |> assign(:game_state, game_state)
      |> assign(:selected_tower, nil)
      |> assign(:designer_mode, designer_mode)
      |> assign(:show_debug, false)
      |> assign(:mouse_pos, {0, 0})
      |> assign(:page_title, "Tower Defense")

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    designer_mode = Map.get(params, "designer", "false") == "true"

    if designer_mode != socket.assigns.designer_mode do
      Engine.set_designer_mode(socket.assigns.engine_pid, designer_mode)
      game_state = Engine.get_state(socket.assigns.engine_pid)

      {:noreply,
       socket
       |> assign(:designer_mode, designer_mode)
       |> assign(:game_state, game_state)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-container h-screen flex flex-row" phx-hook="GameKeys" id="game-keys">
      <div class="flex-1 flex flex-col">
        <!-- Top bar with game info -->
        <div class="bg-gray-800 p-4 flex justify-between items-center border-b border-gray-700">
          <div class="flex gap-6">
            <div class="text-lg">
              <span class="text-gray-400">Wave:</span>
              <span class="font-bold">
                {@game_state.world.current_wave}/{@game_state.world.total_waves}
              </span>
            </div>
            <div class="text-lg">
              <span class="text-gray-400">Lives:</span>
              <span class={"font-bold #{if @game_state.world.lives <= 5, do: "text-red-500", else: "text-green-500"}"}>
                {@game_state.world.lives}
              </span>
            </div>
            <div class="text-lg">
              <span class="text-gray-400">Gold:</span>
              <span class="font-bold text-yellow-500">{@game_state.world.resources}</span>
            </div>
            <div class="text-lg">
              <span class="text-gray-400">Score:</span>
              <span class="font-bold">{@game_state.world.score}</span>
            </div>
          </div>
          <div class="flex gap-4">
            <%= if @game_state.world.state == :waiting do %>
              <button
                phx-click="start_wave"
                class="bg-green-600 hover:bg-green-700 px-4 py-2 rounded font-semibold"
              >
                Start Wave {@game_state.world.current_wave + 1}
              </button>
            <% end %>
            <%= if @game_state.world.state == :playing do %>
              <button
                phx-click="toggle_pause"
                class="bg-yellow-600 hover:bg-yellow-700 px-4 py-2 rounded font-semibold"
              >
                Pause
              </button>
            <% end %>
            <%= if @game_state.world.state == :paused do %>
              <button
                phx-click="toggle_pause"
                class="bg-green-600 hover:bg-green-700 px-4 py-2 rounded font-semibold"
              >
                Resume
              </button>
            <% end %>
            <%= if @game_state.world.state in [:won, :lost] do %>
              <span class={"text-2xl font-bold #{if @game_state.world.state == :won, do: "text-green-500", else: "text-red-500"}"}>
                {if @game_state.world.state == :won, do: "Victory!", else: "Game Over!"}
              </span>
            <% end %>
          </div>
        </div>
        
    <!-- Game board -->
        <div class="flex-1 relative bg-gray-900" phx-hook="GameBoard" id="game-board">
          <GameComponents.game_board
            world={@game_state.world}
            selected_tower={@selected_tower}
            mouse_pos={@mouse_pos}
            show_debug={@show_debug}
            config={@game_state.config}
          />
        </div>
        
    <!-- Designer tools (if in designer mode) -->
        <%= if @designer_mode do %>
          <GameComponents.designer_tools game_state={@game_state} show_debug={@show_debug} />
        <% end %>
      </div>
      
    <!-- Right panel - Tower selection -->
      <div class="w-64 bg-gray-800 border-l border-gray-700 p-4 flex flex-col">
        <h2 class="text-lg font-bold mb-4">Towers</h2>
        <div class="flex flex-col gap-2">
          <%= for tower_type <- @game_state.available_towers do %>
            <% tower_config = Map.get(@game_state.config.towers, tower_type, %{}) %>
            <button
              phx-click="select_tower"
              phx-value-type={tower_type}
              class={"tower-button #{if @selected_tower == tower_type, do: "selected"} #{if Map.get(tower_config, :cost, 0) > @game_state.world.resources, do: "disabled"}"}
              disabled={Map.get(tower_config, :cost, 0) > @game_state.world.resources}
            >
              <div class="font-semibold">{Map.get(tower_config, :name, tower_type)}</div>
              <div class="text-sm text-yellow-500">{Map.get(tower_config, :cost, 100)} gold</div>
            </button>
          <% end %>
        </div>
        
    <!-- Selected tower info -->
        <%= if @selected_tower do %>
          <% tower_config = Map.get(@game_state.config.towers, @selected_tower, %{}) %>
          <div class="mt-4 p-3 bg-gray-700 rounded">
            <h3 class="font-bold">{Map.get(tower_config, :name, @selected_tower)}</h3>
            <div class="text-sm mt-2 space-y-1">
              <% stats = Map.get(tower_config, :stats, %{}) %>
              <div>Damage: {Map.get(stats, :damage, 10)}</div>
              <div>Range: {Map.get(stats, :range, 100)}</div>
              <div>Fire Rate: {Map.get(stats, :fire_rate, 1.0)}/s</div>
              <%= if Map.get(stats, :aoe_radius) do %>
                <div>AOE Radius: {Map.get(stats, :aoe_radius)}</div>
              <% end %>
            </div>
            <button
              phx-click="deselect"
              class="mt-2 w-full bg-gray-600 hover:bg-gray-500 px-2 py-1 rounded text-sm"
            >
              Cancel (Esc)
            </button>
          </div>
        <% end %>
        
    <!-- Keybinds help -->
        <div class="mt-auto pt-4 border-t border-gray-700 text-xs text-gray-500">
          <div class="font-semibold mb-1">Hotkeys:</div>
          <div>P - Pause/Resume</div>
          <div>Esc - Deselect tower</div>
          <%= if @designer_mode do %>
            <div>D - Toggle debug</div>
            <div>+/- - Speed up/down</div>
            <div>Space - Single step</div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select_tower", %{"type" => type}, socket) do
    IO.puts(">>> SELECT_TOWER event received: #{type}")
    tower_type = String.to_existing_atom(type)
    {:noreply, assign(socket, :selected_tower, tower_type)}
  end

  @impl true
  def handle_event("deselect", _params, socket) do
    {:noreply, assign(socket, :selected_tower, nil)}
  end

  @impl true
  def handle_event("board_click", %{"x" => x, "y" => y}, socket) do
    IO.puts(">>> BOARD_CLICK event received at (#{x}, #{y})")

    if socket.assigns.selected_tower do
      position = {parse_coordinate(x), parse_coordinate(y)}
      IO.puts(">>> Attempting to place #{socket.assigns.selected_tower} at #{inspect(position)}")

      case Engine.place_tower(socket.assigns.engine_pid, socket.assigns.selected_tower, position) do
        {:ok, _tower} ->
          IO.puts(">>> Tower placed successfully!")
          game_state = Engine.get_state(socket.assigns.engine_pid)
          {:noreply, assign(socket, game_state: game_state)}

        {:error, reason} ->
          IO.puts(">>> Tower placement failed: #{inspect(reason)}")
          {:noreply, put_flash(socket, :error, "Cannot place tower: #{reason}")}
      end
    else
      IO.puts(">>> No tower selected, ignoring click")
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("mouse_move", %{"x" => x, "y" => y}, socket) do
    {:noreply, assign(socket, :mouse_pos, {x, y})}
  end

  @impl true
  def handle_event("start_wave", _params, socket) do
    IO.puts(">>> START_WAVE event received!")

    case Engine.start_wave(socket.assigns.engine_pid) do
      :ok ->
        IO.puts(">>> Wave started successfully!")
        game_state = Engine.get_state(socket.assigns.engine_pid)
        {:noreply, assign(socket, game_state: game_state)}

      {:error, reason} ->
        IO.puts(">>> Wave start failed: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Cannot start wave: #{reason}")}
    end
  end

  @impl true
  def handle_event("toggle_pause", _params, socket) do
    if socket.assigns.game_state.world.state == :paused do
      Engine.resume(socket.assigns.engine_pid)
    else
      Engine.pause(socket.assigns.engine_pid)
    end

    game_state = Engine.get_state(socket.assigns.engine_pid)
    {:noreply, assign(socket, game_state: game_state)}
  end

  @impl true
  def handle_event("toggle_debug", _params, socket) do
    {:noreply, assign(socket, :show_debug, not socket.assigns.show_debug)}
  end

  @impl true
  def handle_event("speed_up", _params, socket) do
    new_speed = min(4.0, socket.assigns.game_state.game_speed * 2)
    Engine.set_speed(socket.assigns.engine_pid, new_speed)
    game_state = Engine.get_state(socket.assigns.engine_pid)
    {:noreply, assign(socket, game_state: game_state)}
  end

  @impl true
  def handle_event("speed_down", _params, socket) do
    new_speed = max(0.25, socket.assigns.game_state.game_speed / 2)
    Engine.set_speed(socket.assigns.engine_pid, new_speed)
    game_state = Engine.get_state(socket.assigns.engine_pid)
    {:noreply, assign(socket, game_state: game_state)}
  end

  @impl true
  def handle_event("single_step", _params, socket) do
    if socket.assigns.game_state.world.state == :paused do
      Engine.single_step(socket.assigns.engine_pid)
      game_state = Engine.get_state(socket.assigns.engine_pid)
      {:noreply, assign(socket, game_state: game_state)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("spawn_enemy", %{"type" => type}, socket) do
    if socket.assigns.designer_mode do
      enemy_type = String.to_existing_atom(type)
      Engine.spawn_enemy(socket.assigns.engine_pid, enemy_type)
      game_state = Engine.get_state(socket.assigns.engine_pid)
      {:noreply, assign(socket, game_state: game_state)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("set_resources", %{"amount" => amount}, socket) do
    if socket.assigns.designer_mode do
      Engine.set_resources(socket.assigns.engine_pid, String.to_integer(amount))
      game_state = Engine.get_state(socket.assigns.engine_pid)
      {:noreply, assign(socket, game_state: game_state)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:state_updated, game_state}, socket) do
    {:noreply, assign(socket, :game_state, game_state)}
  end

  @impl true
  def handle_info({:tower_placed, _tower}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:wave_started, _wave}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:wave_complete, _wave}, socket) do
    {:noreply, put_flash(socket, :info, "Wave complete!")}
  end

  @impl true
  def handle_info(:game_over_win, socket) do
    {:noreply, put_flash(socket, :info, "Victory! You defended the realm!")}
  end

  @impl true
  def handle_info(:game_over_loss, socket) do
    {:noreply, put_flash(socket, :error, "Game Over! The enemies broke through!")}
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp parse_coordinate(value) when is_number(value), do: value / 1
  defp parse_coordinate(value) when is_binary(value), do: String.to_float(value)
end
