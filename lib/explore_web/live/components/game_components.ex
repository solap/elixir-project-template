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
        <.tower tower={tower} show_range={@show_debug} config={@config} />
      <% end %>
      
    <!-- Enemies -->
      <%= for {_id, enemy} <- @world.enemies do %>
        <.enemy enemy={enemy} show_debug={@show_debug} config={@config} />
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

  # ============================================================================
  # TOWER VISUALS - Unique graphics for each tower type
  # ============================================================================

  attr :tower, :map, required: true
  attr :show_range, :boolean, default: false
  attr :config, :map, default: %{}

  defp tower(assigns) do
    {x, y} = assigns.tower.position
    range = Explore.Game.Entities.Tower.range(assigns.tower)
    tower_type = assigns.tower.type

    tower_config = Map.get(assigns.config.towers, tower_type, %{})
    visual = Map.get(tower_config, :visual, %{})
    color = Map.get(visual, :color, "#3b82f6")
    accent = Map.get(visual, :accent, "#1d4ed8")

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:range, range)
      |> assign(:tower_type, tower_type)
      |> assign(:color, color)
      |> assign(:accent, accent)

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
      <!-- Tower visual based on type -->
      <.tower_visual type={@tower_type} x={@x} y={@y} color={@color} accent={@accent} />
    </g>
    """
  end

  attr :type, :atom, required: true
  attr :x, :float, required: true
  attr :y, :float, required: true
  attr :color, :string, required: true
  attr :accent, :string, required: true

  defp tower_visual(%{type: :arrow_tower} = assigns) do
    ~H"""
    <g>
      <!-- Wooden base -->
      <rect
        x={@x - 12}
        y={@y - 12}
        width="24"
        height="24"
        fill={@color}
        stroke={@accent}
        stroke-width="2"
        rx="2"
      />
      <!-- Bow shape -->
      <path
        d={"M #{@x - 6} #{@y - 8} Q #{@x - 10} #{@y} #{@x - 6} #{@y + 8}"}
        fill="none"
        stroke={@accent}
        stroke-width="3"
      />
      <!-- Arrow -->
      <line x1={@x - 4} y1={@y} x2={@x + 10} y2={@y} stroke="#1f2937" stroke-width="2" />
      <polygon points={"#{@x + 10},#{@y - 3} #{@x + 15},#{@y} #{@x + 10},#{@y + 3}"} fill="#1f2937" />
    </g>
    """
  end

  defp tower_visual(%{type: :flame_tower} = assigns) do
    ~H"""
    <g>
      <!-- Brazier base -->
      <path
        d={"M #{@x - 10} #{@y + 10} L #{@x - 14} #{@y - 4} L #{@x + 14} #{@y - 4} L #{@x + 10} #{@y + 10} Z"}
        fill={@accent}
        stroke="#1f2937"
        stroke-width="2"
      />
      <!-- Fire -->
      <ellipse cx={@x} cy={@y - 4} rx="10" ry="6" fill={@color} />
      <ellipse cx={@x - 3} cy={@y - 8} rx="4" ry="6" fill="#FACC15" class="flame-flicker" />
      <ellipse cx={@x + 3} cy={@y - 10} rx="3" ry="5" fill="#FEF08A" class="flame-flicker-alt" />
    </g>
    """
  end

  defp tower_visual(%{type: :frost_tower} = assigns) do
    ~H"""
    <g>
      <!-- Ice crystal base -->
      <polygon
        points={"#{@x},#{@y - 14} #{@x + 12},#{@y} #{@x},#{@y + 14} #{@x - 12},#{@y}"}
        fill={@color}
        stroke={@accent}
        stroke-width="2"
      />
      <!-- Inner crystal -->
      <polygon
        points={"#{@x},#{@y - 8} #{@x + 6},#{@y} #{@x},#{@y + 8} #{@x - 6},#{@y}"}
        fill={@accent}
      />
      <!-- Sparkle -->
      <circle cx={@x} cy={@y - 4} r="2" fill="white" class="sparkle" />
    </g>
    """
  end

  defp tower_visual(%{type: :lightning_tower} = assigns) do
    ~H"""
    <g>
      <!-- Tesla coil base -->
      <rect
        x={@x - 8}
        y={@y + 2}
        width="16"
        height="12"
        fill="#374151"
        stroke="#1f2937"
        stroke-width="2"
        rx="2"
      />
      <!-- Coil rings -->
      <ellipse cx={@x} cy={@y - 2} rx="10" ry="4" fill="none" stroke={@color} stroke-width="2" />
      <ellipse cx={@x} cy={@y - 6} rx="8" ry="3" fill="none" stroke={@color} stroke-width="2" />
      <ellipse cx={@x} cy={@y - 9} rx="6" ry="2" fill="none" stroke={@color} stroke-width="2" />
      <!-- Top ball -->
      <circle cx={@x} cy={@y - 12} r="4" fill={@accent} class="electric-glow" />
    </g>
    """
  end

  defp tower_visual(%{type: :bomb_launcher} = assigns) do
    ~H"""
    <g>
      <!-- Mortar base -->
      <rect
        x={@x - 10}
        y={@y + 4}
        width="20"
        height="10"
        fill={@accent}
        stroke="#1f2937"
        stroke-width="2"
        rx="2"
      />
      <!-- Barrel -->
      <ellipse cx={@x} cy={@y - 2} rx="8" ry="6" fill={@color} stroke="#1f2937" stroke-width="2" />
      <!-- Opening -->
      <ellipse cx={@x} cy={@y - 6} rx="5" ry="3" fill="#1f2937" />
    </g>
    """
  end

  defp tower_visual(%{type: :minion_factory} = assigns) do
    ~H"""
    <g>
      <!-- Factory building -->
      <rect
        x={@x - 12}
        y={@y - 8}
        width="24"
        height="20"
        fill={@color}
        stroke="#1f2937"
        stroke-width="2"
      />
      <!-- Roof -->
      <polygon
        points={"#{@x - 14},#{@y - 8} #{@x},#{@y - 16} #{@x + 14},#{@y - 8}"}
        fill={@accent}
        stroke="#1f2937"
        stroke-width="2"
      />
      <!-- Door -->
      <rect x={@x - 4} y={@y + 2} width="8" height="10" fill="#1f2937" />
      <!-- Window -->
      <rect x={@x - 8} y={@y - 4} width="4" height="4" fill="#FACC15" />
      <rect x={@x + 4} y={@y - 4} width="4" height="4" fill="#FACC15" />
    </g>
    """
  end

  defp tower_visual(%{type: :sniper_tower} = assigns) do
    ~H"""
    <g>
      <!-- Tall tower base -->
      <rect
        x={@x - 6}
        y={@y - 4}
        width="12"
        height="18"
        fill={@color}
        stroke="#1f2937"
        stroke-width="2"
      />
      <!-- Scope platform -->
      <rect
        x={@x - 10}
        y={@y - 10}
        width="20"
        height="6"
        fill={@accent}
        stroke="#1f2937"
        stroke-width="2"
      />
      <!-- Scope/barrel -->
      <rect x={@x + 6} y={@y - 8} width="10" height="3" fill="#1f2937" />
      <circle cx={@x + 16} cy={@y - 6.5} r="2" fill="#60A5FA" />
    </g>
    """
  end

  defp tower_visual(%{type: :poison_tower} = assigns) do
    ~H"""
    <g>
      <!-- Cauldron -->
      <ellipse cx={@x} cy={@y + 6} rx="12" ry="8" fill={@accent} stroke="#1f2937" stroke-width="2" />
      <ellipse cx={@x} cy={@y - 2} rx="10" ry="4" fill={@color} />
      <!-- Bubbles -->
      <circle cx={@x - 4} cy={@y - 4} r="3" fill="#86EFAC" class="bubble" />
      <circle cx={@x + 5} cy={@y - 6} r="2" fill="#86EFAC" class="bubble-alt" />
      <circle cx={@x} cy={@y - 8} r="2.5" fill="#86EFAC" class="bubble" />
    </g>
    """
  end

  defp tower_visual(%{type: :laser_tower} = assigns) do
    ~H"""
    <g>
      <!-- Dish base -->
      <rect
        x={@x - 6}
        y={@y + 2}
        width="12"
        height="12"
        fill="#374151"
        stroke="#1f2937"
        stroke-width="2"
      />
      <!-- Satellite dish -->
      <path
        d={"M #{@x - 12} #{@y - 2} Q #{@x} #{@y - 14} #{@x + 12} #{@y - 2}"}
        fill={@color}
        stroke={@accent}
        stroke-width="2"
      />
      <!-- Emitter -->
      <circle cx={@x} cy={@y - 4} r="4" fill={@accent} class="laser-glow" />
      <circle cx={@x} cy={@y - 4} r="2" fill="white" />
    </g>
    """
  end

  defp tower_visual(%{type: :cannon_tower} = assigns) do
    ~H"""
    <g>
      <!-- Cannon base -->
      <rect
        x={@x - 10}
        y={@y + 4}
        width="20"
        height="10"
        fill="#1f2937"
        stroke="#374151"
        stroke-width="2"
        rx="2"
      />
      <!-- Cannon barrel -->
      <rect
        x={@x - 6}
        y={@y - 8}
        width="12"
        height="14"
        fill={@color}
        stroke={@accent}
        stroke-width="2"
        rx="2"
      />
      <!-- Barrel opening -->
      <ellipse cx={@x} cy={@y - 8} rx="5" ry="3" fill="#1f2937" />
      <!-- Wheels -->
      <circle cx={@x - 8} cy={@y + 10} r="4" fill="#374151" stroke="#1f2937" stroke-width="1" />
      <circle cx={@x + 8} cy={@y + 10} r="4" fill="#374151" stroke="#1f2937" stroke-width="1" />
    </g>
    """
  end

  # Default tower visual fallback
  defp tower_visual(assigns) do
    ~H"""
    <g>
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
      <circle cx={@x} cy={@y} r="8" fill="#1f2937" />
      <circle cx={@x} cy={@y} r="5" fill={@accent} />
    </g>
    """
  end

  # ============================================================================
  # ENEMY VISUALS - Unique graphics for each enemy type based on config
  # ============================================================================

  attr :enemy, :map, required: true
  attr :show_debug, :boolean, default: false
  attr :config, :map, default: %{}

  defp enemy(assigns) do
    {x, y} = assigns.enemy.position
    health_pct = Explore.Game.Entities.Enemy.health_percentage(assigns.enemy)
    is_slowed = Explore.Game.Entities.Enemy.has_effect?(assigns.enemy, :slow)
    is_burning = Explore.Game.Entities.Enemy.has_effect?(assigns.enemy, :burn)
    is_poisoned = Explore.Game.Entities.Enemy.has_effect?(assigns.enemy, :poison)
    enemy_type = assigns.enemy.type

    enemy_config = Map.get(assigns.config.enemies, enemy_type, %{})
    visual = Map.get(enemy_config, :visual, %{})

    size = Map.get(visual, :size, :medium)
    color = Map.get(visual, :color, "#DC2626")
    accent = Map.get(visual, :accent, "#7F1D1D")
    shape = Map.get(visual, :shape, :circle)
    animation = Map.get(visual, :animation, :bounce)

    radius = size_to_radius(size)

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:health_pct, health_pct)
      |> assign(:is_slowed, is_slowed)
      |> assign(:is_burning, is_burning)
      |> assign(:is_poisoned, is_poisoned)
      |> assign(:color, color)
      |> assign(:accent, accent)
      |> assign(:shape, shape)
      |> assign(:radius, radius)
      |> assign(:animation, animation)
      |> assign(:size, size)

    ~H"""
    <g class={"enemy enemy-#{@animation}"} style={"transform-origin: #{@x}px #{@y}px"}>
      <!-- Effect indicators -->
      <%= if @is_slowed do %>
        <circle cx={@x} cy={@y} r={@radius + 4} class="effect-slow" />
      <% end %>
      <%= if @is_burning do %>
        <circle cx={@x} cy={@y} r={@radius + 3} class="effect-burn" />
      <% end %>
      <%= if @is_poisoned do %>
        <.poison_effect x={@x} y={@y} radius={@radius} />
      <% end %>
      
    <!-- Enemy shadow -->
      <ellipse cx={@x} cy={@y + @radius} rx={@radius * 0.8} ry={@radius * 0.3} fill="rgba(0,0,0,0.3)" />
      
    <!-- Enemy body based on shape -->
      <.enemy_shape
        shape={@shape}
        x={@x}
        y={@y}
        radius={@radius}
        color={@color}
        accent={@accent}
        size={@size}
      />
      
    <!-- Health bar background -->
      <rect
        x={@x - @radius - 2}
        y={@y - @radius - 6}
        width={(@radius + 2) * 2}
        height="3"
        fill="#374151"
        rx="1"
      />
      <!-- Health bar -->
      <rect
        x={@x - @radius - 2}
        y={@y - @radius - 6}
        width={(@radius + 2) * 2 * @health_pct}
        height="3"
        fill={if @health_pct > 0.3, do: "#22c55e", else: "#ef4444"}
        rx="1"
      />
      
    <!-- Debug info -->
      <%= if @show_debug do %>
        <text x={@x} y={@y + @radius + 12} text-anchor="middle" fill="white" font-size="8">
          {trunc(@enemy.health)}/{@enemy.max_health}
        </text>
      <% end %>
    </g>
    """
  end

  defp size_to_radius(:tiny), do: 3
  defp size_to_radius(:small), do: 5
  defp size_to_radius(:medium), do: 7
  defp size_to_radius(:large), do: 10
  defp size_to_radius(:boss), do: 16
  defp size_to_radius(_), do: 6

  # Poison effect visual - green dripping blobs
  attr :x, :float, required: true
  attr :y, :float, required: true
  attr :radius, :integer, required: true

  defp poison_effect(assigns) do
    ~H"""
    <g class="effect-poison">
      <!-- Two overlapping green translucent blobs -->
      <ellipse
        cx={@x - @radius * 0.3}
        cy={@y + @radius * 0.5}
        rx={@radius * 0.5}
        ry={@radius * 0.7}
        fill="#22C55E"
        opacity="0.5"
      />
      <ellipse
        cx={@x + @radius * 0.4}
        cy={@y + @radius * 0.3}
        rx={@radius * 0.4}
        ry={@radius * 0.6}
        fill="#16A34A"
        opacity="0.4"
      />
      <!-- Dripping drops -->
      <ellipse
        cx={@x - @radius * 0.1}
        cy={@y + @radius + 2}
        rx="2"
        ry="3"
        fill="#22C55E"
        opacity="0.6"
        class="poison-drip"
      />
      <ellipse
        cx={@x + @radius * 0.3}
        cy={@y + @radius + 4}
        rx="1.5"
        ry="2.5"
        fill="#16A34A"
        opacity="0.5"
        class="poison-drip-delayed"
      />
    </g>
    """
  end

  attr :shape, :atom, required: true
  attr :x, :float, required: true
  attr :y, :float, required: true
  attr :radius, :integer, required: true
  attr :color, :string, required: true
  attr :accent, :string, required: true
  attr :size, :atom, required: true

  defp enemy_shape(%{shape: :circle} = assigns) do
    ~H"""
    <g class="enemy-body">
      <circle cx={@x} cy={@y} r={@radius} fill={@color} stroke={@accent} stroke-width="1.5" />
      <!-- Eyes -->
      <%= if @size != :tiny do %>
        <circle
          cx={@x - @radius * 0.3}
          cy={@y - @radius * 0.2}
          r={max(1, @radius * 0.2)}
          fill="#1f2937"
        />
        <circle
          cx={@x + @radius * 0.3}
          cy={@y - @radius * 0.2}
          r={max(1, @radius * 0.2)}
          fill="#1f2937"
        />
      <% end %>
    </g>
    """
  end

  defp enemy_shape(%{shape: :square} = assigns) do
    ~H"""
    <g class="enemy-body">
      <rect
        x={@x - @radius}
        y={@y - @radius}
        width={@radius * 2}
        height={@radius * 2}
        fill={@color}
        stroke={@accent}
        stroke-width="2"
        rx={@radius * 0.2}
      />
      <!-- Eyes -->
      <%= if @size != :tiny do %>
        <rect
          x={@x - @radius * 0.5}
          y={@y - @radius * 0.3}
          width={max(2, @radius * 0.3)}
          height={max(2, @radius * 0.4)}
          fill="#1f2937"
        />
        <rect
          x={@x + @radius * 0.2}
          y={@y - @radius * 0.3}
          width={max(2, @radius * 0.3)}
          height={max(2, @radius * 0.4)}
          fill="#1f2937"
        />
      <% end %>
    </g>
    """
  end

  defp enemy_shape(%{shape: :triangle} = assigns) do
    ~H"""
    <g class="enemy-body">
      <polygon
        points={"#{@x},#{@y - @radius} #{@x + @radius},#{@y + @radius * 0.7} #{@x - @radius},#{@y + @radius * 0.7}"}
        fill={@color}
        stroke={@accent}
        stroke-width="1.5"
      />
      <!-- Eyes -->
      <%= if @size != :tiny do %>
        <circle cx={@x - @radius * 0.25} cy={@y} r={max(1, @radius * 0.15)} fill="#1f2937" />
        <circle cx={@x + @radius * 0.25} cy={@y} r={max(1, @radius * 0.15)} fill="#1f2937" />
      <% end %>
    </g>
    """
  end

  defp enemy_shape(%{shape: :blob} = assigns) do
    ~H"""
    <g class="enemy-body">
      <ellipse
        cx={@x}
        cy={@y}
        rx={@radius * 1.2}
        ry={@radius * 0.8}
        fill={@color}
        stroke={@accent}
        stroke-width="1.5"
      />
      <!-- Blobby bumps -->
      <circle cx={@x - @radius * 0.6} cy={@y - @radius * 0.3} r={@radius * 0.4} fill={@color} />
      <circle cx={@x + @radius * 0.5} cy={@y - @radius * 0.4} r={@radius * 0.35} fill={@color} />
      <!-- Eyes -->
      <%= if @size != :tiny do %>
        <circle
          cx={@x - @radius * 0.3}
          cy={@y - @radius * 0.1}
          r={max(1, @radius * 0.18)}
          fill="#1f2937"
        />
        <circle
          cx={@x + @radius * 0.3}
          cy={@y - @radius * 0.1}
          r={max(1, @radius * 0.18)}
          fill="#1f2937"
        />
      <% end %>
    </g>
    """
  end

  # Fallback shape
  defp enemy_shape(assigns) do
    ~H"""
    <g class="enemy-body">
      <circle cx={@x} cy={@y} r={@radius} fill={@color} stroke={@accent} stroke-width="1.5" />
    </g>
    """
  end

  # ============================================================================
  # PROJECTILE VISUALS - Unique graphics for each projectile type
  # ============================================================================

  attr :projectile, :map, required: true

  defp projectile(assigns) do
    {x, y} = assigns.projectile.position
    {tx, ty} = assigns.projectile.target_position
    projectile_type = Map.get(assigns.projectile, :projectile_type, :arrow)
    damage_type = assigns.projectile.damage_type

    # Calculate angle for directional projectiles
    dx = tx - x
    dy = ty - y
    angle = :math.atan2(dy, dx) * 180 / :math.pi()

    # Symmetric projectiles shouldn't rotate (they look the same from all angles)
    no_rotation = projectile_type in [:iceball, :cannonball, :fireball, :poison_glob, :laser_beam]

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:angle, angle)
      |> assign(:projectile_type, projectile_type)
      |> assign(:damage_type, damage_type)
      |> assign(:no_rotation, no_rotation)

    ~H"""
    <g class="projectile" transform={if @no_rotation, do: "", else: "rotate(#{@angle}, #{@x}, #{@y})"}>
      <.projectile_visual projectile_type={@projectile_type} damage_type={@damage_type} x={@x} y={@y} />
    </g>
    """
  end

  attr :projectile_type, :atom, required: true
  attr :damage_type, :atom, required: true
  attr :x, :float, required: true
  attr :y, :float, required: true

  # Arrow projectile (default, from arrow tower)
  defp projectile_visual(%{projectile_type: :arrow} = assigns) do
    ~H"""
    <g>
      <!-- Arrow shaft -->
      <line x1={@x - 8} y1={@y} x2={@x + 4} y2={@y} stroke="#8B4513" stroke-width="2" />
      <!-- Arrow head -->
      <polygon points={"#{@x + 4},#{@y - 3} #{@x + 10},#{@y} #{@x + 4},#{@y + 3}"} fill="#94a3b8" />
      <!-- Fletching -->
      <polygon points={"#{@x - 8},#{@y} #{@x - 12},#{@y - 3} #{@x - 10},#{@y}"} fill="#DC2626" />
      <polygon points={"#{@x - 8},#{@y} #{@x - 12},#{@y + 3} #{@x - 10},#{@y}"} fill="#DC2626" />
    </g>
    """
  end

  # Bullet projectile (sniper tower)
  defp projectile_visual(%{projectile_type: :bullet} = assigns) do
    ~H"""
    <g class="bullet-tracer">
      <!-- Bullet tracer trail -->
      <line x1={@x - 12} y1={@y} x2={@x - 4} y2={@y} stroke="#FEF08A" stroke-width="2" opacity="0.6" />
      <line x1={@x - 18} y1={@y} x2={@x - 12} y2={@y} stroke="#FEF08A" stroke-width="1" opacity="0.3" />
      <!-- Main bullet -->
      <ellipse cx={@x} cy={@y} rx="4" ry="2" fill="#94a3b8" />
      <ellipse cx={@x + 1} cy={@y - 0.5} rx="2" ry="1" fill="#e2e8f0" />
    </g>
    """
  end

  # Cannonball projectile (cannon tower)
  defp projectile_visual(%{projectile_type: :cannonball} = assigns) do
    ~H"""
    <g>
      <!-- Cannonball -->
      <circle cx={@x} cy={@y} r="6" fill="#1f2937" />
      <circle cx={@x - 2} cy={@y - 2} r="2" fill="#4b5563" opacity="0.6" />
      <!-- Smoke trail -->
      <circle cx={@x - 8} cy={@y} r="3" fill="#9ca3af" opacity="0.4" />
      <circle cx={@x - 14} cy={@y + 1} r="2" fill="#9ca3af" opacity="0.2" />
    </g>
    """
  end

  # Bomb projectile (bomb tower) - arcs up and down
  defp projectile_visual(%{projectile_type: :bomb} = assigns) do
    ~H"""
    <g class="bomb-projectile">
      <!-- Bomb body -->
      <circle cx={@x} cy={@y} r="5" fill="#1f2937" />
      <!-- Highlight -->
      <circle cx={@x - 1} cy={@y - 1} r="2" fill="#4b5563" />
      <!-- Fuse -->
      <line x1={@x + 3} y1={@y - 3} x2={@x + 6} y2={@y - 5} stroke="#92400e" stroke-width="1.5" />
      <!-- Spark on fuse -->
      <circle cx={@x + 6} cy={@y - 5} r="2" fill="#fbbf24" class="fuse-spark" />
      <circle cx={@x + 6} cy={@y - 5} r="1" fill="#fef08a" />
    </g>
    """
  end

  # Fireball projectile (flame tower)
  defp projectile_visual(%{projectile_type: :fireball} = assigns) do
    ~H"""
    <g>
      <!-- Fire trail -->
      <ellipse cx={@x - 6} cy={@y} rx="4" ry="3" fill="#FACC15" opacity="0.6" />
      <ellipse cx={@x - 10} cy={@y} rx="3" ry="2" fill="#F97316" opacity="0.4" />
      <!-- Main fireball -->
      <circle cx={@x} cy={@y} r="5" fill="#F97316" />
      <circle cx={@x + 1} cy={@y - 1} r="3" fill="#FACC15" />
    </g>
    """
  end

  # Ice shard projectile (frost tower)
  defp projectile_visual(%{projectile_type: :iceball} = assigns) do
    ~H"""
    <g>
      <!-- Ice crystal -->
      <polygon
        points={"#{@x - 4},#{@y} #{@x},#{@y - 3} #{@x + 6},#{@y} #{@x},#{@y + 3}"}
        fill="#38BDF8"
        stroke="#E0F2FE"
        stroke-width="1"
      />
      <!-- Sparkle -->
      <circle cx={@x + 2} cy={@y - 1} r="1" fill="white" />
    </g>
    """
  end

  # Lightning bolt projectile (lightning tower)
  defp projectile_visual(%{projectile_type: :lightning} = assigns) do
    ~H"""
    <g>
      <!-- Lightning bolt -->
      <polyline
        points={"#{@x - 6},#{@y - 2} #{@x - 2},#{@y - 2} #{@x - 4},#{@y} #{@x + 2},#{@y} #{@x},#{@y + 2} #{@x + 6},#{@y + 2}"}
        fill="none"
        stroke="#FACC15"
        stroke-width="2"
      />
      <!-- Glow -->
      <circle cx={@x} cy={@y} r="4" fill="#FEF08A" opacity="0.5" />
    </g>
    """
  end

  # Poison glob projectile (poison tower)
  defp projectile_visual(%{projectile_type: :poison_glob} = assigns) do
    ~H"""
    <g class="poison-glob">
      <!-- Main glob -->
      <circle cx={@x} cy={@y} r="5" fill="#22C55E" opacity="0.9" />
      <!-- Dripping drops -->
      <ellipse cx={@x - 4} cy={@y + 3} rx="2" ry="3" fill="#22C55E" opacity="0.7" />
      <ellipse cx={@x + 2} cy={@y + 4} rx="1.5" ry="2.5" fill="#22C55E" opacity="0.5" />
      <!-- Highlight bubble -->
      <circle cx={@x + 1} cy={@y - 1} r="2" fill="#86EFAC" opacity="0.8" />
      <circle cx={@x - 2} cy={@y} r="1" fill="#86EFAC" opacity="0.6" />
    </g>
    """
  end

  # Laser beam projectile (laser tower)
  defp projectile_visual(%{projectile_type: :laser_beam} = assigns) do
    ~H"""
    <g class="laser-beam">
      <!-- Outer glow -->
      <ellipse cx={@x} cy={@y} rx="8" ry="4" fill="#E879F9" opacity="0.3" />
      <!-- Inner beam -->
      <ellipse cx={@x} cy={@y} rx="6" ry="2" fill="#E879F9" opacity="0.8" />
      <ellipse cx={@x} cy={@y} rx="4" ry="1" fill="#F5D0FE" />
      <!-- Core -->
      <ellipse cx={@x + 2} cy={@y} rx="2" ry="1" fill="white" opacity="0.9" />
    </g>
    """
  end

  # No visible projectile (for instant-hit towers)
  defp projectile_visual(%{projectile_type: :none} = assigns) do
    ~H"""
    <g></g>
    """
  end

  # Default projectile - falls back to damage_type color
  defp projectile_visual(assigns) do
    color = Damage.damage_type_color(assigns.damage_type)
    assigns = assign(assigns, :color, color)

    ~H"""
    <circle cx={@x} cy={@y} r="4" fill={@color} />
    """
  end

  # ============================================================================
  # MINION VISUALS
  # ============================================================================

  attr :minion, :map, required: true

  defp minion(assigns) do
    {x, y} = assigns.minion.position

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)

    ~H"""
    <g class="minion walking-bomb">
      <!-- Shadow -->
      <ellipse cx={@x} cy={@y + 7} rx="6" ry="2" fill="rgba(0,0,0,0.3)" />
      <!-- Bomb body - dark round shape -->
      <circle cx={@x} cy={@y} r="7" fill="#1f2937" />
      <!-- Highlight -->
      <circle cx={@x - 2} cy={@y - 2} r="3" fill="#374151" opacity="0.6" />
      <!-- Fuse cap -->
      <rect x={@x - 2} y={@y - 10} width="4" height="3" fill="#78716c" />
      <!-- Fuse -->
      <path
        d={"M #{@x} #{@y - 10} Q #{@x + 4} #{@y - 14} #{@x + 2} #{@y - 16}"}
        stroke="#92400e"
        stroke-width="2"
        fill="none"
        class="fuse-burn"
      />
      <!-- Spark with glow -->
      <circle cx={@x + 2} cy={@y - 16} r="3" fill="#fef08a" opacity="0.5" class="spark-glow" />
      <circle cx={@x + 2} cy={@y - 16} r="2" fill="#fbbf24" class="spark" />
      <circle cx={@x + 2} cy={@y - 16} r="1" fill="#fef9c3" />
      <!-- Little legs for walking animation -->
      <ellipse cx={@x - 4} cy={@y + 6} rx="2" ry="3" fill="#1f2937" class="leg-left" />
      <ellipse cx={@x + 4} cy={@y + 6} rx="2" ry="3" fill="#1f2937" class="leg-right" />
    </g>
    """
  end

  # ============================================================================
  # EXPLOSION/EFFECT VISUALS - Unique for each damage type
  # ============================================================================

  attr :effect, :map, required: true

  defp effect(assigns) do
    x = Map.get(assigns.effect, :x, 0)
    y = Map.get(assigns.effect, :y, 0)
    radius = Map.get(assigns.effect, :radius, 20)
    damage_type = Map.get(assigns.effect, :damage_type, :physical)

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:radius, radius)
      |> assign(:damage_type, damage_type)

    ~H"""
    <g class={"explosion explosion-#{@damage_type}"}>
      <.explosion_visual damage_type={@damage_type} x={@x} y={@y} radius={@radius} />
    </g>
    """
  end

  attr :damage_type, :atom, required: true
  attr :x, :float, required: true
  attr :y, :float, required: true
  attr :radius, :float, required: true

  # Physical explosion - grey shockwave
  defp explosion_visual(%{damage_type: :physical} = assigns) do
    ~H"""
    <g>
      <circle cx={@x} cy={@y} r={@radius} fill="none" stroke="#9CA3AF" stroke-width="3" opacity="0.7" />
      <circle cx={@x} cy={@y} r={@radius * 0.6} fill="#6B7280" opacity="0.4" />
    </g>
    """
  end

  # Fire explosion - orange flame burst
  defp explosion_visual(%{damage_type: :fire} = assigns) do
    ~H"""
    <g>
      <circle cx={@x} cy={@y} r={@radius} fill="#F97316" opacity="0.5" />
      <circle cx={@x} cy={@y} r={@radius * 0.7} fill="#FACC15" opacity="0.6" />
      <circle cx={@x} cy={@y} r={@radius * 0.4} fill="#FEF08A" opacity="0.8" />
      <!-- Flame particles -->
      <circle
        cx={@x - @radius * 0.5}
        cy={@y - @radius * 0.3}
        r={@radius * 0.2}
        fill="#F97316"
        opacity="0.7"
      />
      <circle
        cx={@x + @radius * 0.4}
        cy={@y - @radius * 0.4}
        r={@radius * 0.15}
        fill="#FACC15"
        opacity="0.6"
      />
    </g>
    """
  end

  # Ice explosion - blue frost shatter
  defp explosion_visual(%{damage_type: :ice} = assigns) do
    ~H"""
    <g>
      <circle cx={@x} cy={@y} r={@radius} fill="#38BDF8" opacity="0.3" />
      <!-- Ice shards -->
      <line x1={@x} y1={@y} x2={@x} y2={@y - @radius} stroke="#E0F2FE" stroke-width="2" />
      <line
        x1={@x}
        y1={@y}
        x2={@x + @radius * 0.7}
        y2={@y - @radius * 0.7}
        stroke="#E0F2FE"
        stroke-width="2"
      />
      <line x1={@x} y1={@y} x2={@x + @radius} y2={@y} stroke="#E0F2FE" stroke-width="2" />
      <line
        x1={@x}
        y1={@y}
        x2={@x + @radius * 0.7}
        y2={@y + @radius * 0.7}
        stroke="#E0F2FE"
        stroke-width="2"
      />
      <line x1={@x} y1={@y} x2={@x} y2={@y + @radius} stroke="#E0F2FE" stroke-width="2" />
      <line
        x1={@x}
        y1={@y}
        x2={@x - @radius * 0.7}
        y2={@y + @radius * 0.7}
        stroke="#E0F2FE"
        stroke-width="2"
      />
      <line x1={@x} y1={@y} x2={@x - @radius} y2={@y} stroke="#E0F2FE" stroke-width="2" />
      <line
        x1={@x}
        y1={@y}
        x2={@x - @radius * 0.7}
        y2={@y - @radius * 0.7}
        stroke="#E0F2FE"
        stroke-width="2"
      />
    </g>
    """
  end

  # Lightning explosion - yellow electric arcs
  defp explosion_visual(%{damage_type: :lightning} = assigns) do
    ~H"""
    <g>
      <circle cx={@x} cy={@y} r={@radius * 0.3} fill="#FEF08A" opacity="0.9" />
      <!-- Electric arcs -->
      <polyline
        points={"#{@x},#{@y} #{@x + @radius * 0.3},#{@y - @radius * 0.5} #{@x + @radius * 0.6},#{@y - @radius * 0.3} #{@x + @radius},#{@y - @radius * 0.6}"}
        fill="none"
        stroke="#FACC15"
        stroke-width="2"
      />
      <polyline
        points={"#{@x},#{@y} #{@x - @radius * 0.4},#{@y + @radius * 0.4} #{@x - @radius * 0.7},#{@y + @radius * 0.2} #{@x - @radius},#{@y + @radius * 0.5}"}
        fill="none"
        stroke="#FACC15"
        stroke-width="2"
      />
      <polyline
        points={"#{@x},#{@y} #{@x + @radius * 0.2},#{@y + @radius * 0.6} #{@x + @radius * 0.5},#{@y + @radius * 0.4} #{@x + @radius * 0.8},#{@y + @radius}"}
        fill="none"
        stroke="#FACC15"
        stroke-width="2"
      />
    </g>
    """
  end

  # Poison explosion - green toxic cloud
  defp explosion_visual(%{damage_type: :poison} = assigns) do
    ~H"""
    <g>
      <circle cx={@x} cy={@y} r={@radius} fill="#22C55E" opacity="0.3" />
      <!-- Toxic clouds -->
      <circle
        cx={@x - @radius * 0.3}
        cy={@y - @radius * 0.2}
        r={@radius * 0.5}
        fill="#22C55E"
        opacity="0.4"
      />
      <circle
        cx={@x + @radius * 0.4}
        cy={@y + @radius * 0.1}
        r={@radius * 0.4}
        fill="#86EFAC"
        opacity="0.5"
      />
      <circle cx={@x} cy={@y + @radius * 0.3} r={@radius * 0.35} fill="#22C55E" opacity="0.4" />
      <!-- Bubbles -->
      <circle
        cx={@x - @radius * 0.2}
        cy={@y - @radius * 0.4}
        r={@radius * 0.1}
        fill="#86EFAC"
        opacity="0.7"
      />
      <circle
        cx={@x + @radius * 0.3}
        cy={@y - @radius * 0.3}
        r={@radius * 0.08}
        fill="#86EFAC"
        opacity="0.6"
      />
    </g>
    """
  end

  # Energy explosion - purple pulse wave
  defp explosion_visual(%{damage_type: :energy} = assigns) do
    ~H"""
    <g>
      <circle cx={@x} cy={@y} r={@radius} fill="none" stroke="#E879F9" stroke-width="4" opacity="0.6" />
      <circle
        cx={@x}
        cy={@y}
        r={@radius * 0.7}
        fill="none"
        stroke="#F5D0FE"
        stroke-width="3"
        opacity="0.7"
      />
      <circle cx={@x} cy={@y} r={@radius * 0.4} fill="#E879F9" opacity="0.5" />
      <circle cx={@x} cy={@y} r={@radius * 0.2} fill="white" opacity="0.8" />
    </g>
    """
  end

  # Default explosion
  defp explosion_visual(assigns) do
    color = Map.get(assigns, :color, "#f97316")
    assigns = assign(assigns, :color, color)

    ~H"""
    <circle cx={@x} cy={@y} r={@radius} fill={@color} opacity="0.5" />
    """
  end

  # ============================================================================
  # DESIGNER TOOLS
  # ============================================================================

  @doc """
  Renders designer mode tools.
  """
  attr :game_state, :map, required: true
  attr :show_debug, :boolean, default: false

  def designer_tools(assigns) do
    ~H"""
    <div class="designer-panel border-t border-gray-700 bg-gray-900/90 p-4">
      <div class="flex gap-6 items-center flex-wrap">
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

        <div class="flex items-center gap-2 flex-wrap">
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
