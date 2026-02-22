const MonthlyUsageChart = {
  mounted() {
    this.renderChart()
  },

  updated() {
    this.chart.destroy()
    this.renderChart()
  },

  renderChart() {
    const ctx = this.el.getContext("2d")

    const labels = JSON.parse(this.el.dataset.labels)
    const values = JSON.parse(this.el.dataset.values)

    // Gradient fill
    const gradient = ctx.createLinearGradient(0, 0, 0, 200)
    gradient.addColorStop(0, "rgba(59,130,246,0.4)")
    gradient.addColorStop(1, "rgba(59,130,246,0)")

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [{
          label: "API Calls",
          data: values,
          tension: 0.4,
          fill: true,
          backgroundColor: gradient,
          borderColor: "#3B82F6",
          pointRadius: 4,
          pointHoverRadius: 6,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: "#111827",
            titleColor: "#fff",
            bodyColor: "#fff",
            borderColor: "#374151",
            borderWidth: 1,
          }
        },
        scales: {
          x: {
            ticks: { color: "#9CA3AF" },
            grid: { display: false }
          },
          y: {
            beginAtZero: true,
            ticks: { color: "#9CA3AF" },
            grid: { color: "rgba(255,255,255,0.05)" }
          }
        }
      }
    })
  }
}

export default MonthlyUsageChart
