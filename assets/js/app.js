// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"

// Phoenix & LiveView
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/ai_guard"
import topbar from "../vendor/topbar"

// ✅ Chart.js
import Chart from "chart.js/auto"
window.Chart = Chart

// ✅ Usage Chart Hook
import UsageChart from "./hooks/usage_chart"

// Merge hooks
let Hooks = { ...colocatedHooks }
Hooks.UsageChart = UsageChart

// CSRF
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// ✅ SINGLE LiveSocket instance
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// Topbar loader
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

// Connect LiveView
liveSocket.connect()

// Debug helpers
window.liveSocket = liveSocket

// Live reload helpers (dev only)
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
    reloader.enableServerLogs()
    window.liveReloader = reloader
  })
}
