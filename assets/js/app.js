import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
// import topbar from "../vendor/topbar"  // Disabled due to error

let Hooks = {}

// Game board hook for handling canvas/SVG interactions
Hooks.GameBoard = {
  mounted() {
    console.log("GameBoard hook mounted")

    // Get the SVG element inside the game board
    this.svg = this.el.querySelector("svg")
    console.log("SVG element found:", !!this.svg)

    // Track mouse position in SVG coordinates (throttled)
    this.lastMouseMove = 0
    this.el.addEventListener("mousemove", (e) => {
      const now = Date.now()
      if (now - this.lastMouseMove < 50) return // Throttle to 20fps
      this.lastMouseMove = now

      const coords = this.clientToSVG(e.clientX, e.clientY)
      this.pushEvent("mouse_move", {x: coords.x, y: coords.y})
    })

    // Handle clicks for tower placement
    this.el.addEventListener("click", (e) => {
      const coords = this.clientToSVG(e.clientX, e.clientY)
      console.log("Board clicked at SVG coords:", coords)
      this.pushEvent("board_click", {x: coords.x.toString(), y: coords.y.toString()})
    })
  },

  // Convert client coordinates to SVG viewBox coordinates
  clientToSVG(clientX, clientY) {
    const svg = this.el.querySelector("svg")
    if (!svg) {
      console.warn("SVG element not found")
      return {x: 0, y: 0}
    }

    const rect = svg.getBoundingClientRect()
    const viewBox = svg.viewBox.baseVal

    if (!viewBox || viewBox.width === 0) {
      console.warn("SVG viewBox not available or zero width")
      return {x: clientX - rect.left, y: clientY - rect.top}
    }

    // Calculate scale factors between viewport and viewBox
    const scaleX = viewBox.width / rect.width
    const scaleY = viewBox.height / rect.height

    // Transform coordinates
    const x = (clientX - rect.left) * scaleX
    const y = (clientY - rect.top) * scaleY

    return {x: x, y: y}
  }
}

// Keyboard hook for designer mode hotkeys
Hooks.GameKeys = {
  mounted() {
    console.log("GameKeys hook mounted")

    this.handleKeyDown = (e) => {
      if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") return

      switch(e.key.toLowerCase()) {
        case "p":
          this.pushEvent("toggle_pause", {})
          break
        case " ":
          e.preventDefault()
          this.pushEvent("single_step", {})
          break
        case "+":
        case "=":
          this.pushEvent("speed_up", {})
          break
        case "-":
          this.pushEvent("speed_down", {})
          break
        case "d":
          this.pushEvent("toggle_debug", {})
          break
        case "escape":
          this.pushEvent("deselect", {})
          break
      }
    }

    window.addEventListener("keydown", this.handleKeyDown)
  },

  destroyed() {
    window.removeEventListener("keydown", this.handleKeyDown)
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  dom: {
    onBeforeElUpdated(from, to) {
      // Preserve hook state during updates
      if (from._x_dataStack) {
        to._x_dataStack = from._x_dataStack
      }
      return true
    }
  }
})

// Enable debug logging for LiveView connection
liveSocket.enableDebug()
console.log("LiveSocket initialized, connecting...")

// Connect first - this is critical for LiveView to work
liveSocket.connect()

// Log connection status after connect is called
let socket = liveSocket.getSocket()
if (socket) {
  socket.onOpen(() => console.log("LiveSocket connected!"))
  socket.onError((err) => console.error("LiveSocket error:", err))
  socket.onClose(() => console.log("LiveSocket closed"))
}

// Topbar disabled due to JavaScript error
// window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
// window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

window.liveSocket = liveSocket
