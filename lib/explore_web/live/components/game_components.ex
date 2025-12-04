defmodule ExploreWeb.GameComponents do
  @moduledoc """
  Game UI components for the tower defense game.
  """
  use Phoenix.Component

  alias Explore.Game.Combat.Damage

  @doc """
  Renders the game board with SVG graphics.
  """
  attr :world, :map, required: true
  attr :selected_tower, :atom, default: nil
  attr :mouse_pos, :any, default: {0, 0}
  attr :show_debug, :boolean, default: false
  attr :config, :map, default: %{}

  def game_board(assigns) do
    ~H"""
    <svg
      viewBox={"0 0 #{@world.map.width} #{@world.map.height}"}
      class="w-full h-full"
      preserveAspectRatio="xMidYMid meet"
    >
      <!-- Background -->
      <rect width={@world.map.width} height={@world.map.height} fill="#1f2937" />
      
    <!-- Grid (debug) -->
      <%= if @show_debug do %>
        <.grid grid={@world.map.grid} />
      <% end %>
      
    <!-- Path -->
      <.path path={@world.map.path} width={@world.map.path_width} />
      
    <!-- Valid placement indicator -->
      <%= if @selected_tower do %>
        <.placement_indicator
          world={@world}
          mouse_pos={@mouse_pos}
          selected_tower={@selected_tower}
          config={@config}
        />
      <% end %>
      
    <!-- Towers -->
      <%= for {_id, tower} <- @world.towers do %>
        <.tower tower={tower} show_range={@show_debug} />
      <% end %>
      
    <!-- Enemies -->
      <%= for {_id, enemy} <- @world.enemies do %>
        <.enemy enemy={enemy} show_debug={@show_debug} />
      <% end %>
      
    <!-- Projectiles -->
      <%= for {_id, projectile} <- @world.projectiles do %>
        <.projectile projectile={projectile} />
      <% end %>
      
    <!-- Minions -->
      <%= for {_id, minion} <- @world.minions do %>
        <.minion minion={minion} />
      <% end %>
      
    <!-- Visual effects -->
      <%= for effect <- @world.effects do %>
        <.effect effect={effect} />
      <% end %>
    </svg>
    """
  end

  attr :grid, :any, required: true

  defp grid(assigns) do
    ~H"""
    <g class="grid">
      <%= for x <- 0..(@grid.width - 1), y <- 0..(@grid.height - 1) do %>
        <% cell_state = Explore.Game.Map.Grid.get_cell(@grid, {x, y}) %>
        <rect
          x={x * @grid.cell_size}
          y={y * @grid.cell_size}
          width={@grid.cell_size}
          height={@grid.cell_size}
          class={"grid-cell #{cell_state}"}
          stroke="#374151"
          stroke-width="0.5"
          fill={cell_fill(cell_state)}
        />
      <% end %>
    </g>
    """
  end

  defp cell_fill(:empty), do: "transparent"
  defp cell_fill(:path), do: "rgba(180, 83, 9, 0.3)"
  defp cell_fill(:tower), do: "rgba(59, 130, 246, 0.3)"
  defp cell_fill(:blocked), do: "rgba(239, 68, 68, 0.3)"
  defp cell_fill(_), do: "transparent"

  attr :path, :any, required: true
  attr :width, :integer, default: 30

  defp path(assigns) do
    waypoints = assigns.path.waypoints
    path_d = build_path_d(waypoints)

    assigns = assign(assigns, :path_d, path_d)

    ~H"""
    <path
      d={@path_d}
      fill="none"
      stroke="#92400e"
      stroke-width={@width}
      stroke-linecap="round"
      stroke-linejoin="round"
    />
    <path
      d={@path_d}
      fill="none"
      stroke="#78350f"
      stroke-width={@width - 4}
      stroke-linecap="round"
      stroke-linejoin="round"
    />
    """
  end

  defp build_path_d([]), do: ""

  defp build_path_d([{x, y} | rest]) do
    start = "M #{x} #{y}"
    lines = Enum.map(rest, fn {px, py} -> "L #{px} #{py}" end)
    Enum.join([start | lines], " ")
  end

  attr :world, :map, required: true
  attr :mouse_pos, :any, required: true
  attr :selected_tower, :atom, required: true
  attr :config, :map, required: true

  defp placement_indicator(assigns) do
    {mx, my} = assigns.mouse_pos
    grid = assigns.world.map.grid
    snapped = Explore.Game.Map.Grid.world_to_grid(grid, {mx, my})
    {sx, sy} = Explore.Game.Map.Grid.grid_to_world(grid, snapped)
    can_place = Explore.Game.Map.Grid.can_place_tower?(grid, snapped)

    tower_config = Map.get(assigns.config.towers, assigns.selected_tower, %{})
    range = get_in(tower_config, [:stats, :range]) || 100

    assigns =
      assigns
      |> assign(:sx, sx)
      |> assign(:sy, sy)
      |> assign(:can_place, can_place)
      |> assign(:range, range)
      |> assign(:cell_size, grid.cell_size)

    ~H"""
    <g>
      <!-- Range indicator -->
      <circle
        cx={@sx}
        cy={@sy}
        r={@range}
        fill={if @can_place, do: "rgba(59, 130, 246, 0.1)", else: "rgba(239, 68, 68, 0.1)"}
        stroke={if @can_place, do: "#3b82f6", else: "#ef4444"}
        stroke-width="1"
        stroke-dasharray="4"
      />
      <!-- Tower placeholder -->
      <rect
        x={@sx - @cell_size / 2}
        y={@sy - @cell_size / 2}
        width={@cell_size}
        height={@cell_size}
        fill={if @can_place, do: "rgba(59, 130, 246, 0.5)", else: "rgba(239, 68, 68, 0.5)"}
        stroke={if @can_place, do: "#3b82f6", else: "#ef4444"}
        stroke-width="2"
        rx="4"
      />
    </g>
    """
  end

  attr :tower, :map, required: true
  attr :show_range, :boolean, default: false

  defp tower(assigns) do
    {x, y} = assigns.tower.position
    range = Explore.Game.Entities.Tower.range(assigns.tower)
    damage_type = Explore.Game.Entities.Tower.damage_type(assigns.tower)
    color = Damage.damage_type_color(damage_type)

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:range, range)
      |> assign(:color, color)

    ~H"""
    <g class="tower">
      <!-- Range indicator (on hover/debug) -->
      <%= if @show_range do %>
        <circle
          cx={@x}
          cy={@y}
          r={@range}
          fill="rgba(59, 130, 246, 0.1)"
          stroke="#3b82f6"
          stroke-width="1"
        />
      <% end %>
      <!-- Tower body -->
      <rect
        x={@x - 15}
        y={@y - 15}
        width="30"
        height="30"
        fill={@color}
        stroke="#1f2937"
        stroke-width="2"
        rx="4"
      />
      <!-- Tower turret -->
      <circle cx={@x} cy={@y} r="8" fill="#1f2937" />
      <circle cx={@x} cy={@y} r="5" fill={@color} />
    </g>
    """
  end

  attr :enemy, :map, required: true
  attr :show_debug, :boolean, default: false

  defp enemy(assigns) do
    {x, y} = assigns.enemy.position
    health_pct = Explore.Game.Entities.Enemy.health_percentage(assigns.enemy)
    is_slowed = Explore.Game.Entities.Enemy.has_effect?(assigns.enemy, :slow)
    is_burning = Explore.Game.Entities.Enemy.has_effect?(assigns.enemy, :burn)

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:health_pct, health_pct)
      |> assign(:is_slowed, is_slowed)
      |> assign(:is_burning, is_burning)

    ~H"""
    <g class="enemy">
      <!-- Effect indicators -->
      <%= if @is_slowed do %>
        <circle cx={@x} cy={@y} r="16" class="effect-slow" />
      <% end %>
      <%= if @is_burning do %>
        <circle cx={@x} cy={@y} r="14" class="effect-burn" />
      <% end %>
      
    <!-- Enemy body -->
      <circle cx={@x} cy={@y} r="12" fill="#dc2626" stroke="#7f1d1d" stroke-width="2" />
      
    <!-- Health bar background -->
      <rect x={@x - 15} y={@y - 22} width="30" height="4" fill="#374151" rx="2" />
      <!-- Health bar -->
      <rect
        x={@x - 15}
        y={@y - 22}
        width={30 * @health_pct}
        height="4"
        fill={if @health_pct > 0.3, do: "#22c55e", else: "#ef4444"}
        rx="2"
      />
      
    <!-- Debug info -->
      <%= if @show_debug do %>
        <text x={@x} y={@y + 25} text-anchor="middle" fill="white" font-size="10">
          {trunc(@enemy.health)}/{@enemy.max_health}
        </text>
      <% end %>
    </g>
    """
  end

  attr :projectile, :map, required: true

  defp projectile(assigns) do
    {x, y} = assigns.projectile.position
    color = Damage.damage_type_color(assigns.projectile.damage_type)

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:color, color)

    ~H"""
    <circle cx={@x} cy={@y} r="4" fill={@color} class="projectile" />
    """
  end

  attr :minion, :map, required: true

  defp minion(assigns) do
    {x, y} = assigns.minion.position

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)

    ~H"""
    <g class="minion">
      <circle cx={@x} cy={@y} r="8" fill="#f59e0b" stroke="#92400e" stroke-width="2" />
      <!-- Fuse -->
      <line x1={@x} y1={@y - 8} x2={@x} y2={@y - 14} stroke="#ef4444" stroke-width="2" />
    </g>
    """
  end

  attr :effect, :map, required: true

  defp effect(assigns) do
    ~H"""
    <circle
      cx={Map.get(@effect, :x, 0)}
      cy={Map.get(@effect, :y, 0)}
      r={Map.get(@effect, :radius, 20)}
      fill={Map.get(@effect, :color, "#f97316")}
      opacity="0.5"
      class="explosion"
    />
    """
  end

  @doc """
  Renders designer mode tools.
  """
  attr :game_state, :map, required: true
  attr :show_debug, :boolean, default: false

  def designer_tools(assigns) do
    ~H"""
    <div class="designer-panel border-t border-gray-700 bg-gray-900/90 p-4">
      <div class="flex gap-6 items-center">
        <div class="text-sm font-bold text-yellow-500">DESIGNER MODE</div>

        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-400">Speed:</span>
          <span class="font-bold">{@game_state.game_speed}x</span>
        </div>

        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-400">Tick:</span>
          <span class="font-mono">{@game_state.world.tick}</span>
        </div>

        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-400">Enemies:</span>
          <span>{map_size(@game_state.world.enemies)}</span>
        </div>

        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-400">Debug:</span>
          <button
            phx-click="toggle_debug"
            class={"px-2 py-1 rounded text-xs #{if @show_debug, do: "bg-green-600", else: "bg-gray-600"}"}
          >
            {if @show_debug, do: "ON", else: "OFF"}
          </button>
        </div>

        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-400">Spawn:</span>
          <%= for {type, _config} <- @game_state.config.enemies do %>
            <button
              phx-click="spawn_enemy"
              phx-value-type={type}
              class="px-2 py-1 bg-red-600 hover:bg-red-700 rounded text-xs"
            >
              {type}
            </button>
          <% end %>
        </div>

        <form phx-submit="set_resources" class="flex items-center gap-2">
          <span class="text-sm text-gray-400">Set Gold:</span>
          <input
            type="number"
            name="amount"
            value={@game_state.world.resources}
            class="w-20 px-2 py-1 bg-gray-700 rounded text-sm"
          />
          <button type="submit" class="px-2 py-1 bg-blue-600 hover:bg-blue-700 rounded text-xs">
            Set
          </button>
        </form>
      </div>
    </div>
    """
  end
end
